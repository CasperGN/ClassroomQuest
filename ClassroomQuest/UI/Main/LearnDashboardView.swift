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

    private let horizontalPadding: CGFloat = 20
    @ScaledMetric(relativeTo: .title2) private var headerAvatarSize: CGFloat = 68
    @ScaledMetric(relativeTo: .title2) private var headerEmojiSize: CGFloat = 36
    @ScaledMetric(relativeTo: .body) private var supportTileMinHeight: CGFloat = 164
    @ScaledMetric(relativeTo: .body) private var tileIconSize: CGFloat = 44
    @ScaledMetric(relativeTo: .body) private var tileButtonHeight: CGFloat = 44

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
                        .padding(.horizontal, horizontalPadding)

                    Text("Skills to Explore")
                        .font(.cqTitle2)
                        .foregroundStyle(CQTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, horizontalPadding)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(subjectSummaries) { entry in
                                SubjectCardView(subject: entry.subject, progressSummary: entry.summary) {
                                    onStartSubject(entry.subject)
                                }
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, 8)
                    }

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                        starBalanceTile
                        unlimitedTile
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 32)
                }
                .padding(.top, 24)
            }
        }
        .accentColor(CQTheme.bluePrimary)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(CQTheme.cardBackground)
                        .frame(width: headerAvatarSize, height: headerAvatarSize)
                        .shadow(color: CQTheme.bluePrimary.opacity(0.15), radius: 12, x: 0, y: 8)
                    Text("😊")
                        .font(.system(size: headerEmojiSize))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Today's Quest")
                        .font(.system(.title2, design: .rounded))
                        .foregroundStyle(CQTheme.textPrimary)
                        .minimumScaleFactor(0.85)
                    Text("Keep your streak alive and earn stars!")
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(CQTheme.textSecondary)
                }

                Spacer(minLength: 12)

                Button(action: onShowSettings) {
                    Label("Parents", systemImage: "gearshape")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(CQTheme.bluePrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(CQTheme.cardBackground.opacity(0.9))
                        .clipShape(Capsule())
                        .shadow(color: CQTheme.bluePrimary.opacity(0.1), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Parent settings")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("XP Progress")
                    .font(.system(.footnote, design: .rounded).weight(.medium))
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
                    .font(.system(.footnote, design: .rounded).weight(.medium))
                    .foregroundStyle(CQTheme.textPrimary.opacity(0.8))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: CQTheme.bluePrimary.opacity(0.12), radius: 24, x: 0, y: 16)
        )
    }

    private var starBalanceTile: some View {
        supportTile(
            iconName: "star.fill",
            tint: CQTheme.yellowAccent,
            title: "Stars",
            message: "You have \(starBalance) stars ready to spend.",
            buttonTitle: "Go to Shop",
            buttonBackground: CQTheme.yellowAccent.opacity(0.18),
            action: onOpenShop
        )
    }

    private var unlimitedTile: some View {
        supportTile(
            iconName: isUnlimitedUnlocked ? "checkmark.seal.fill" : "sparkles",
            tint: isUnlimitedUnlocked ? CQTheme.greenSecondary : CQTheme.bluePrimary,
            title: isUnlimitedUnlocked ? "Unlimited Unlocked" : "Unlock Unlimited",
            message: isUnlimitedUnlocked ? "Enjoy endless quests every day." : "Parents can enable endless quests with a tap.",
            buttonTitle: isUnlimitedUnlocked ? "See Benefits" : "Ask a Grown-up",
            buttonBackground: CQTheme.bluePrimary.opacity(0.12),
            action: onUpgrade
        )
    }

    private func supportTile(
        iconName: String,
        tint: Color,
        title: String,
        message: String,
        buttonTitle: String,
        buttonBackground: Color,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(tint)
                    .font(.system(size: tileIconSize, weight: .semibold, design: .rounded))
                    .frame(width: tileIconSize + 12, height: tileIconSize + 12)
                    .background(tint.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(CQTheme.textPrimary)
                        .minimumScaleFactor(0.9)
                    Text(message)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(CQTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)

            Button(action: action) {
                Text(buttonTitle)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: tileButtonHeight)
                    .background(buttonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: supportTileMinHeight, alignment: .topLeading)
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
