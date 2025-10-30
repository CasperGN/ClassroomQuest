import Foundation
import SwiftUI

enum CurriculumLevelStatus {
    case locked
    case current
    case completed
}

@MainActor
final class CurriculumProgressStore: ObservableObject {
    private struct StoredState: Codable {
        var highestUnlockedIndex: [String: Int]
        var placementGradeRaw: String?
    }

    private let storageKey = "curriculum.progress.state.v1"

    @Published private(set) var highestUnlockedIndex: [CurriculumSubject: Int]
    @Published private(set) var placementGrade: CurriculumGrade?

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if
            let data = userDefaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(StoredState.self, from: data)
        {
            var restored: [CurriculumSubject: Int] = [:]
            for (key, value) in decoded.highestUnlockedIndex {
                if let subject = CurriculumSubject(rawValue: key) {
                    restored[subject] = value
                }
            }
            for subject in CurriculumSubject.allCases where restored[subject] == nil {
                restored[subject] = 0
            }
            highestUnlockedIndex = restored
            placementGrade = decoded.placementGradeRaw.flatMap(CurriculumGrade.init(rawValue:))
        } else {
            highestUnlockedIndex = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, 0) })
            placementGrade = nil
        }
    }

    func status(for level: CurriculumLevel, subject: CurriculumSubject) -> CurriculumLevelStatus {
        let levels = CurriculumCatalog.subjectPath(for: subject).levels
        guard let index = levels.firstIndex(of: level) else { return .locked }
        let unlockedIndex = highestUnlockedIndex[subject] ?? 0
        if unlockedIndex >= levels.count {
            return .completed
        }
        if index < unlockedIndex {
            return .completed
        } else if index == unlockedIndex {
            return .current
        } else {
            return .locked
        }
    }

    func markLevelCompleted(_ level: CurriculumLevel, subject: CurriculumSubject) {
        let levels = CurriculumCatalog.subjectPath(for: subject).levels
        guard let index = levels.firstIndex(of: level) else { return }
        let current = highestUnlockedIndex[subject] ?? 0
        guard current <= index else { return }
        let nextIndex = min(index + 1, levels.count)
        if nextIndex != current {
            highestUnlockedIndex[subject] = nextIndex
            persist()
        }
    }

    func resetProgress() {
        highestUnlockedIndex = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, 0) })
        placementGrade = nil
        persist()
    }

    func applyPlacement(grade: CurriculumGrade) {
        placementGrade = grade
        for subject in CurriculumSubject.allCases {
            let levels = CurriculumCatalog.subjectPath(for: subject).levels
            let targetIndex = CurriculumCatalog.indexOfFirstLevel(for: grade, subject: subject) ?? 0
            highestUnlockedIndex[subject] = min(targetIndex, levels.count)
        }
        persist()
    }

    func resetSubject(_ subject: CurriculumSubject) {
        highestUnlockedIndex[subject] = 0
        persist()
    }

    private func persist() {
        var encoded: [String: Int] = [:]
        for (subject, value) in highestUnlockedIndex {
            encoded[subject.rawValue] = value
        }
        let state = StoredState(highestUnlockedIndex: encoded, placementGradeRaw: placementGrade?.rawValue)
        if let data = try? JSONEncoder().encode(state) {
            userDefaults.set(data, forKey: storageKey)
        }
        objectWillChange.send()
    }

    private let userDefaults: UserDefaults
}
