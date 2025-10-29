import Foundation

struct MathProblem: Identifiable, Equatable, Hashable {
    let id: UUID
    let prompt: String
    let correctAnswer: Int
    let skill: MathSkill
    let difficulty: Double

    init(id: UUID = UUID(), prompt: String, correctAnswer: Int, skill: MathSkill, difficulty: Double) {
        self.id = id
        self.prompt = prompt
        self.correctAnswer = correctAnswer
        self.skill = skill
        self.difficulty = difficulty
    }
}

struct MathProblemResult {
    let problem: MathProblem
    let isCorrect: Bool
}
