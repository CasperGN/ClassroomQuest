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
        authenticationState = .authenticating
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }
            if let viewController {
                self.presentAuthenticationController(viewController)
                return
            }

            if GKLocalPlayer.local.isAuthenticated {
                self.authenticationState = .authenticated
                self.configureAccessPoint(isActive: true)
                self.flushPendingReports()
            } else if let error {
                self.logger.error("Game Center authentication failed: \(error.localizedDescription, privacy: .public)")
                self.authenticationState = .failed(error.localizedDescription)
                self.configureAccessPoint(isActive: false)
            } else {
                self.authenticationState = .idle
                self.configureAccessPoint(isActive: false)
            }
        }
    }

    func recordSession(report: GameSessionReport) {
        if case .authenticated = authenticationState, GKLocalPlayer.local.isAuthenticated {
            submit(report: report)
        } else {
            pendingReports.append(report)
            if authenticationState == .idle {
                authenticate()
            }
        }
    }

    func setAccessPointVisible(_ isVisible: Bool) {
        accessPointRequested = isVisible
        configureAccessPoint(isActive: GKLocalPlayer.local.isAuthenticated)
    }

    private func flushPendingReports() {
        guard case .authenticated = authenticationState else { return }
        let reports = pendingReports
        pendingReports.removeAll()
        for report in reports {
            submit(report: report)
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

    private func buildLeaderboardEntries(for report: GameSessionReport) -> [GKScore] {
        guard report.subject == .math else { return [] }
        let score = GKScore(leaderboardIdentifier: GameCenterLeaderboard.totalCorrectAnswers.rawValue)
        score.value = Int64(report.totalCorrectAnswers)
        score.context = 0
        return [score]
    }

    private func configureAccessPoint(isActive: Bool) {
        GKAccessPoint.shared.showHighlights = false
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.isActive = isActive && accessPointRequested
    }

    private func presentAuthenticationController(_ controller: UIViewController) {
    #if canImport(UIKit)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let root = window.rootViewController else {
            logger.error("Unable to present Game Center login controller")
            return
        }

        var presenter: UIViewController = root
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        presenter.present(controller, animated: true)
    #endif
    }
    private func submit(report: GameSessionReport) {
        let achievements = buildAchievements(for: report)
        if !achievements.isEmpty {
            GKAchievement.report(achievements) { [weak self] error in
                if let error {
                    self?.logger.error("Failed to report achievements: \(error.localizedDescription, privacy: .public)")
                }
            }
        }

        let leaderboardEntries = buildLeaderboardEntries(for: report)
        if !leaderboardEntries.isEmpty {
            GKScore.report(leaderboardEntries) { [weak self] error in
                if let error {
                    self?.logger.error("Failed to report leaderboard score: \(error.localizedDescription, privacy: .public)")
                }
            }
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
