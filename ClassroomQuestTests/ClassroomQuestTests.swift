import Testing
import CoreData
@testable import ClassroomQuest

struct ClassroomQuestTests {

    @Test func dailyExerciseLimitResetsWithNewDay() throws {
        let controller = PersistenceController(inMemory: true)
        let store = ProgressStore(viewContext: controller.container.viewContext)
        let skill = MathSkill.counting
        let problem = MathProblem(prompt: "Count", correctAnswer: 3, skill: skill, difficulty: 0.1)

        #expect(store.canStartExercise(for: .math))
        try store.recordSession(for: .math, results: [MathProblemResult(problem: problem, isCorrect: true)])
        #expect(!store.canStartExercise(for: .math))

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        #expect(store.canStartExercise(for: .math, on: tomorrow))
    }

    @Test func masteryImprovesAfterCorrectAnswer() throws {
        let controller = PersistenceController(inMemory: true)
        let store = ProgressStore(viewContext: controller.container.viewContext)
        let skill = MathSkill.additionWithin10
        let problem = MathProblem(prompt: "2 + 2", correctAnswer: 4, skill: skill, difficulty: 0.5)

        let initial = store.proficiency(for: skill, subject: .math)
        try store.recordSession(for: .math, results: [MathProblemResult(problem: problem, isCorrect: true)])
        let updated = store.proficiency(for: skill, subject: .math)

        #expect(updated > initial)
    }
}
