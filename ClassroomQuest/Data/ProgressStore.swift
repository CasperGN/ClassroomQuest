import Combine
internal import CoreData
import Foundation

enum CurriculumLevelStatus {
    case locked
    case current
    case completed
}

@MainActor
final class ProgressStore: ObservableObject {
    private let context: NSManagedObjectContext
    private let masteryEngine = MathMasteryEngine()
    // In-memory recent prompts cache to reduce repeats across sessions (per app run)
    private var recentPromptsBySkill: [String: Set<String>] = [:]
    weak var achievementReporter: GameCenterAchievementReporting?

    struct CurriculumLevelRecord: Codable {
        var attempts: Int = 0
        var bestCompletedQuestCount: Int = 0
        var assistedUnlock: Bool = false

        var needsReview: Bool { assistedUnlock }
    }

    struct CurriculumOverallProgress {
        let level: Int
        let progressToNext: Double
        let completedLevels: Int
        let totalLevels: Int
    }

    private struct CurriculumStoredState: Codable {
        var highestUnlockedIndex: [String: Int]
        var placementGradeRaw: String?
        var levelRecords: [String: [String: CurriculumLevelRecord]]
    }

    private struct CurriculumLegacyStoredState: Codable {
        var highestUnlockedIndex: [String: Int]
        var placementGradeRaw: String?
    }

    @Published private(set) var curriculumHighestUnlockedIndex: [CurriculumSubject: Int]
    @Published private(set) var curriculumPlacementGrade: CurriculumGrade?
    @Published private(set) var curriculumLevelRecords: [CurriculumSubject: [UUID: CurriculumLevelRecord]]

    private static let curriculumStorageKey = "curriculum.progress.state.v2"
    private static let curriculumLegacyStorageKey = "curriculum.progress.state.v1"
    private let assistedUnlockAttemptThreshold = 3
    private let userDefaults: UserDefaults

    init(viewContext: NSManagedObjectContext, userDefaults: UserDefaults = .standard) {
        self.context = viewContext
        self.userDefaults = userDefaults
        let initialState = ProgressStore.loadCurriculumState(userDefaults: userDefaults)
        curriculumHighestUnlockedIndex = initialState.highestUnlockedIndex
        curriculumPlacementGrade = initialState.placementGrade
        curriculumLevelRecords = initialState.levelRecords
    }

    func subjectProgress(for subject: LearningSubject) throws -> SubjectProgress {
        if let progress = try context.fetch(SubjectProgress.fetchRequest(for: subject.id)).first {
            resetDailyCountIfNeeded(progress: progress)
            return progress
        }

        let progress = SubjectProgress(context: context)
        progress.id = subject.id
        progress.dailyExerciseCount = 0
        progress.totalSessions = 0
        progress.totalCorrectAnswers = 0
        try context.save()
        return progress
    }

    func skillProgress(for skill: MathSkill, subject: LearningSubject) throws -> SkillProgress {
        if let stored = try context.fetch(SkillProgress.fetchRequest(for: skill.id, subjectID: subject.id)).first {
            return stored
        }

        let skillProgress = SkillProgress(context: context)
        skillProgress.id = skill.id
        skillProgress.subjectID = subject.id
        skillProgress.proficiency = 0
        skillProgress.streak = 0
        try context.save()
        return skillProgress
    }

    func proficiency(for skill: MathSkill, subject: LearningSubject) -> Double {
        (try? skillProgress(for: skill, subject: subject).proficiency) ?? 0
    }

    func canStartExercise(for subject: LearningSubject, on date: Date = Date()) -> Bool {
        guard let progress = try? subjectProgress(for: subject) else { return true }
        resetDailyCountIfNeeded(progress: progress, referenceDate: date)
        return progress.dailyExerciseCount < 1
    }

    func recordSession(for subject: LearningSubject, results: [MathProblemResult], referenceDate: Date = Date()) throws {
        objectWillChange.send()
        let progress = try subjectProgress(for: subject)
        resetDailyCountIfNeeded(progress: progress, referenceDate: referenceDate)
        progress.dailyExerciseCount += 1
        progress.totalSessions += 1
        progress.totalCorrectAnswers += Int32(results.filter { $0.isCorrect }.count)
        progress.lastExerciseDate = referenceDate

        var newlyMasteredSkills = Set<MathSkill>()

        // Update recent prompts cache to reduce repeats in subsequent sessions within app lifetime
        for result in results {
            let key = result.problem.skill.id
            var set = recentPromptsBySkill[key] ?? Set<String>()
            set.insert(result.problem.prompt)
            recentPromptsBySkill[key] = set
        }

        for result in results {
            let skill = result.problem.skill
            let skillProgress = try skillProgress(for: skill, subject: subject)
            let priorProficiency = skillProgress.proficiency
            let updated = masteryEngine.updatedProficiency(from: priorProficiency, correct: result.isCorrect, difficulty: result.problem.difficulty, streak: Int(skillProgress.streak))
            skillProgress.proficiency = updated
            skillProgress.lastReviewed = referenceDate
            if result.isCorrect {
                skillProgress.streak += 1
            } else {
                skillProgress.streak = 0
            }

            if priorProficiency < MathSkill.masteryThreshold && updated >= MathSkill.masteryThreshold {
                newlyMasteredSkills.insert(skill)
            }
        }

        try context.save()

        let report = GameSessionReport(
            subject: subject,
            totalSessions: Int(progress.totalSessions),
            totalCorrectAnswers: Int(progress.totalCorrectAnswers),
            newMasteredSkills: Array(newlyMasteredSkills)
        )
        achievementReporter?.recordSession(report: report)
    }

    func focusSkill(for subject: LearningSubject) -> MathSkill {
        masteryEngine.nextFocusSkill { skill in
            proficiency(for: skill, subject: subject)
        }
    }

    func focusSkillProficiency(for subject: LearningSubject) -> Double {
        let skill = focusSkill(for: subject)
        return proficiency(for: skill, subject: subject)
    }

    private func resetDailyCountIfNeeded(progress: SubjectProgress, referenceDate: Date = Date()) {
        guard let lastDate = progress.lastExerciseDate else {
            progress.dailyExerciseCount = 0
            return
        }
        if !Calendar.current.isDate(lastDate, inSameDayAs: referenceDate) {
            progress.dailyExerciseCount = 0
        }
    }
    
    func recentPrompts(for skill: MathSkill) -> Set<String> {
        recentPromptsBySkill[skill.id] ?? []
    }
    
    func setProficiency(_ value: Double, for skill: MathSkill, subject: LearningSubject) throws {
        let sp = try skillProgress(for: skill, subject: subject)
        sp.proficiency = value
        try context.save()
    }
    
    func applyPlacement(profile: PlacementProfile, subject: LearningSubject = .math) throws {
        // Seeding strategy:
        // - Skills clearly below the selected grade band: seed slightly above mastery to skip trivial content.
        // - At-grade skills: seed mid-range to allow quick probing upward.
        // - Above-grade skills: seed slightly lower to allow the engine to climb if ready.
        let masteredSeed: Double = MathSkill.masteryThreshold + 0.2 // slightly above mastery
        let midSeed: Double = 0.0 // middle of our -2.5...2.5 proficiency scale
        let lowSeed: Double = -0.8 // below mid to allow climbing

        for skill in MathSkill.allCases {
            let band = skill.gradeBand
            let seed: Double
            switch band {
            case .kindergarten, .grade1:
                // If selecting K or 1, keep foundations at mid, others low
                if profile.gradeBand == .kindergarten {
                    seed = (band == .kindergarten) ? midSeed : lowSeed
                } else if profile.gradeBand == .grade1 {
                    seed = (band == .kindergarten) ? masteredSeed : (band == .grade1 ? midSeed : lowSeed)
                } else {
                    // Higher placement; K/1 skills assumed mastered
                    seed = masteredSeed
                }
            case .grade2:
                if profile.gradeBand.rawValue <= GradeBand.grade2.rawValue {
                    seed = (profile.gradeBand == .grade2) ? midSeed : lowSeed
                } else {
                    seed = masteredSeed
                }
            case .grade3:
                if profile.gradeBand.rawValue <= GradeBand.grade3.rawValue {
                    seed = (profile.gradeBand == .grade3) ? midSeed : lowSeed
                } else {
                    seed = masteredSeed
                }
            case .grade4:
                if profile.gradeBand.rawValue <= GradeBand.grade4.rawValue {
                    seed = (profile.gradeBand == .grade4) ? midSeed : lowSeed
                } else {
                    seed = masteredSeed
                }
            case .grade5:
                if profile.gradeBand == .grade5 {
                    seed = midSeed
                } else if profile.gradeBand.rawValue > GradeBand.grade5.rawValue {
                    seed = masteredSeed
                } else {
                    seed = lowSeed
                }
            }
            try setProficiency(seed, for: skill, subject: subject)
        }

        // Optionally nudge focus skills upward a bit to prioritize them early.
        for skill in profile.focusSkills {
            let current = proficiency(for: skill, subject: subject)
            try setProficiency(max(current, midSeed + 0.3), for: skill, subject: subject)
        }
    }

    // MARK: - Curriculum progression

    func curriculumStatus(for level: CurriculumLevel, subject: CurriculumSubject) -> CurriculumLevelStatus {
        let levels = CurriculumCatalog.subjectPath(for: subject).levels
        guard let index = levels.firstIndex(of: level) else { return .locked }
        let unlockedIndex = curriculumHighestUnlockedIndex[subject] ?? 0
        if unlockedIndex >= levels.count { return .completed }
        if index < unlockedIndex { return .completed }
        if index == unlockedIndex { return .current }
        return .locked
    }

    func markCurriculumLevelCompleted(
        _ level: CurriculumLevel,
        subject: CurriculumSubject,
        completedQuests: Int,
        assisted: Bool = false
    ) {
        let levels = CurriculumCatalog.subjectPath(for: subject).levels
        guard let index = levels.firstIndex(of: level) else { return }
        registerCurriculumAttempt(
            for: level,
            subject: subject,
            completedQuests: completedQuests,
            assisted: assisted
        )
        advanceCurriculumPastLevel(at: index, subject: subject)
        persistCurriculum()
    }

    func resetCurriculumProgress() {
        curriculumHighestUnlockedIndex = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, 0) })
        curriculumPlacementGrade = nil
        curriculumLevelRecords = Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, [:]) })
        persistCurriculum()
    }

    func applyCurriculumPlacement(grade: CurriculumGrade) {
        curriculumPlacementGrade = grade
        for subject in CurriculumSubject.allCases {
            let levels = CurriculumCatalog.subjectPath(for: subject).levels
            guard !levels.isEmpty else {
                curriculumHighestUnlockedIndex[subject] = 0
                curriculumLevelRecords[subject] = [:]
                continue
            }

            let targetIndex = CurriculumCatalog.indexOfFirstLevel(for: grade, subject: subject) ?? 0
            let clampedIndex = min(max(targetIndex, 0), max(levels.count - 1, 0))
            curriculumHighestUnlockedIndex[subject] = clampedIndex
            curriculumLevelRecords[subject] = [:]
        }
        persistCurriculum()
    }

    func resetCurriculumSubject(_ subject: CurriculumSubject) {
        curriculumHighestUnlockedIndex[subject] = 0
        curriculumLevelRecords[subject] = [:]
        persistCurriculum()
    }

    func recordCurriculumIncompleteAttempt(
        for level: CurriculumLevel,
        subject: CurriculumSubject,
        completedQuests: Int
    ) {
        registerCurriculumAttempt(for: level, subject: subject, completedQuests: completedQuests, assisted: false)
        persistCurriculum()
    }

    func shouldOfferCurriculumAssistedUnlock(
        for level: CurriculumLevel,
        subject: CurriculumSubject,
        pendingCompletedQuests: Int
    ) -> Bool {
        guard curriculumStatus(for: level, subject: subject) == .current else { return false }
        guard let record = curriculumLevelRecords[subject]?[level.id] else { return false }
        if record.assistedUnlock { return false }

        let attemptsIncludingCurrent = record.attempts + 1
        let bestCompleted = max(record.bestCompletedQuestCount, pendingCompletedQuests)
        let minimumQuestsForAssist = max(1, level.questsRequiredForMastery - 1)

        return attemptsIncludingCurrent >= assistedUnlockAttemptThreshold
            && bestCompleted >= minimumQuestsForAssist
            && pendingCompletedQuests < level.questsRequiredForMastery
    }

    func curriculumLevelRecord(for level: CurriculumLevel, subject: CurriculumSubject) -> CurriculumLevelRecord? {
        curriculumLevelRecords[subject]?[level.id]
    }

    func curriculumOverallProgress() -> CurriculumOverallProgress {
        let totalLevels = CurriculumCatalog.totalLevelCount
        guard totalLevels > 0 else {
            return CurriculumOverallProgress(level: 1, progressToNext: 0, completedLevels: 0, totalLevels: 0)
        }

        var completedLevels = 0
        var bestFractionTowardNext: Double = 0

        for subject in CurriculumSubject.allCases {
            let path = CurriculumCatalog.subjectPath(for: subject)
            let unlocked = min(curriculumHighestUnlockedIndex[subject] ?? 0, path.levels.count)
            completedLevels += min(unlocked, path.levels.count)

            guard unlocked < path.levels.count else { continue }
            let currentLevel = path.levels[unlocked]
            let record = curriculumLevelRecords[subject]?[currentLevel.id]
            let required = max(1, currentLevel.questsRequiredForMastery)
            let fraction = min(1, max(0, Double(record?.bestCompletedQuestCount ?? 0) / Double(required)))
            bestFractionTowardNext = max(bestFractionTowardNext, fraction)
        }

        let cappedCompleted = min(totalLevels, completedLevels)
        let levelNumber = cappedCompleted + 1
        let progressToNext = cappedCompleted >= totalLevels ? 1 : bestFractionTowardNext

        return CurriculumOverallProgress(
            level: levelNumber,
            progressToNext: progressToNext,
            completedLevels: completedLevels,
            totalLevels: totalLevels
        )
    }

    private func persistCurriculum() {
        var encoded: [String: Int] = [:]
        for (subject, value) in curriculumHighestUnlockedIndex {
            encoded[subject.rawValue] = value
        }
        var encodedRecords: [String: [String: CurriculumLevelRecord]] = [:]
        for (subject, records) in curriculumLevelRecords {
            encodedRecords[subject.rawValue] = Dictionary(uniqueKeysWithValues: records.map { ($0.key.uuidString, $0.value) })
        }

        let state = CurriculumStoredState(
            highestUnlockedIndex: encoded,
            placementGradeRaw: curriculumPlacementGrade?.rawValue,
            levelRecords: encodedRecords
        )
        if let data = try? JSONEncoder().encode(state) {
            userDefaults.set(data, forKey: ProgressStore.curriculumStorageKey)
        }
        objectWillChange.send()
    }

    private func registerCurriculumAttempt(
        for level: CurriculumLevel,
        subject: CurriculumSubject,
        completedQuests: Int,
        assisted: Bool
    ) {
        var subjectRecords = curriculumLevelRecords[subject] ?? [:]
        var record = subjectRecords[level.id] ?? CurriculumLevelRecord()
        record.attempts += 1
        record.bestCompletedQuestCount = max(record.bestCompletedQuestCount, completedQuests)
        if assisted {
            record.assistedUnlock = true
        }
        subjectRecords[level.id] = record
        curriculumLevelRecords[subject] = subjectRecords
    }

    private func advanceCurriculumPastLevel(at index: Int, subject: CurriculumSubject) {
        let levels = CurriculumCatalog.subjectPath(for: subject).levels
        let current = curriculumHighestUnlockedIndex[subject] ?? 0
        guard current <= index else { return }
        let nextIndex = min(index + 1, levels.count)
        if nextIndex != current {
            curriculumHighestUnlockedIndex[subject] = nextIndex
        }
    }

    private static func loadCurriculumState(userDefaults: UserDefaults) -> (
        highestUnlockedIndex: [CurriculumSubject: Int],
        placementGrade: CurriculumGrade?,
        levelRecords: [CurriculumSubject: [UUID: CurriculumLevelRecord]]
    ) {
        if
            let data = userDefaults.data(forKey: ProgressStore.curriculumStorageKey),
            let decoded = try? JSONDecoder().decode(CurriculumStoredState.self, from: data)
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

            var restoredRecords: [CurriculumSubject: [UUID: CurriculumLevelRecord]] = [:]
            for (subjectKey, records) in decoded.levelRecords {
                guard let subject = CurriculumSubject(rawValue: subjectKey) else { continue }
                var subjectRecords: [UUID: CurriculumLevelRecord] = [:]
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

            return (
                highestUnlockedIndex: restored,
                placementGrade: decoded.placementGradeRaw.flatMap(CurriculumGrade.init(rawValue:)),
                levelRecords: restoredRecords
            )
        } else if
            let data = userDefaults.data(forKey: ProgressStore.curriculumLegacyStorageKey),
            let decoded = try? JSONDecoder().decode(CurriculumLegacyStoredState.self, from: data)
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
            return (
                highestUnlockedIndex: restored,
                placementGrade: decoded.placementGradeRaw.flatMap(CurriculumGrade.init(rawValue:)),
                levelRecords: Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, [:]) })
            )
        } else {
            return (
                highestUnlockedIndex: Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, 0) }),
                placementGrade: nil,
                levelRecords: Dictionary(uniqueKeysWithValues: CurriculumSubject.allCases.map { ($0, [:]) })
            )
        }
    }
}
