import SwiftUI

extension CurriculumSubject {
    var accentColor: Color {
        switch self {
        case .math:
            return Color(red: 0.35, green: 0.63, blue: 1.0)
        case .language:
            return Color(red: 0.96, green: 0.52, blue: 0.64)
        case .science:
            return Color(red: 0.32, green: 0.75, blue: 0.53)
        case .socialStudies:
            return Color(red: 0.94, green: 0.74, blue: 0.36)
        }
    }
}
