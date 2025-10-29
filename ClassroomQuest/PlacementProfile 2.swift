import Foundation

/// NOTE: Renamed to avoid duplicate declaration with existing PlacementProfile.
/// Describes an initial placement for the learner.
/// Use this to seed proficiencies so the adaptive engine can quickly find the appropriate level.
struct InitialPlacementProfile: Equatable {
    /// Target grade band for initial placement.
    let gradeBand: GradeBand
    /// Optional focus areas (families) to emphasize. For now this is a hint; future use can prioritize selection.
    let focusSkills: Set<MathSkill>

    init(gradeBand: GradeBand, focusSkills: Set<MathSkill> = []) {
        self.gradeBand = gradeBand
        self.focusSkills = focusSkills
    }
}
