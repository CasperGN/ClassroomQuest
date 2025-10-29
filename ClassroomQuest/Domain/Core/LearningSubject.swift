import Foundation

enum LearningSubject: String, CaseIterable, Identifiable {
    case math

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .math:
            return "Math"
        }
    }

    var iconSystemName: String {
        switch self {
        case .math:
            return "function"
        }
    }

    var accentColorHex: UInt32 {
        switch self {
        case .math:
            return 0x4E6EFA
        }
    }
}
