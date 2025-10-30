import Combine
internal import CoreData
import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    private let context: NSManagedObjectContext
    private let masteryEngine = MathMasteryEngine()
    // In-memory recent prompts cache to reduce repeats across sessions (per app run)
    private var recentPromptsBySkill: [String: Set<String>] = [:]
    weak var achievementReporter: GameCenterAchievementReporting?

    init(viewContext: NSManagedObjectContext) {
        self.context = viewContext
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
}
