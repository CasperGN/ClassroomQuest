import Combine
import Foundation
import GameKit
import os
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class GameCenterManager: ObservableObject {
    enum AuthenticationState: Equatable {
        case idle
        case authenticating
        case authenticated
        case failed(String)
    }

    struct Guidance: Equatable {
        let message: String
        let documentationURL: URL?
    }

    @Published private(set) var authenticationState: AuthenticationState = .idle
    @Published private(set) var guidance: Guidance?

    private let logger = Logger(subsystem: "com.classroomquest.app", category: "GameCenter")
    private var pendingReports: [GameSessionReport] = []
    private var accessPointRequested = false

    func authenticate() {
        guard authenticationState != .authenticating else { return }

        if GKLocalPlayer.local.isAuthenticated {
            finalizeAuthenticationSuccess()
            return
        }

        authenticationState = .authenticating
        configureAccessPoint(isActive: false)

        guidance = nil

        if #available(iOS 17.0, *) {
            Task { [weak self] in
                guard let self else { return }
                await self.authenticateUsingAsyncAPI()
            }
        } else {
            authenticateUsingHandler()
        }
    }

    func recordSession(report: GameSessionReport) {
        if case .authenticated = authenticationState, GKLocalPlayer.local.isAuthenticated {
            Task { await submit(report: report) }
        } else {
            pendingReports.append(report)
            authenticate()
        }
    }

    func setAccessPointVisible(_ isVisible: Bool) {
        accessPointRequested = isVisible
        configureAccessPoint(isActive: GKLocalPlayer.local.isAuthenticated)
    }

    private func flushPendingReports() async {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        let reports = pendingReports
        pendingReports.removeAll()

        for report in reports {
            await submit(report: report)
        }
    }

    private func buildAchievements(for report: GameSessionReport) -> [GKAchievement] {
        var achievements: [GKAchievement] = []

        func configuredAchievement(_ identifier: GameCenterAchievement, progress: Double) -> GKAchievement {
            let achievement = GKAchievement(identifier: identifier.rawValue)
            achievement.percentComplete = min(100.0, progress * 100)
            achievement.showsCompletionBanner = true
            return achievement
        }

        if report.totalSessions > 0 {
            let progress = Double(report.totalSessions) / GameCenterAchievement.firstQuest.goal
            achievements.append(configuredAchievement(.firstQuest, progress: progress))
        }

        if report.totalSessions > 0 {
            let progress = Double(report.totalSessions) / GameCenterAchievement.tenQuests.goal
            achievements.append(configuredAchievement(.tenQuests, progress: progress))
        }

        if report.totalCorrectAnswers > 0 {
            let progress = Double(report.totalCorrectAnswers) / GameCenterAchievement.hundredCorrectAnswers.goal
            achievements.append(configuredAchievement(.hundredCorrectAnswers, progress: progress))
        }

        if !report.newMasteredSkills.isEmpty {
            achievements.append(configuredAchievement(.firstMastery, progress: 1.0))
        }

        return achievements
    }


    func retry() {
        guidance = nil
        authenticate()
    }

    @MainActor
    private func configureAccessPoint(isActive: Bool) {
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.isActive = isActive && accessPointRequested
    }

    @MainActor
    private func finalizeAuthenticationSuccess() {
        authenticationState = .authenticated
        guidance = nil
        configureAccessPoint(isActive: true)
        Task { [weak self] in
            guard let self else { return }
            await self.flushPendingReports()
        }
    }

    @available(iOS 17.0, *)
    private func authenticateUsingAsyncAPI() async {
        do {
            try await GKLocalPlayer.local.authenticateIfNeeded()
            await finalizeAuthenticationSuccess()
        } catch {
            await handleAuthenticationFailure(error)
        }
    }

    private func authenticateUsingHandler() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }

            if let viewController {
                self.presentAuthenticationViewController(viewController)
                return
            }

            Task { @MainActor in
                if let error {
                    await self.handleAuthenticationFailure(error)
                } else if GKLocalPlayer.local.isAuthenticated {
                    self.finalizeAuthenticationSuccess()
                } else {
                    self.authenticationState = .idle
                    self.configureAccessPoint(isActive: false)
                }
            }
        }
    }

#if canImport(UIKit)
    private func presentAuthenticationViewController(_ controller: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let root = window.rootViewController else {
            logger.error("Unable to find a window to present the Game Center sign-in sheet.")
            authenticationState = .failed("Unable to present sign-in UI.")
            configureAccessPoint(isActive: false)
            return
        }

        let presenter = topViewController(from: root) ?? root
        if presenter.presentedViewController == nil {
            presenter.present(controller, animated: true)
        }
    }

    private func topViewController(from root: UIViewController?) -> UIViewController? {
        if let navigation = root as? UINavigationController {
            return topViewController(from: navigation.visibleViewController)
        }

        if let tab = root as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }

        if let presented = root?.presentedViewController {
            return topViewController(from: presented)
        }

        return root
    }
#endif

    @MainActor
    private func handleAuthenticationFailure(_ error: Error) async {
        let message = userFacingMessage(for: error)
        logger.error("Game Center authentication failed: \(message, privacy: .public)")
        authenticationState = .failed(message)
        configureAccessPoint(isActive: false)

        let nsError = error as NSError
        if nsError.domain == GKErrorDomain, let code = GKError.Code(rawValue: nsError.code) {
            switch code {
            case .gameUnrecognized:
                guidance = Guidance(
                    message: String(localized: "Enable Game Center for this bundle in App Store Connect, then try again.", comment: "Guidance shown when the bundle is not enabled for Game Center."),
                    documentationURL: URL(string: "https://developer.apple.com/help/app-store-connect/configure-game-center/enable-an-app-version-for-game-center")
                )
            case .notAuthenticated:
                guidance = Guidance(
                    message: String(localized: "Sign in with a Sandbox Tester account under Settings › Game Center before testing achievements.", comment: "Guidance shown when the player must sign in."),
                    documentationURL: URL(string: "https://developer.apple.com/help/app-store-connect/test-in-app-purchases-in-the-sandbox/environment-setup#test-game-center")
                )
            case .notAuthorized, .underage:
                guidance = Guidance(
                    message: String(localized: "Screen Time or parental controls are preventing Game Center access on this device.", comment: "Guidance shown when the device is restricted."),
                    documentationURL: URL(string: "https://support.apple.com/en-us/HT201304")
                )
            default:
                break
            }
        }
    }

    private func userFacingMessage(for error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == GKErrorDomain, let code = GKError.Code(rawValue: nsError.code) {
            switch code {
            case .cancelled:
                return String(localized: "Sign-in was cancelled. You can try again from Settings.", comment: "Message shown when a parent cancels the Game Center sign-in flow.")
            case .notAuthenticated:
                return String(localized: "Please sign in to Game Center from Settings to enable achievements.", comment: "Message instructing the parent to sign in to Game Center.")
            case .gameUnrecognized:
                return String(localized: "Enable Game Center for this bundle in App Store Connect before testing achievements.", comment: "Message shown when the app bundle is not configured for Game Center.")
            case .notAuthorized, .underage:
                return String(localized: "Game Center is restricted on this device.", comment: "Message shown when Game Center restrictions are enabled.")
            default:
                break
            }
        }

        return error.localizedDescription
    }

    private func submit(report: GameSessionReport) async {
        let achievements = buildAchievements(for: report)

        if !achievements.isEmpty {
            do {
                try await GKAchievement.report(achievements)
            } catch {
                logger.error("Failed to report achievements: \(error.localizedDescription, privacy: .public)")
            }
        }

        guard report.subject == .math else { return }

        do {
            try await GKLeaderboard.submitScore(
                report.totalCorrectAnswers,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [GameCenterLeaderboard.totalCorrectAnswers.rawValue]
            )
        } catch {
            logger.error("Failed to report leaderboard score: \(error.localizedDescription, privacy: .public)")
        }
    }
}

extension GameCenterManager: GameCenterAchievementReporting {}

private enum GameCenterAchievement: String, CaseIterable {
    case firstQuest = "com.classroomquest.achievement.firstquest"
    case tenQuests = "com.classroomquest.achievement.tenquests"
    case hundredCorrectAnswers = "com.classroomquest.achievement.hundredcorrect"
    case firstMastery = "com.classroomquest.achievement.firstmastery"

    var goal: Double {
        switch self {
        case .firstQuest:
            return 1
        case .tenQuests:
            return 10
        case .hundredCorrectAnswers:
            return 100
        case .firstMastery:
            return 1
        }
    }
}

private enum GameCenterLeaderboard: String {
    case totalCorrectAnswers = "com.classroomquest.leaderboard.totalcorrect"
}
