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

    @Published private(set) var authenticationState: AuthenticationState = .idle

    private let logger = Logger(subsystem: "com.classroomquest.app", category: "GameCenter")
    private var pendingReports: [GameSessionReport] = []
    private var accessPointRequested = false

    func authenticate() {
        guard authenticationState != .authenticating else { return }

        if GKLocalPlayer.local.isAuthenticated {
            authenticationState = .authenticated
            configureAccessPoint(isActive: true)
            Task { [weak self] in
                guard let self else { return }
                await self.flushPendingReports()
            }
            return
        }

        authenticationState = .authenticating
        configureAccessPoint(isActive: false)

        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }

            if let viewController {
                self.presentAuthenticationViewController(viewController)
                return
            }

            if let error {
                let nsError = error as NSError
                if nsError.domain == GKErrorDomain,
                   nsError.code == GKError.Code.gameUnrecognized.rawValue {
                    self.logger.error("Game Center authentication failed because the bundle is not enabled on App Store Connect. Enable Game Center for this app before testing achievements.")
                }

                let message = self.userFacingMessage(for: error)
                self.logger.error("Game Center authentication failed: \(message, privacy: .public)")
                self.authenticationState = .failed(message)
                self.configureAccessPoint(isActive: false)
                return
            }

            guard GKLocalPlayer.local.isAuthenticated else {
                self.authenticationState = .idle
                self.configureAccessPoint(isActive: false)
                return
            }

            self.authenticationState = .authenticated
            self.configureAccessPoint(isActive: true)
            Task { [weak self] in
                guard let self else { return }
                await self.flushPendingReports()
            }
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

    private func configureAccessPoint(isActive: Bool) {
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.isActive = isActive && accessPointRequested
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
