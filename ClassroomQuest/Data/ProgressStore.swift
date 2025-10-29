import Combine
import CoreData
import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    private let context: NSManagedObjectContext
    private let masteryEngine = MathMasteryEngine()

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

        for result in results {
            let skill = result.problem.skill
            let skillProgress = try skillProgress(for: skill, subject: subject)
            let updated = masteryEngine.updatedProficiency(from: skillProgress.proficiency, correct: result.isCorrect, difficulty: result.problem.difficulty)
            skillProgress.proficiency = updated
            skillProgress.lastReviewed = referenceDate
            if result.isCorrect {
                skillProgress.streak += 1
            } else {
                skillProgress.streak = 0
            }
        }

        try context.save()
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
}
