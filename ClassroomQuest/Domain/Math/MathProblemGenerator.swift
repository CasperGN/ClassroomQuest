import Foundation

struct MathProblemGenerator {
    let masteryEngine: MathMasteryEngine

    init(masteryEngine: MathMasteryEngine = MathMasteryEngine()) {
        self.masteryEngine = masteryEngine
    }

    func generateProblem(for skill: MathSkill, proficiency: Double, randomSource: inout RandomNumberGenerator) -> MathProblem {
        let targetDifficulty = masteryEngine.targetDifficulty(for: proficiency)
        let clampedDifficulty = min(skill.difficultyBounds.upperBound, max(skill.difficultyBounds.lowerBound, targetDifficulty))
        switch skill {
        case .counting:
            let a = Int.random(in: 1...5, using: &randomSource)
            let b = Int.random(in: 1...4, using: &randomSource)
            return MathProblem(prompt: "\(a) + \(b) = ?", correctAnswer: a + b, skill: skill, difficulty: clampedDifficulty)
        case .additionWithin10:
            let range = range(forBase: 5, difficulty: clampedDifficulty, upperBound: 10)
            let a = Int.random(in: 1...range, using: &randomSource)
            let b = Int.random(in: 0...max(1, range - a), using: &randomSource)
            return MathProblem(prompt: "\(a) + \(b) = ?", correctAnswer: a + b, skill: skill, difficulty: clampedDifficulty)
        case .additionWithin20:
            let range = range(forBase: 10, difficulty: clampedDifficulty, upperBound: 20)
            let a = Int.random(in: 5...range, using: &randomSource)
            let b = Int.random(in: 1...max(5, range - a + 5), using: &randomSource)
            let sum = a + b
            return MathProblem(prompt: "\(a) + \(b) = ?", correctAnswer: sum, skill: skill, difficulty: clampedDifficulty)
        case .subtractionWithin20:
            let range = range(forBase: 12, difficulty: clampedDifficulty, upperBound: 20)
            let a = Int.random(in: 6...range, using: &randomSource)
            let b = Int.random(in: 1...a, using: &randomSource)
            return MathProblem(prompt: "\(a) − \(b) = ?", correctAnswer: a - b, skill: skill, difficulty: clampedDifficulty)
        case .multiplicationFactsTo5:
            let multiplier = Int.random(in: 2...5, using: &randomSource)
            let range = max(3, Int(round(3 + clampedDifficulty * 3)))
            let multiplicand = Int.random(in: 2...range, using: &randomSource)
            return MathProblem(prompt: "\(multiplier) × \(multiplicand) = ?", correctAnswer: multiplier * multiplicand, skill: skill, difficulty: clampedDifficulty)
        }
    }

    func generateSession(for skill: MathSkill, proficiency: Double, problemCount: Int = 5, randomSource: inout RandomNumberGenerator) -> [MathProblem] {
        (0..<problemCount).reduce(into: [MathProblem]()) { acc, _ in
            var attempts = 0
            var next: MathProblem
            repeat {
                next = generateProblem(for: skill, proficiency: proficiency, randomSource: &randomSource)
                attempts += 1
                // Cap retries to avoid infinite loops in extreme edge cases
                if attempts > 10 { break }
            } while acc.contains(where: { $0.prompt == next.prompt })
            acc.append(next)
        }
    }

    private func range(forBase base: Int, difficulty: Double, upperBound: Int) -> Int {
        let adjustable = Double(upperBound - base)
        let value = Double(base) + adjustable * difficulty
        return min(upperBound, Swift.max(base, Int(round(value))))
    }
}

