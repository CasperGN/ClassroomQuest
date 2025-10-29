import SwiftUI

struct SubjectCardView: View {
    let subject: LearningSubject
    let progressSummary: SubjectProgressSummary
    let onStartExercise: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: subject.iconSystemName)
                    .font(.title2)
                    .padding(8)
                    .background(subject.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Spacer()

                Text(progressSummary.statusText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(progressSummary.statusTint.opacity(0.15))
                    .foregroundStyle(progressSummary.statusTint)
                    .clipShape(Capsule())
            }

            Text(subject.displayName)
                .font(.title2)
                .fontWeight(.semibold)

            Text(progressSummary.detailText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onStartExercise) {
                Label(progressSummary.ctaTitle, systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!progressSummary.canStart)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 8)
        )
    }
}

struct SubjectProgressSummary {
    let statusText: String
    let detailText: String
    let statusTint: Color
    let ctaTitle: String
    let canStart: Bool
}

#Preview {
    SubjectCardView(
        subject: .math,
        progressSummary: SubjectProgressSummary(statusText: "Ready", detailText: "You can play today's challenge.", statusTint: .green, ctaTitle: "Start", canStart: true)
    ) {}
    .padding()
    .background(Color(.systemGroupedBackground))
}
