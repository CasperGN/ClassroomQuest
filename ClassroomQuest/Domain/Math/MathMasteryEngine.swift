import Foundation

struct MathMasteryEngine {
    /// Returns the next skill to focus on, respecting the learning path and mastery threshold.
    func nextFocusSkill(using proficiencyProvider: (MathSkill) -> Double) -> MathSkill {
        for skill in MathSkill.learningPath {
            let proficiency = proficiencyProvider(skill)
            if proficiency < MathSkill.masteryThreshold {
                return skill
            }
        }
        return MathSkill.learningPath.last ?? .counting
    }

    /// Applies a simple Elo-style delta to a stored proficiency value.
    func updatedProficiency(from current: Double, correct: Bool, difficulty: Double) -> Double {
        // K-factor tuned for child-friendly pacing.
        let k: Double = 0.2
        let expected = 1.0 / (1.0 + exp(-(current - difficulty)))
        let actual = correct ? 1.0 : 0.0
        return min(2.5, max(-2.5, current + k * (actual - expected)))
    }

    /// Derives a target difficulty for the provided proficiency.
    func targetDifficulty(for proficiency: Double) -> Double {
        // Map -2.5...2.5 into 0...1.5 difficulty space.
        return (proficiency + 2.5) / 5.0 * 1.5
    }
}
