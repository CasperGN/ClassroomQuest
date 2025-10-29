import SwiftUI

struct LearnDashboardSubject: Identifiable {
    let subject: LearningSubject
    let summary: SubjectProgressSummary

    var id: String { subject.id }
}

struct LearnDashboardView: View {
    let subjectSummaries: [LearnDashboardSubject]
    let xpProgress: Double
    let starBalance: Int
    let isUnlimitedUnlocked: Bool
    let onStartSubject: (LearningSubject) -> Void
    let onOpenShop: () -> Void
    let onUpgrade: () -> Void
    let onShowSettings: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            CQTheme.background
                .ignoresSafeArea()

            LinearGradient.cqSoftAdventure
                .opacity(0.9)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerCard

                    Text("Skills to Explore")
                        .font(.cqTitle2)
                        .foregroundStyle(CQTheme.textPrimary)
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(subjectSummaries) { entry in
                                SubjectCardView(subject: entry.subject, progressSummary: entry.summary) {
                                    onStartSubject(entry.subject)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }

                    if let primarySubject = subjectSummaries.first?.subject {
                        Button(action: { onStartSubject(primarySubject) }) {
                            Text("Start Practice")
                                .font(.cqButton)
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(CQTheme.bluePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                    }

                    HStack(spacing: 16) {
                        starBalanceTile
                        unlimitedTile
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .padding(.top, 24)
            }
        }
        .accentColor(CQTheme.bluePrimary)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(CQTheme.cardBackground)
                            .frame(width: 68, height: 68)
                            .shadow(color: CQTheme.bluePrimary.opacity(0.15), radius: 12, x: 0, y: 8)
                        Text("😊")
                            .font(.system(size: 36))
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today's Quest")
                            .font(.cqTitle2)
                            .foregroundStyle(CQTheme.textPrimary)
                        Text("Keep your streak alive and earn stars!")
                            .font(.cqBody2)
                            .foregroundStyle(CQTheme.textSecondary)
                    }
                }

                Spacer()

                Button(action: onShowSettings) {
                    Image(systemName: "lock")
                        .font(.title3)
                        .foregroundStyle(CQTheme.bluePrimary)
                        .padding(12)
                        .background(CQTheme.cardBackground.opacity(0.7))
                        .clipShape(Circle())
                        .shadow(color: CQTheme.bluePrimary.opacity(0.15), radius: 12, x: 0, y: 8)
                }
                .accessibilityLabel("Parent settings")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("XP Progress")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
                GeometryReader { geometry in
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [CQTheme.bluePrimary, CQTheme.bluePrimary.opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                                .frame(width: max(geometry.size.width * max(0.05, xpProgress), 24))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: xpProgress)
                        }
                }
                .frame(height: 18)
                Text("Level \(max(1, Int(xpProgress * 10))) Adventurer")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textPrimary.opacity(0.8))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: CQTheme.bluePrimary.opacity(0.12), radius: 24, x: 0, y: 16)
        )
        .padding(.horizontal, 16)
    }

    private var starBalanceTile: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(CQTheme.yellowAccent)
                    .font(.title2)
                Spacer()
                Text("⭐️")
                    .font(.title)
            }
            Text("Stars")
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)
            Text("You have \(starBalance) stars ready to spend.")
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textSecondary)
            Button(action: onOpenShop) {
                Text("Go to Shop")
                    .font(.cqCaption)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(CQTheme.yellowAccent.opacity(0.2))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
    }

    private var unlimitedTile: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isUnlimitedUnlocked ? "checkmark.seal.fill" : "sparkles")
                    .font(.title2)
                    .foregroundStyle(isUnlimitedUnlocked ? CQTheme.greenSecondary : CQTheme.bluePrimary)
                Spacer()
            }
            Text(isUnlimitedUnlocked ? "Unlimited Unlocked" : "Unlock Unlimited")
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)
            Text(isUnlimitedUnlocked ? "Enjoy endless quests every day." : "Parents can enable endless quests with a tap.")
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textSecondary)
            Button(action: onUpgrade) {
                Text(isUnlimitedUnlocked ? "See Benefits" : "Ask a Grown-up")
                    .font(.cqCaption)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(CQTheme.bluePrimary.opacity(0.15))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
    }
}

#Preview {
    LearnDashboardView(
        subjectSummaries: [
            LearnDashboardSubject(
                subject: .math,
                summary: SubjectProgressSummary(
                    statusText: "Ready",
                    detailText: "Next skill: Addition to 10",
                    statusTint: CQTheme.bluePrimary,
                    ctaTitle: "Start Quest",
                    canStart: true,
                    focusSkillName: "Addition",
                    masteryProgress: 0.4,
                    starRating: 2.5
                )
            )
        ],
        xpProgress: 0.3,
        starBalance: 28,
        isUnlimitedUnlocked: false,
        onStartSubject: { _ in },
        onOpenShop: {},
        onUpgrade: {},
        onShowSettings: {}
    )
}
