import SwiftUI

enum CQTheme {
    static let bluePrimary = Color("CQBluePrimary")
    static let yellowAccent = Color("CQYellowAccent")
    static let greenSecondary = Color("CQGreenSecondary")
    static let purpleLanguage = Color("CQPurpleLang")
    static let goldReligious = Color("CQGoldReligious")
    static let orangeWarning = Color(.systemOrange)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let cardBackground = Color(.secondarySystemBackground)
    static let background = Color(.systemGroupedBackground)
}

extension Font {
    static var cqTitle1: Font { .system(size: 34, weight: .semibold, design: .rounded) }
    static var cqTitle2: Font { .system(size: 28, weight: .semibold, design: .rounded) }
    static var cqBody1: Font { .system(size: 20, weight: .regular, design: .rounded) }
    static var cqBody2: Font { .system(size: 18, weight: .regular, design: .rounded) }
    static var cqButton: Font { .system(size: 22, weight: .semibold, design: .rounded) }
    static var cqCaption: Font { .system(size: 16, weight: .medium, design: .rounded) }
}

extension LinearGradient {
    static var cqSoftAdventure: LinearGradient {
        LinearGradient(
            colors: [CQTheme.bluePrimary.opacity(0.2), CQTheme.greenSecondary.opacity(0.25)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
