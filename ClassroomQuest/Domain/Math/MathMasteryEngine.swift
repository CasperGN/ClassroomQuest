import Foundation

struct MathMasteryEngine {
    // Mastery and spacing parameters
    let masteryThreshold: Double = MathSkill.masteryThreshold
    let spacingInterval: TimeInterval = 60 * 60 * 12 // 12 hours between focused reviews by default

    /// Determines if a skill is considered mastered given its proficiency.
    func isMastered(_ proficiency: Double) -> Bool {
        return proficiency >= masteryThreshold
    }

    /// Returns the next skill to focus on, respecting the learning path and mastery threshold.
    func nextFocusSkill(using proficiencyProvider: (MathSkill) -> Double) -> MathSkill {
        // Prefer the first skill whose prerequisites are mastered but which itself is not mastered.
        for skill in MathSkill.learningPath {
            let prereqs = skill.prerequisiteSkills
            let prereqsMastered = prereqs.allSatisfy { isMastered(proficiencyProvider($0)) }
            if prereqsMastered && !isMastered(proficiencyProvider(skill)) {
                return skill
            }
        }
        // If we reach here, either all skills are mastered or some prerequisites are not yet mastered.
        // Fallback: return the earliest skill in the path that is not mastered (even if its own prereqs are not mastered),
        // so the system can focus on building up foundations first.
        for skill in MathSkill.learningPath {
            if !isMastered(proficiencyProvider(skill)) {
                return skill
            }
        }
        return MathSkill.learningPath.last ?? .counting
    }

    /// Applies a simple Elo-style delta to a stored proficiency value.
    func updatedProficiency(from current: Double, correct: Bool, difficulty: Double, streak: Int) -> Double {
        // Base K-factor tuned for child-friendly pacing; boost slightly on streaks.
        let baseK: Double = 0.2
        let streakBoost: Double = streak >= 3 && correct ? 1.25 : 1.0
        let k = baseK * streakBoost

        // Sigmoid expectation: if current proficiency is below difficulty, expected success is lower.
        let expected = 1.0 / (1.0 + exp(-(current - difficulty)))
        let actual = correct ? 1.0 : 0.0

        // Apply update with gentle clipping to avoid large jumps.
        let updated = current + k * (actual - expected)
        return min(2.5, max(-2.5, updated))
    }

    /// Derives a target difficulty for the provided proficiency.
    func targetDifficulty(for proficiency: Double) -> Double {
        // Map -2.5...2.5 into 0...1.5 difficulty space with a smooth S-curve for responsiveness.
        let normalized = max(-2.5, min(2.5, proficiency))
        let t = (normalized + 2.5) / 5.0 // 0...1
        // Ease-in-out (smoothstep) to make difficulty ramp feel responsive but not spiky.
        let eased = t * t * (3 - 2 * t)
        return eased * 1.5
    }
}
