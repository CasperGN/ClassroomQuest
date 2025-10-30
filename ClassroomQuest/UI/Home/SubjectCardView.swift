import SwiftUI

struct SubjectCardView: View {
    let subject: LearningSubject
    let progressSummary: SubjectProgressSummary
    let onStartExercise: () -> Void

    private static let starIndices = Array(0..<5)
    @ScaledMetric(relativeTo: .title3) private var iconSize: CGFloat = 28
    @ScaledMetric(relativeTo: .title3) private var iconPadding: CGFloat = 10
    @ScaledMetric(relativeTo: .title3) private var ringSize: CGFloat = 52
    @ScaledMetric(relativeTo: .title2) private var cardWidth: CGFloat = 190
    @ScaledMetric(relativeTo: .title2) private var cardHeight: CGFloat = 220
    @ScaledMetric(relativeTo: .headline) private var actionHeight: CGFloat = 44

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: subject.iconSystemName)
                    .font(.system(size: iconSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(subject.accentColor)
                    .padding(iconPadding)
                    .background(subject.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Spacer()

                CQProgressRing(value: progressSummary.masteryProgress, color: subject.accentColor)
                    .frame(width: ringSize, height: ringSize)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(progressSummary.focusSkillName)
                    .font(.cqBody2)
                    .foregroundStyle(CQTheme.textPrimary)
                Text(progressSummary.detailText)
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
                    .lineLimit(2)
            }

            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { i in
                    star(for: progressSummary.starRating, at: i)
                }
                Spacer()
                Text(progressSummary.statusText)
                    .font(.cqCaption)
                    .foregroundStyle(progressSummary.statusTint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(progressSummary.statusTint.opacity(0.12))
                    .clipShape(Capsule())
            }

            Spacer(minLength: 0)

            Button(action: onStartExercise) {
                Label(progressSummary.ctaTitle, systemImage: "play.fill")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: actionHeight)
            }
            .buttonStyle(.borderedProminent)
            .tint(subject.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .disabled(!progressSummary.canStart)
        }
        .padding(20)
        .frame(width: cardWidth, height: cardHeight)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: CQTheme.bluePrimary.opacity(0.12), radius: 16, x: 0, y: 8)
        )
    }
}

@ViewBuilder
private func star(for rating: Double, at index: Int) -> some View {
    let lower = Double(index), upper = lower + 1
    let symbol = rating >= upper ? "star.fill" :
                 rating >  lower ? "star.leadinghalf.filled" : "star"
    let filled = rating > lower
    Image(systemName: symbol)
        .foregroundStyle(filled ? CQTheme.yellowAccent
                                : CQTheme.textSecondary.opacity(0.3))
}

struct SubjectProgressSummary {
    let statusText: String
    let detailText: String
    let statusTint: Color
    let ctaTitle: String
    let canStart: Bool
    let focusSkillName: String
    let masteryProgress: Double
    let starRating: Double
}

#Preview {
    SubjectCardView(
        subject: .math,
        progressSummary: SubjectProgressSummary(
            statusText: "Ready",
            detailText: "Master Addition • 3 quests completed",
            statusTint: CQTheme.greenSecondary,
            ctaTitle: "Start Quest",
            canStart: true,
            focusSkillName: "Addition",
            masteryProgress: 0.6,
            starRating: 3.5
        )
    ) {}
    .padding()
    .background(CQTheme.background)
}
