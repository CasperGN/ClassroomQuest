import SwiftUI

struct SubjectCardView: View {
    let subject: LearningSubject
    let progressSummary: SubjectProgressSummary
    let onStartExercise: () -> Void
    
    private static let starIndices = Array(0..<5)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: subject.iconSystemName)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(subject.accentColor)
                    .padding(10)
                    .background(subject.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Spacer()

                CQProgressRing(value: progressSummary.masteryProgress, color: subject.accentColor)
                    .frame(width: 56, height: 56)
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

            Spacer()

            Button(action: onStartExercise) {
                Label(progressSummary.ctaTitle, systemImage: "play.fill")
                    .font(.cqButton)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(subject.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .disabled(!progressSummary.canStart)
        }
        .padding(20)
        .frame(width: 200, height: 236)
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
