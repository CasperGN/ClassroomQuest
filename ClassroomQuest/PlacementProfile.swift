import Foundation

/// A profile defining initial proficiencies for a placement assessment,
/// organized by grade band and optional focus areas.
public struct PlacementProfile {
    /// The grade band this profile applies to (e.g., "K-2", "3-5", "6-8", "9-12").
    public let gradeBand: String
    
    /// Optional focus areas to tailor the proficiency profile (e.g., "Reading", "Math").
    public let focusAreas: [String]?
    
    /// A dictionary mapping proficiency categories to their initial proficiency values.
    /// The key is the proficiency category (e.g., "Phonics", "Algebra"), and the value is
    /// a Double representing the starting proficiency level (0.0 - 1.0).
    public let initialProficiencies: [String: Double]
    
    /// Initializes a new PlacementProfile with given grade band, optional focus areas,
    /// and initial proficiencies.
    /// - Parameters:
    ///   - gradeBand: The grade band the profile is for.
    ///   - focusAreas: Optional array of focus areas to customize the profile.
    ///   - initialProficiencies: Dictionary of proficiency categories and their initial values.
    public init(gradeBand: String,
                focusAreas: [String]? = nil,
                initialProficiencies: [String: Double] = [:]) {
        self.gradeBand = gradeBand
        self.focusAreas = focusAreas
        self.initialProficiencies = initialProficiencies
    }
    
    /// Returns a default placement profile for a given grade band.
    /// - Parameter gradeBand: The grade band to get the default profile for.
    /// - Returns: A PlacementProfile with default proficiencies.
    public static func defaultProfile(for gradeBand: String) -> PlacementProfile {
        switch gradeBand {
        case "K-2":
            return PlacementProfile(
                gradeBand: gradeBand,
                initialProficiencies: [
                    "Phonics": 0.2,
                    "SightWords": 0.3,
                    "Comprehension": 0.1
                ])
        case "3-5":
            return PlacementProfile(
                gradeBand: gradeBand,
                initialProficiencies: [
                    "Phonics": 0.5,
                    "Vocabulary": 0.4,
                    "Comprehension": 0.3
                ])
        case "6-8":
            return PlacementProfile(
                gradeBand: gradeBand,
                initialProficiencies: [
                    "Vocabulary": 0.6,
                    "Comprehension": 0.5,
                    "CriticalThinking": 0.4
                ])
        case "9-12":
            return PlacementProfile(
                gradeBand: gradeBand,
                initialProficiencies: [
                    "CriticalThinking": 0.7,
                    "Analysis": 0.6,
                    "Synthesis": 0.5
                ])
        default:
            return PlacementProfile(
                gradeBand: gradeBand,
                initialProficiencies: [:]
            )
        }
    }
}
