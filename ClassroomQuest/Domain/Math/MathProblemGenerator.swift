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
        case .numberComparison:
            let upper = max(5, Int(round(10 + clampedDifficulty * 40)))
            var a = Int.random(in: 0...upper, using: &randomSource)
            var b = Int.random(in: 0...upper, using: &randomSource)
            while a == b {
                a = Int.random(in: 0...upper, using: &randomSource)
                b = Int.random(in: 0...upper, using: &randomSource)
            }
            let prompt = "Which number is greater? Enter the larger number: \(a) or \(b)"
            return MathProblem(prompt: prompt, correctAnswer: max(a, b), skill: skill, difficulty: clampedDifficulty)
        case .placeValueTensOnes:
            let tens = Int.random(in: 1...max(3, Int(round(3 + clampedDifficulty * 6))), using: &randomSource)
            let ones = Int.random(in: 0...9, using: &randomSource)
            let value = tens * 10 + ones
            let prompt = "What number is \(tens) tens and \(ones) ones?"
            return MathProblem(prompt: prompt, correctAnswer: value, skill: skill, difficulty: clampedDifficulty)
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
        case .additionWithRegrouping:
            let upper = max(20, Int(round(30 + clampedDifficulty * 70)))
            var a = Int.random(in: 10...upper, using: &randomSource)
            var b = Int.random(in: 10...upper, using: &randomSource)
            while (a % 10) + (b % 10) < 10 {
                a = Int.random(in: 10...upper, using: &randomSource)
                b = Int.random(in: 10...upper, using: &randomSource)
            }
            return MathProblem(prompt: "\(a) + \(b) = ?", correctAnswer: a + b, skill: skill, difficulty: clampedDifficulty)
        case .multiDigitAddition:
            let upper = max(100, Int(round(150 + clampedDifficulty * 350)))
            let a = Int.random(in: 50...upper, using: &randomSource)
            let b = Int.random(in: 25...upper, using: &randomSource)
            return MathProblem(prompt: "\(a) + \(b) = ?", correctAnswer: a + b, skill: skill, difficulty: clampedDifficulty)
        case .subtractionWithin20:
            let range = range(forBase: 12, difficulty: clampedDifficulty, upperBound: 20)
            let a = Int.random(in: 6...range, using: &randomSource)
            let b = Int.random(in: 1...a, using: &randomSource)
            return MathProblem(prompt: "\(a) − \(b) = ?", correctAnswer: a - b, skill: skill, difficulty: clampedDifficulty)
        case .subtractionWithin10:
            let range = range(forBase: 6, difficulty: clampedDifficulty, upperBound: 10)
            let a = Int.random(in: 2...range, using: &randomSource)
            let b = Int.random(in: 0...a, using: &randomSource)
            return MathProblem(prompt: "\(a) − \(b) = ?", correctAnswer: a - b, skill: skill, difficulty: clampedDifficulty)
        case .subtractionWithRegrouping:
            let upper = max(20, Int(round(30 + clampedDifficulty * 70)))
            var minuend = Int.random(in: 20...upper + 30, using: &randomSource)
            var subtrahend = Int.random(in: 10...upper, using: &randomSource)
            while minuend % 10 >= subtrahend % 10 {
                minuend = Int.random(in: 20...upper + 30, using: &randomSource)
                subtrahend = Int.random(in: 10...upper, using: &randomSource)
            }
            return MathProblem(prompt: "\(minuend) − \(subtrahend) = ?", correctAnswer: minuend - subtrahend, skill: skill, difficulty: clampedDifficulty)
        case .multiDigitSubtraction:
            let upper = max(200, Int(round(250 + clampedDifficulty * 500)))
            let minuend = Int.random(in: 150...upper, using: &randomSource)
            let subtrahend = Int.random(in: 50...minuend, using: &randomSource)
            return MathProblem(prompt: "\(minuend) − \(subtrahend) = ?", correctAnswer: minuend - subtrahend, skill: skill, difficulty: clampedDifficulty)
        case .multiplicationFactsTo5:
            let multiplier = Int.random(in: 2...5, using: &randomSource)
            let range = max(3, Int(round(3 + clampedDifficulty * 3)))
            let multiplicand = Int.random(in: 2...range, using: &randomSource)
            return MathProblem(prompt: "\(multiplier) × \(multiplicand) = ?", correctAnswer: multiplier * multiplicand, skill: skill, difficulty: clampedDifficulty)
        case .multiplicationFactsTo10:
            let multiplier = Int.random(in: 2...10, using: &randomSource)
            let multiplicand = Int.random(in: 2...10, using: &randomSource)
            return MathProblem(prompt: "\(multiplier) × \(multiplicand) = ?", correctAnswer: multiplier * multiplicand, skill: skill, difficulty: clampedDifficulty)
        case .multiDigitTimesSingleDigit:
            let base = Int(round(50 + clampedDifficulty * 450))
            let multiplicand = Int.random(in: 20...max(50, base), using: &randomSource)
            let multiplier = Int.random(in: 3...9, using: &randomSource)
            return MathProblem(prompt: "\(multiplicand) × \(multiplier) = ?", correctAnswer: multiplicand * multiplier, skill: skill, difficulty: clampedDifficulty)
        case .divisionFactsTo5:
            let divisor = Int.random(in: 2...5, using: &randomSource)
            let quotient = Int.random(in: 2...10, using: &randomSource)
            let dividend = divisor * quotient
            return MathProblem(prompt: "\(dividend) ÷ \(divisor) = ?", correctAnswer: quotient, skill: skill, difficulty: clampedDifficulty)
        case .divisionFactsTo10:
            let divisor = Int.random(in: 2...10, using: &randomSource)
            let quotient = Int.random(in: 2...12, using: &randomSource)
            let dividend = divisor * quotient
            return MathProblem(prompt: "\(dividend) ÷ \(divisor) = ?", correctAnswer: quotient, skill: skill, difficulty: clampedDifficulty)
        case .singleDigitDivisionWithRemainder:
            let divisor = Int.random(in: 3...9, using: &randomSource)
            let quotient = Int.random(in: 2...12, using: &randomSource)
            let remainder = Int.random(in: 1..<(divisor), using: &randomSource)
            let dividend = divisor * quotient + remainder
            let prompt = "What is the remainder when \(dividend) is divided by \(divisor)?"
            return MathProblem(prompt: prompt, correctAnswer: remainder, skill: skill, difficulty: clampedDifficulty)
        case .fractionsUnit:
            let denominator = Int.random(in: 2...8, using: &randomSource)
            let prompt = "How many 1/\(denominator) unit fractions make a whole?"
            return MathProblem(prompt: prompt, correctAnswer: denominator, skill: skill, difficulty: clampedDifficulty)
        case .fractionsEquivalent:
            let denominator = Int.random(in: 2...8, using: &randomSource)
            let numerator = Int.random(in: 1..<(denominator), using: &randomSource)
            let factor = Int.random(in: 2...4, using: &randomSource)
            let prompt = "Fill in the blank: \(numerator)/\(denominator) = ?/\(denominator * factor)"
            return MathProblem(prompt: prompt, correctAnswer: numerator * factor, skill: skill, difficulty: clampedDifficulty)
        case .fractionsCompareLikeDenominators:
            let denominator = Int.random(in: 3...10, using: &randomSource)
            var first = Int.random(in: 1..<(denominator), using: &randomSource)
            var second = Int.random(in: 1..<(denominator), using: &randomSource)
            while first == second {
                first = Int.random(in: 1..<(denominator), using: &randomSource)
                second = Int.random(in: 1..<(denominator), using: &randomSource)
            }
            let correct = first > second ? 1 : 2
            let prompt = "Which fraction is greater? Enter 1 for \(first)/\(denominator), 2 for \(second)/\(denominator)."
            return MathProblem(prompt: prompt, correctAnswer: correct, skill: skill, difficulty: clampedDifficulty)
        case .fractionsAddSubtractLikeDenominators:
            let denominator = Int.random(in: 4...12, using: &randomSource)
            let first = Int.random(in: 1..<(denominator), using: &randomSource)
            let second = Int.random(in: 1...(denominator - first), using: &randomSource)
            let prompt = "What is \(first)/\(denominator) + \(second)/\(denominator)? Give the numerator of the answer."
            return MathProblem(prompt: prompt, correctAnswer: first + second, skill: skill, difficulty: clampedDifficulty)
        case .timeReadHourHalf:
            let hour = Int.random(in: 1...12, using: &randomSource)
            let halfHour = Bool.random(using: &randomSource)
            if halfHour {
                let prompt = "If the clock reads \(hour):30, what hour number does it show?"
                return MathProblem(prompt: prompt, correctAnswer: hour, skill: skill, difficulty: clampedDifficulty)
            } else {
                let prompt = "If the clock reads \(hour):00, what hour number does it show?"
                return MathProblem(prompt: prompt, correctAnswer: hour, skill: skill, difficulty: clampedDifficulty)
            }
        case .moneyCoinValues:
            let quarters = Int.random(in: 0...Int(round(clampedDifficulty * 3)) + 1, using: &randomSource)
            let dimes = Int.random(in: 0...Int(round(clampedDifficulty * 4)) + 2, using: &randomSource)
            let nickels = Int.random(in: 0...3, using: &randomSource)
            let pennies = Int.random(in: 0...4, using: &randomSource)
            let total = quarters * 25 + dimes * 10 + nickels * 5 + pennies
            let prompt = "What is the total value in cents of \(quarters) quarters, \(dimes) dimes, \(nickels) nickels, and \(pennies) pennies?"
            return MathProblem(prompt: prompt, correctAnswer: total, skill: skill, difficulty: clampedDifficulty)
        case .shapesBasic:
            let shapes = ["triangle": 3, "square": 4, "rectangle": 4, "pentagon": 5, "hexagon": 6]
            let choice = shapes.randomElement(using: &randomSource)!
            let prompt = "How many sides does a \(choice.key) have?"
            return MathProblem(prompt: prompt, correctAnswer: choice.value, skill: skill, difficulty: clampedDifficulty)
        case .areaPerimeterRectangles:
            let length = Int.random(in: 2...Int(round(4 + clampedDifficulty * 6)), using: &randomSource)
            let width = Int.random(in: 2...Int(round(4 + clampedDifficulty * 6)), using: &randomSource)
            if Bool.random(using: &randomSource) {
                let prompt = "What is the area of a rectangle with length \(length) and width \(width)?"
                return MathProblem(prompt: prompt, correctAnswer: length * width, skill: skill, difficulty: clampedDifficulty)
            } else {
                let prompt = "What is the perimeter of a rectangle with length \(length) and width \(width)?"
                return MathProblem(prompt: prompt, correctAnswer: 2 * (length + width), skill: skill, difficulty: clampedDifficulty)
            }
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

