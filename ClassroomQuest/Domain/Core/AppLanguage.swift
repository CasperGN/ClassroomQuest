import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            return String(localized: "English")
        case .spanish:
            return String(localized: "Spanish")
        case .french:
            return String(localized: "French")
        }
    }

    var localeIdentifier: String { rawValue }

    static func from(identifier: String) -> AppLanguage {
        AppLanguage(rawValue: identifier)
            ?? .english
    }
}
