import Foundation

enum GradeBand: String, CaseIterable, Identifiable {
    case kindergarten, grade1, grade2, grade3, grade4, grade5
    var id: String { rawValue }
}

enum MathSkill: String, CaseIterable, Identifiable {
    // Early Number Sense
    case counting
    case numberComparison
    case placeValueTensOnes

    // Addition
    case additionWithin10
    case additionWithin20
    case additionWithRegrouping
    case multiDigitAddition

    // Subtraction
    case subtractionWithin10
    case subtractionWithin20
    case subtractionWithRegrouping
    case multiDigitSubtraction

    // Multiplication
    case multiplicationFactsTo5
    case multiplicationFactsTo10
    case multiDigitTimesSingleDigit

    // Division
    case divisionFactsTo5
    case divisionFactsTo10
    case singleDigitDivisionWithRemainder

    // Fractions
    case fractionsUnit
    case fractionsEquivalent
    case fractionsCompareLikeDenominators
    case fractionsAddSubtractLikeDenominators

    // Measurement & Geometry (lightweight starters for K–5)
    case timeReadHourHalf
    case moneyCoinValues
    case shapesBasic
    case areaPerimeterRectangles

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .counting: return "Counting"
        case .numberComparison: return "Compare Numbers"
        case .placeValueTensOnes: return "Place Value (Tens/Ones)"
        case .additionWithin10: return "Addition to 10"
        case .additionWithin20: return "Addition to 20"
        case .additionWithRegrouping: return "Addition (Regrouping)"
        case .multiDigitAddition: return "Multi-digit Addition"
        case .subtractionWithin10: return "Subtraction to 10"
        case .subtractionWithin20: return "Subtraction to 20"
        case .subtractionWithRegrouping: return "Subtraction (Regrouping)"
        case .multiDigitSubtraction: return "Multi-digit Subtraction"
        case .multiplicationFactsTo5: return "Multiplication Facts ×5"
        case .multiplicationFactsTo10: return "Multiplication Facts ×10"
        case .multiDigitTimesSingleDigit: return "Multi-digit × Single-digit"
        case .divisionFactsTo5: return "Division Facts ÷5"
        case .divisionFactsTo10: return "Division Facts ÷10"
        case .singleDigitDivisionWithRemainder: return "Division w/ Remainder"
        case .fractionsUnit: return "Unit Fractions"
        case .fractionsEquivalent: return "Equivalent Fractions"
        case .fractionsCompareLikeDenominators: return "Compare Fractions (Like Denoms)"
        case .fractionsAddSubtractLikeDenominators: return "Add/Sub Fractions (Like Denoms)"
        case .timeReadHourHalf: return "Read Time (Hour/Half)"
        case .moneyCoinValues: return "Money: Coin Values"
        case .shapesBasic: return "Basic Shapes"
        case .areaPerimeterRectangles: return "Area/Perimeter (Rectangles)"
        }
    }

    var description: String {
        switch self {
        case .counting: return "Count objects and identify totals."
        case .numberComparison: return "Compare numbers using <, >, =."
        case .placeValueTensOnes: return "Understand tens and ones."
        case .additionWithin10: return "Add two numbers with sums up to 10."
        case .additionWithin20: return "Add two numbers with sums up to 20."
        case .additionWithRegrouping: return "Add with regrouping (carrying)."
        case .multiDigitAddition: return "Add multi-digit numbers."
        case .subtractionWithin10: return "Subtract within 10, no negatives."
        case .subtractionWithin20: return "Subtract within 20, no negatives."
        case .subtractionWithRegrouping: return "Subtract with regrouping (borrowing)."
        case .multiDigitSubtraction: return "Subtract multi-digit numbers."
        case .multiplicationFactsTo5: return "Multiply numbers with factors up to 5."
        case .multiplicationFactsTo10: return "Multiply numbers with factors up to 10."
        case .multiDigitTimesSingleDigit: return "Multiply multi-digit by single-digit."
        case .divisionFactsTo5: return "Divide numbers with divisors up to 5."
        case .divisionFactsTo10: return "Divide numbers with divisors up to 10."
        case .singleDigitDivisionWithRemainder: return "Divide with remainders."
        case .fractionsUnit: return "Understand unit fractions (1/n)."
        case .fractionsEquivalent: return "Find equivalent fractions."
        case .fractionsCompareLikeDenominators: return "Compare fractions with like denominators."
        case .fractionsAddSubtractLikeDenominators: return "Add/subtract fractions with like denominators."
        case .timeReadHourHalf: return "Read analog clocks to hour/half-hour."
        case .moneyCoinValues: return "Identify coin values and simple sums."
        case .shapesBasic: return "Recognize and name basic shapes."
        case .areaPerimeterRectangles: return "Compute area/perimeter of rectangles."
        }
    }

    var prerequisiteSkills: [MathSkill] {
        switch self {
        case .counting: return []
        case .numberComparison: return [.counting]
        case .placeValueTensOnes: return [.numberComparison]

        case .additionWithin10: return [.counting]
        case .additionWithin20: return [.additionWithin10]
        case .additionWithRegrouping: return [.additionWithin20, .placeValueTensOnes]
        case .multiDigitAddition: return [.additionWithRegrouping]

        case .subtractionWithin10: return [.counting]
        case .subtractionWithin20: return [.subtractionWithin10]
        case .subtractionWithRegrouping: return [.subtractionWithin20, .placeValueTensOnes]
        case .multiDigitSubtraction: return [.subtractionWithRegrouping]

        case .multiplicationFactsTo5: return [.additionWithin20]
        case .multiplicationFactsTo10: return [.multiplicationFactsTo5]
        case .multiDigitTimesSingleDigit: return [.multiplicationFactsTo10, .placeValueTensOnes]

        case .divisionFactsTo5: return [.multiplicationFactsTo5]
        case .divisionFactsTo10: return [.divisionFactsTo5]
        case .singleDigitDivisionWithRemainder: return [.divisionFactsTo10]

        case .fractionsUnit: return [.numberComparison]
        case .fractionsEquivalent: return [.fractionsUnit]
        case .fractionsCompareLikeDenominators: return [.fractionsUnit]
        case .fractionsAddSubtractLikeDenominators: return [.fractionsEquivalent]

        case .timeReadHourHalf: return [.numberComparison]
        case .moneyCoinValues: return [.additionWithin10]
        case .shapesBasic: return []
        case .areaPerimeterRectangles: return [.additionWithin20]
        }
    }

    // Bounds for difficulty mapping (0...1.5 overall); tighter for early skills, broader for advanced.
    var difficultyBounds: ClosedRange<Double> {
        switch self {
        case .counting, .numberComparison, .shapesBasic, .timeReadHourHalf:
            return 0.0...0.6
        case .placeValueTensOnes, .additionWithin10, .subtractionWithin10, .moneyCoinValues:
            return 0.0...0.8
        case .additionWithin20, .subtractionWithin20, .multiplicationFactsTo5, .divisionFactsTo5, .fractionsUnit:
            return 0.2...1.0
        case .additionWithRegrouping, .subtractionWithRegrouping, .multiplicationFactsTo10, .divisionFactsTo10, .fractionsEquivalent, .fractionsCompareLikeDenominators:
            return 0.4...1.2
        case .multiDigitAddition, .multiDigitSubtraction, .multiDigitTimesSingleDigit, .singleDigitDivisionWithRemainder, .fractionsAddSubtractLikeDenominators, .areaPerimeterRectangles:
            return 0.6...1.5
        }
    }

    var gradeBand: GradeBand {
        switch self {
        case .counting, .numberComparison, .shapesBasic, .timeReadHourHalf:
            return .kindergarten
        case .placeValueTensOnes, .additionWithin10, .subtractionWithin10, .moneyCoinValues:
            return .grade1
        case .additionWithin20, .subtractionWithin20, .additionWithRegrouping, .subtractionWithRegrouping:
            return .grade2
        case .multiplicationFactsTo5, .divisionFactsTo5, .fractionsUnit, .areaPerimeterRectangles:
            return .grade3
        case .multiplicationFactsTo10, .divisionFactsTo10, .fractionsEquivalent, .fractionsCompareLikeDenominators, .multiDigitAddition, .multiDigitSubtraction:
            return .grade4
        case .multiDigitTimesSingleDigit, .singleDigitDivisionWithRemainder, .fractionsAddSubtractLikeDenominators:
            return .grade5
        }
    }

    static var learningPath: [MathSkill] {
        return [
            // Foundations
            .counting, .numberComparison, .placeValueTensOnes,
            // Addition/Subtraction basics
            .additionWithin10, .subtractionWithin10,
            .additionWithin20, .subtractionWithin20,
            .additionWithRegrouping, .subtractionWithRegrouping,
            .multiDigitAddition, .multiDigitSubtraction,
            // Multiplication/Division
            .multiplicationFactsTo5, .divisionFactsTo5,
            .multiplicationFactsTo10, .divisionFactsTo10,
            .multiDigitTimesSingleDigit, .singleDigitDivisionWithRemainder,
            // Fractions
            .fractionsUnit, .fractionsEquivalent,
            .fractionsCompareLikeDenominators, .fractionsAddSubtractLikeDenominators,
            // Measurement/Geometry samplers
            .timeReadHourHalf, .moneyCoinValues, .shapesBasic, .areaPerimeterRectangles
        ]
    }

    static let masteryThreshold: Double = 1.0
}
