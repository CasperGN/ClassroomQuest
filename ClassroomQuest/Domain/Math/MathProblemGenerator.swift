import Foundation

struct MathProblemGenerator {
    let masteryEngine: MathMasteryEngine

    init(masteryEngine: MathMasteryEngine = MathMasteryEngine()) {
        self.masteryEngine = masteryEngine
    }

    func generateProblem(for skill: MathSkill, proficiency: Double, randomSource: inout RandomNumberGenerator) -> MathProblem {
        let targetDifficulty = masteryEngine.targetDifficulty(for: proficiency)
        switch skill {
        case .counting:
            let count = Int.random(in: 3...9, using: &randomSource)
            return MathProblem(prompt: "How many stars do you count? \(count)", correctAnswer: count, skill: skill, difficulty: targetDifficulty)
        case .additionWithin10:
            let range = range(forBase: 5, difficulty: targetDifficulty, max: 10)
            let a = Int.random(in: 1...range, using: &randomSource)
            let b = Int.random(in: 0...max(1, range - a), using: &randomSource)
            return MathProblem(prompt: "\(a) + \(b) = ?", correctAnswer: a + b, skill: skill, difficulty: targetDifficulty)
        case .additionWithin20:
            let range = range(forBase: 10, difficulty: targetDifficulty, max: 20)
            let a = Int.random(in: 5...range, using: &randomSource)
            let b = Int.random(in: 1...max(5, range - a + 5), using: &randomSource)
            let sum = a + b
            return MathProblem(prompt: "\(a) + \(b) = ?", correctAnswer: sum, skill: skill, difficulty: targetDifficulty)
        case .subtractionWithin20:
            let range = range(forBase: 12, difficulty: targetDifficulty, max: 20)
            let a = Int.random(in: 6...range, using: &randomSource)
            let b = Int.random(in: 1...a, using: &randomSource)
            return MathProblem(prompt: "\(a) − \(b) = ?", correctAnswer: a - b, skill: skill, difficulty: targetDifficulty)
        case .multiplicationWithin5:
            let multiplier = Int.random(in: 2...5, using: &randomSource)
            let range = max(3, Int(round(3 + targetDifficulty * 3)))
            let multiplicand = Int.random(in: 2...range, using: &randomSource)
            return MathProblem(prompt: "\(multiplier) × \(multiplicand) = ?", correctAnswer: multiplier * multiplicand, skill: skill, difficulty: targetDifficulty)
        }
    }

    func generateSession(for skill: MathSkill, proficiency: Double, problemCount: Int = 5, randomSource: inout RandomNumberGenerator) -> [MathProblem] {
        (0..<problemCount).map { _ in
            generateProblem(for: skill, proficiency: proficiency, randomSource: &randomSource)
        }
    }

    private func range(forBase base: Int, difficulty: Double, max: Int) -> Int {
        let adjustable = Double(max - base)
        let value = Double(base) + adjustable * difficulty
        return min(max, max(base, Int(round(value))))
    }
}
