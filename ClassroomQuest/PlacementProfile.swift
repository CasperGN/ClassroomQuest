import Foundation

/// Describes an initial placement configuration for a learner.
/// This is used to seed proficiencies in the adaptive engine so that
/// early sessions start at an appropriate difficulty.
struct PlacementProfile: Equatable {
    /// The grade band selected during placement.
    let gradeBand: GradeBand
    /// Optional math skills to emphasize immediately after placement.
    let focusSkills: Set<MathSkill>

    init(gradeBand: GradeBand, focusSkills: Set<MathSkill> = []) {
        self.gradeBand = gradeBand
        self.focusSkills = focusSkills
    }
}
