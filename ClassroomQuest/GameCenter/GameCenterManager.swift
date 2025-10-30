import Combine
import Foundation
import GameKit
import os

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
        if case .authenticated = authenticationState, GKLocalPlayer.local.isAuthenticated {
            configureAccessPoint(isActive: true)
            return
        }
        authenticationState = .authenticating

        Task { await authenticatePlayer() }
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

    private func authenticatePlayer() async {
        do {
            try await GKLocalPlayer.local.authenticate()

            guard GKLocalPlayer.local.isAuthenticated else {
                authenticationState = .idle
                configureAccessPoint(isActive: false)
                return
            }

            authenticationState = .authenticated
            configureAccessPoint(isActive: true)
            await flushPendingReports()
        } catch {
            logger.error("Game Center authentication failed: \(error.localizedDescription, privacy: .public)")
            authenticationState = .failed(error.localizedDescription)
            configureAccessPoint(isActive: false)
        }
    }

    private func flushPendingReports() async {
        guard case .authenticated = authenticationState else { return }
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
