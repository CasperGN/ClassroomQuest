import Foundation
import SwiftUI

enum CurriculumLevelStatus {
    case locked
    case current
    case completed
}

@MainActor
final class CurriculumProgressStore: ObservableObject {
    struct LevelRecord: Codable {
        var attempts: Int = 0
        var bestCompletedQuestCount: Int = 0
        var assistedUnlock: Bool = false

        var needsReview: Bool { assistedUnlock }
    }

    private struct StoredState: Codable {
        var highestUnlockedIndex: [String: Int]
        var placementGradeRaw: String?
        var levelRecords: [String: [String: LevelRecord]]
    }

    private struct LegacyStoredState: Codable {
        var highestUnlockedIndex: [String: Int]
        var placementGradeRaw: String?
    }

    private let storageKey = "curriculum.progress.state.v2"
    private let legacyStorageKey = "curriculum.progress.state.v1"
    private let assistedUnlockAttemptThreshold = 3

    @Published private(set) var highestUnlockedIndex: [CurriculumSubject: Int]
    @Published private(set) var placementGrade: CurriculumGrade?
    @Published private(set) var levelRecords: [CurriculumSubject: [UUID: LevelRecord]]

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

            var restoredRecords: [CurriculumSubject: [UUID: LevelRecord]] = [:]
            for (subjectKey, records) in decoded.levelRecords {
                guard let subject = CurriculumSubject(rawValue: subjectKey) else { continue }
                var subjectRecords: [UUID: LevelRecord] = [:]
                for (levelID, record) in records {
                    if let uuid = UUID(uuidString: levelID) {
                        subjectRecords[uuid] = record
                    }
                }
                restoredRecords[subject] = subjectRecords
            }

            for subject in CurriculumSubject.allCases where restoredRecords[subject] == nil {
                restoredRecords[subject] = [:]
            }

            levelRecords = restoredRecords
        } else if
            let data = userDefaults.data(forKey: legacyStorageKey),
            let decoded = try? JSONDecoder().decode(LegacyStoredState.self, from: data)
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
            levelRecords = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, [:]) })
        } else {
            highestUnlockedIndex = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, 0) })
            placementGrade = nil
            levelRecords = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, [:]) })
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

    func markLevelCompleted(
        _ level: CurriculumLevel,
        subject: CurriculumSubject,
        completedQuests: Int,
        assisted: Bool = false
    ) {
        let levels = CurriculumCatalog.subjectPath(for: subject).levels
        guard let index = levels.firstIndex(of: level) else { return }
        registerAttempt(
            for: level,
            subject: subject,
            completedQuests: completedQuests,
            assisted: assisted
        )
        advancePastLevel(at: index, subject: subject)
        persist()
    }

    func resetProgress() {
        highestUnlockedIndex = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, 0) })
        placementGrade = nil
        levelRecords = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, [:]) })
        persist()
    }

    func applyPlacement(grade: CurriculumGrade) {
        placementGrade = grade
        for subject in CurriculumSubject.allCases {
            let levels = CurriculumCatalog.subjectPath(for: subject).levels
            let targetIndex = CurriculumCatalog.indexOfFirstLevel(for: grade, subject: subject) ?? 0
            highestUnlockedIndex[subject] = min(targetIndex, levels.count)
            levelRecords[subject] = [:]
        }
        persist()
    }

    func resetSubject(_ subject: CurriculumSubject) {
        highestUnlockedIndex[subject] = 0
        levelRecords[subject] = [:]
        persist()
    }

    func recordIncompleteAttempt(for level: CurriculumLevel, subject: CurriculumSubject, completedQuests: Int) {
        registerAttempt(for: level, subject: subject, completedQuests: completedQuests, assisted: false)
        persist()
    }

    func shouldOfferAssistedUnlock(
        for level: CurriculumLevel,
        subject: CurriculumSubject,
        pendingCompletedQuests: Int
    ) -> Bool {
        guard status(for: level, subject: subject) == .current else { return false }
        guard let record = levelRecords[subject]?[level.id] else { return false }

        if record.assistedUnlock { return false }

        let attemptsIncludingCurrent = record.attempts + 1
        let bestCompleted = max(record.bestCompletedQuestCount, pendingCompletedQuests)
        let minimumQuestsForAssist = max(1, level.questsRequiredForMastery - 1)

        return attemptsIncludingCurrent >= assistedUnlockAttemptThreshold
            && bestCompleted >= minimumQuestsForAssist
            && pendingCompletedQuests < level.questsRequiredForMastery
    }

    func levelRecord(for level: CurriculumLevel, subject: CurriculumSubject) -> LevelRecord? {
        levelRecords[subject]?[level.id]
    }

    private func persist() {
        var encoded: [String: Int] = [:]
        for (subject, value) in highestUnlockedIndex {
            encoded[subject.rawValue] = value
        }
        var encodedRecords: [String: [String: LevelRecord]] = [:]
        for (subject, records) in levelRecords {
            encodedRecords[subject.rawValue] = Dictionary(uniqueKeysWithValues: records.map { ($0.key.uuidString, $0.value) })
        }

        let state = StoredState(
            highestUnlockedIndex: encoded,
            placementGradeRaw: placementGrade?.rawValue,
            levelRecords: encodedRecords
        )
        if let data = try? JSONEncoder().encode(state) {
            userDefaults.set(data, forKey: storageKey)
        }
        objectWillChange.send()
    }

    private func registerAttempt(
        for level: CurriculumLevel,
        subject: CurriculumSubject,
        completedQuests: Int,
        assisted: Bool
    ) {
        var subjectRecords = levelRecords[subject] ?? [:]
        var record = subjectRecords[level.id] ?? LevelRecord()
        record.attempts += 1
        record.bestCompletedQuestCount = max(record.bestCompletedQuestCount, completedQuests)
        if assisted {
            record.assistedUnlock = true
        }
        subjectRecords[level.id] = record
        levelRecords[subject] = subjectRecords
    }

    private func advancePastLevel(at index: Int, subject: CurriculumSubject) {
        let levels = CurriculumCatalog.subjectPath(for: subject).levels
        let current = highestUnlockedIndex[subject] ?? 0
        guard current <= index else { return }
        let nextIndex = min(index + 1, levels.count)
        if nextIndex != current {
            highestUnlockedIndex[subject] = nextIndex
        }
    }

    private let userDefaults: UserDefaults
}
