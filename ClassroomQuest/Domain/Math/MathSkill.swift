import Foundation

enum MathSkill: String, CaseIterable, Identifiable {
    case counting
    case additionWithin10
    case additionWithin20
    case subtractionWithin20
    case multiplicationWithin5

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .counting:
            return "Counting"
        case .additionWithin10:
            return "Addition to 10"
        case .additionWithin20:
            return "Addition to 20"
        case .subtractionWithin20:
            return "Subtraction to 20"
        case .multiplicationWithin5:
            return "Multiplication by 5"
        }
    }

    var description: String {
        switch self {
        case .counting:
            return "Count objects and identify totals."
        case .additionWithin10:
            return "Add two numbers with sums up to 10."
        case .additionWithin20:
            return "Add two numbers with sums up to 20."
        case .subtractionWithin20:
            return "Subtract within 20, no negatives."
        case .multiplicationWithin5:
            return "Multiply numbers up to five."
        }
    }

    var prerequisite: MathSkill? {
        switch self {
        case .counting:
            return nil
        case .additionWithin10:
            return .counting
        case .additionWithin20:
            return .additionWithin10
        case .subtractionWithin20:
            return .additionWithin20
        case .multiplicationWithin5:
            return .subtractionWithin20
        }
    }

    static var learningPath: [MathSkill] {
        [.counting, .additionWithin10, .additionWithin20, .subtractionWithin20, .multiplicationWithin5]
    }

    static let masteryThreshold: Double = 1.0
}
