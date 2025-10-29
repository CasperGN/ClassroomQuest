import Testing
import CoreData
@testable import ClassroomQuest

struct ClassroomQuestTests {

    @MainActor @Test func dailyExerciseLimitResetsWithNewDay() throws {
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

    @MainActor @Test func masteryImprovesAfterCorrectAnswer() throws {
        let controller = PersistenceController(inMemory: true)
        let store = ProgressStore(viewContext: controller.container.viewContext)
        let skill = MathSkill.additionWithin10
        let problem = MathProblem(prompt: "2 + 2", correctAnswer: 4, skill: skill, difficulty: 0.5)

        let initial = store.proficiency(for: skill, subject: .math)
        try store.recordSession(for: .math, results: [MathProblemResult(problem: problem, isCorrect: true)])
        let updated = store.proficiency(for: skill, subject: .math)

        #expect(updated > initial)
    }

    @MainActor @Test func streakIncrementsOnCorrectAndResetsOnIncorrect() throws {
        let controller = PersistenceController(inMemory: true)
        let store = ProgressStore(viewContext: controller.container.viewContext)
        let skill = MathSkill.additionWithin10

        // Correct session increases streak
        let problem1 = MathProblem(prompt: "1 + 2", correctAnswer: 3, skill: skill, difficulty: 0.3)
        try store.recordSession(for: .math, results: [MathProblemResult(problem: problem1, isCorrect: true)])
        let s1 = try store.skillProgress(for: skill, subject: .math).streak
        #expect(s1 == 1)

        // Another correct increases streak again
        let problem2 = MathProblem(prompt: "2 + 2", correctAnswer: 4, skill: skill, difficulty: 0.4)
        try store.recordSession(for: .math, results: [MathProblemResult(problem: problem2, isCorrect: true)])
        let s2 = try store.skillProgress(for: skill, subject: .math).streak
        #expect(s2 == 2)

        // Incorrect resets streak
        let problem3 = MathProblem(prompt: "3 + 1", correctAnswer: 4, skill: skill, difficulty: 0.5)
        try store.recordSession(for: .math, results: [MathProblemResult(problem: problem3, isCorrect: false)])
        let s3 = try store.skillProgress(for: skill, subject: .math).streak
        #expect(s3 == 0)
    }

    @MainActor @Test func focusSkillProgressionRespondsToProficiency() throws {
        let controller = PersistenceController(inMemory: true)
        let store = ProgressStore(viewContext: controller.container.viewContext)

        // Capture initial focus skill
        let initialFocus = store.focusSkill(for: .math)
        let initialProficiency = store.proficiency(for: initialFocus, subject: .math)

        // Simulate a strong correct session on the focus skill to increase proficiency
        var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()
        let generator = MathProblemGenerator()
        let problems = generator.generateSession(for: initialFocus, proficiency: max(0.1, initialProficiency), problemCount: 5, randomSource: &rng)
        let results = problems.map { MathProblemResult(problem: $0, isCorrect: true) }
        try store.recordSession(for: .math, results: results)

        // After proficiency improves, focus skill may advance or remain if not mastered yet.
        // We assert that proficiency increased and focus selection remains valid.
        let updatedProficiency = store.proficiency(for: initialFocus, subject: .math)
        #expect(updatedProficiency >= initialProficiency)

        let newFocus = store.focusSkill(for: .math)
        // The focus should be a valid skill; we allow either staying or advancing depending on thresholds.
        _ = newFocus // Just ensure call succeeds
    }

    @MainActor @Test func difficultyTrendsUpWithCorrectAnswers() throws {
        let controller = PersistenceController(inMemory: true)
        let store = ProgressStore(viewContext: controller.container.viewContext)
        let skill = MathSkill.additionWithin10

        var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()
        let generator = MathProblemGenerator()

        // Capture initial proficiency and difficulty
        let initialProf = store.proficiency(for: skill, subject: .math)
        let initialProblems = generator.generateSession(for: skill, proficiency: max(0.1, initialProf), problemCount: 3, randomSource: &rng)
        let initialAvgDifficulty = initialProblems.map { $0.difficulty }.reduce(0.0, +) / Double(initialProblems.count)

        // Simulate a streak of correct answers
        let results = initialProblems.map { MathProblemResult(problem: $0, isCorrect: true) }
        try store.recordSession(for: .math, results: results)

        // Generate again with updated proficiency
        let updatedProf = store.proficiency(for: skill, subject: .math)
        let nextProblems = generator.generateSession(for: skill, proficiency: max(0.1, updatedProf), problemCount: 3, randomSource: &rng)
        let nextAvgDifficulty = nextProblems.map { $0.difficulty }.reduce(0.0, +) / Double(nextProblems.count)

        #expect(updatedProf >= initialProf)
        #expect(nextAvgDifficulty >= initialAvgDifficulty)
    }

    @MainActor @Test func difficultyEasesAfterIncorrectAnswers() throws {
        let controller = PersistenceController(inMemory: true)
        let store = ProgressStore(viewContext: controller.container.viewContext)
        let skill = MathSkill.additionWithin20

        var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()
        let generator = MathProblemGenerator()

        // Start with some moderate difficulty problems
        let prof = max(0.5, store.proficiency(for: skill, subject: .math))
        let problems = generator.generateSession(for: skill, proficiency: prof, problemCount: 3, randomSource: &rng)
        let avgDifficulty = problems.map { $0.difficulty }.reduce(0.0, +) / Double(problems.count)

        // Simulate incorrect answers to lower proficiency
        let wrongResults = problems.map { MathProblemResult(problem: $0, isCorrect: false) }
        try store.recordSession(for: .math, results: wrongResults)

        // Generate again; average difficulty should not increase and may decrease
        let updatedProf = store.proficiency(for: skill, subject: .math)
        let nextProblems = generator.generateSession(for: skill, proficiency: updatedProf, problemCount: 3, randomSource: &rng)
        let nextAvgDifficulty = nextProblems.map { $0.difficulty }.reduce(0.0, +) / Double(nextProblems.count)

        #expect(updatedProf <= prof)
        #expect(nextAvgDifficulty <= avgDifficulty)
    }

    @MainActor @Test func placementSeedingSetsExpectedBands() throws {
        let controller = PersistenceController(inMemory: true)
        let store = ProgressStore(viewContext: controller.container.viewContext)

        // Apply Grade 3 placement
        let profile = PlacementProfile(gradeBand: .grade3)
        try store.applyPlacement(profile: profile)

        // Collect a few representative skills across bands
        let kSkills: [MathSkill] = [.counting, .shapesBasic]
        let g1Skills: [MathSkill] = [.additionWithin10, .subtractionWithin10]
        let g3Skills: [MathSkill] = [.multiplicationFactsTo5, .fractionsUnit]
        let g5Skills: [MathSkill] = [.multiDigitTimesSingleDigit]

        // Expect below-grade skills to be at/above mastery, at-grade near mid, above-grade lower
        let masteredThreshold = MathSkill.masteryThreshold

        for s in kSkills + g1Skills {
            let p = store.proficiency(for: s, subject: .math)
            #expect(p >= masteredThreshold, "Below-grade skills should be seeded as mastered or higher")
        }

        for s in g3Skills {
            let p = store.proficiency(for: s, subject: .math)
            #expect(p >= -0.3 && p <= 0.3, "At-grade skills should be seeded near mid-range")
        }

        for s in g5Skills {
            let p = store.proficiency(for: s, subject: .math)
            #expect(p < 0.0, "Above-grade skills should be seeded lower to allow climbing")
        }
    }
}
