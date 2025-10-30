import SwiftUI
internal import CoreData
import GameKit


struct ParentDashboardView: View {
    @ObservedObject var progressStore: ProgressStore
    @EnvironmentObject private var gameCenterManager: GameCenterManager
    @State private var showAchievements = false
    @State private var showLeaderboard = false
    @AppStorage("gameCenterAccessPointVisible") private var isAccessPointEnabled = false

    private var subjectProgress: SubjectProgress? {
        try? progressStore.subjectProgress(for: .math)
    }

    private var streakCount: Int {
        guard let progress = subjectProgress else { return 0 }
        return Int(progress.totalSessions)
    }

    private var totalCorrect: Int {
        Int(subjectProgress?.totalCorrectAnswers ?? 0)
    }

    private var focusSkill: MathSkill {
        progressStore.focusSkill(for: .math)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                progressSection
                gameCenterSection
                starsSection
                subscriptionSection
                exportSection
            }
            .padding(24)
        }
        .background(CQTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showAchievements) {
            GameCenterDashboardView(destination: .achievements)
        }
        .sheet(isPresented: $showLeaderboard) {
            GameCenterDashboardView(destination: .leaderboards)
        }
        .onAppear {
            gameCenterManager.setAccessPointVisible(isAccessPointEnabled)
        }
        .onChange(of: isAccessPointEnabled) { _, newValue in
            gameCenterManager.setAccessPointVisible(newValue)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Parent Dashboard")
                .font(.cqTitle2)
                .foregroundStyle(CQTheme.textPrimary)
            Text("Monitor growth, celebrate wins, and manage your family's subscription.")
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Overview")
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)

            VStack(spacing: 12) {
                progressBar(title: "Daily Quests", value: min(Double(streakCount) / 10.0, 1.0), detail: "\(streakCount) completed this month")
                progressBar(title: "Correct Answers", value: min(Double(totalCorrect) / 100.0, 1.0), detail: "\(totalCorrect) correct all time")
                progressBar(title: "Focus Skill", value: normalizedMastery, detail: focusSkill.displayName)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(CQTheme.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 8)
            )
        }
    }

    private var starsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stars & Streaks")
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)

            HStack(spacing: 16) {
                infoTile(title: "Stars Earned", value: "⭐️ \(totalCorrect + streakCount * 12)", subtitle: "Lifetime total")
                infoTile(title: "Current Streak", value: "🔥 \(max(streakCount, 1))", subtitle: "Days in a row")
            }
        }
    }

    private var gameCenterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Center")
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(gameCenterStatusColor)
                        .frame(width: 10, height: 10)
                    Text(gameCenterStatusDescription)
                        .font(.cqCaption)
                        .foregroundStyle(CQTheme.textSecondary)
                    Spacer()
                    if gameCenterManager.isConfigurationValid {
                        if case .failed = gameCenterManager.authenticationState {
                            Button("Retry") {
                                gameCenterManager.authenticate()
                            }
                            .font(.cqCaption)
                        }
                    } else {
                        Button("Check Again") {
                            gameCenterManager.resetConfigurationValidation()
                        }
                        .font(.cqCaption)
                    }
                }

                HStack(spacing: 12) {
                    Button("View Achievements") {
                        showAchievements = true
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isGameCenterReady || !GameCenterDashboardView.isAvailable)

                    Button("View Leaderboard") {
                        showLeaderboard = true
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isGameCenterReady || !GameCenterDashboardView.isAvailable)
                }

                Toggle("Show Game Center icon for kids", isOn: $isAccessPointEnabled)
                    .font(.cqCaption)
                    .tint(CQTheme.bluePrimary)
                    .disabled(!isGameCenterReady || !gameCenterManager.isConfigurationValid)

                if !gameCenterManager.isConfigurationValid {
                    Text("Enable Game Center for this bundle in App Store Connect, then tap \"Check Again\" to retry authentication.")
                        .font(.cqCaption)
                        .foregroundStyle(CQTheme.textSecondary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(CQTheme.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 8)
            )
        }
    }

    private var isGameCenterReady: Bool {
        if case .authenticated = gameCenterManager.authenticationState,
           GKLocalPlayer.local.isAuthenticated,
           GameCenterDashboardView.isAvailable {
            return true
        }
        return false
    }

    private var gameCenterStatusDescription: String {
        switch gameCenterManager.authenticationState {
        case .idle:
            return "Sign in from your device settings to enable achievements."
        case .authenticating:
            return "Connecting to Game Center…"
        case .authenticated:
            if GameCenterDashboardView.isAvailable {
                return "Game Center connected. Achievements are tracking."
            } else {
                return "Game Center is connected. Update your device to view dashboards."
            }
        case .failed(let message):
            return "Sign-in failed: \(message)"
        }
    }

    private var gameCenterStatusColor: Color {
        switch gameCenterManager.authenticationState {
        case .authenticated:
            return .green
        case .authenticating:
            return .yellow
        case .failed:
            return .red
        case .idle:
            return .gray
        }
    }

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subscription")
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)
            VStack(alignment: .leading, spacing: 12) {
                Text("ClassroomQuest Unlimited")
                    .font(.cqBody2)
                    .foregroundStyle(CQTheme.textPrimary)
                Text("Unlock unlimited quests, avatar gifts, and premium reports for the whole family.")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
                Button(action: {}) {
                    Text("Manage with Family Sharing")
                        .font(.cqCaption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(CQTheme.bluePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(CQTheme.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 8)
            )
        }
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Progress")
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)
            Button(action: {}) {
                Label("Save to iCloud Drive", systemImage: "icloud.and.arrow.down")
                    .font(.cqBody2)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func progressBar(title: String, value: Double, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
                Spacer()
                Text(detail)
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
            }
            GeometryReader { geometry in
                Capsule()
                    .fill(CQTheme.background)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(CQTheme.bluePrimary)
                            .frame(width: geometry.size.width * value)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
                    }
            }
            .frame(height: 16)
        }
    }

    private func infoTile(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textSecondary)
            Text(value)
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)
            Text(subtitle)
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
        )
    }

    private var normalizedMastery: Double {
        let proficiency = progressStore.focusSkillProficiency(for: .math)
        let normalized = (proficiency + 2.5) / 5.0
        return min(max(normalized, 0), 1)
    }
}

#Preview {
    let controller = PersistenceController.preview
    let store = ProgressStore(viewContext: controller.container.viewContext)
    let manager = GameCenterManager()
    store.achievementReporter = manager
    return ParentDashboardView(progressStore: store)
        .environmentObject(manager)
}
