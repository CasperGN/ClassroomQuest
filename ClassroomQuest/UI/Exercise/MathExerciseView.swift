import SwiftUI
internal import CoreData

struct ExerciseRoute: Hashable {
    let id = UUID()
    let subject: LearningSubject
    let problems: [MathProblem]
}

struct MathExerciseView: View {
    let route: ExerciseRoute
    let progressStore: ProgressStore

    @Environment(\.dismiss) private var dismiss
    @State private var answers: [UUID: String] = [:]
    @State private var results: [MathProblemResult] = []
    @State private var currentIndex: Int = 0
    @State private var completed = false
    @State private var celebrationID = UUID()
    @State private var submissionError = false
    @State private var showFeedback = false
    @State private var lastResult: MathProblemResult?
    @State private var lastSubmittedAnswer: Int?
    @State private var hintUsed = false

    private var currentProblem: MathProblem { route.problems[currentIndex] }
    private var correctAnswerCount: Int { results.filter { $0.isCorrect }.count }
    private var progressValue: Double {
        let answered = Double(currentIndex) + (showFeedback ? 1 : 0)
        return answered / Double(route.problems.count)
    }

    var body: some View {
        ZStack {
            LinearGradient.cqSoftAdventure
                .ignoresSafeArea()

            VStack(spacing: 24) {
                if completed {
                    completionView
                } else {
                    progressHeader
                    problemCard
                    controlSection
                    hintFooter
                }
            }
            .padding(24)
        }
        .navigationTitle("\(route.subject.displayName) Quest")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
                Spacer()
                Text("Question \(currentIndex + 1)/\(route.problems.count)")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
            }

            GeometryReader { geometry in
                Capsule()
                    .fill(Color.white.opacity(0.35))
                    .frame(height: 18)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(CQTheme.yellowAccent)
                            .frame(width: max(geometry.size.width * max(progressValue, 0.05), 24))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressValue)
                    }
            }
            .frame(height: 18)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(CQTheme.cardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 8)
        )
    }

    private var problemCard: some View {
        VStack(spacing: 24) {
            Text(currentProblem.prompt)
                .font(.system(size: 44, weight: .semibold, design: .rounded))
                .foregroundStyle(CQTheme.textPrimary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)

            TextField("Type your answer", text: Binding(
                get: { answers[currentProblem.id, default: ""] },
                set: { answers[currentProblem.id] = $0 }
            ))
            .keyboardType(.numberPad)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(CQTheme.bluePrimary.opacity(0.4), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                    )
            )
            .font(.system(size: 32, weight: .regular, design: .rounded))
            .multilineTextAlignment(.center)
            .disabled(showFeedback)

            if submissionError {
                Text("Please enter a number to continue.")
                    .font(.cqCaption)
                    .foregroundStyle(.red)
            }

            if hintUsed && !showFeedback {
                Text("Hint: Break the numbers into friendly parts to make counting easier.")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            feedbackSection
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 12)
        )
    }

    @ViewBuilder
    private var controlSection: some View {
        if showFeedback {
            Button(action: advanceAfterFeedback) {
                Text(currentIndex == route.problems.count - 1 ? "See Results" : "Next Question")
                    .font(.cqButton)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
            }
            .buttonStyle(.borderedProminent)
            .tint(CQTheme.bluePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else {
            Button(action: submitAnswer) {
                Text("Check Answer")
                    .font(.cqButton)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
            }
            .buttonStyle(.borderedProminent)
            .tint(CQTheme.bluePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var hintFooter: some View {
        Button {
            hintUsed = true
        } label: {
            Label(hintUsed ? "Hint Used" : "Need a Hint?", systemImage: hintUsed ? "lightbulb.fill" : "questionmark.circle")
                .font(.cqBody2)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .buttonStyle(.bordered)
        .tint(CQTheme.yellowAccent)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .disabled(hintUsed || showFeedback)
    }

    private func submitAnswer() {
        guard !showFeedback else {
            advanceAfterFeedback()
            return
        }
        submissionError = false
        guard let text = answers[currentProblem.id]?.trimmingCharacters(in: .whitespacesAndNewlines),
              let value = Int(text) else {
            submissionError = true
            return
        }

        let problem = currentProblem
        let isCorrect = value == problem.correctAnswer
        let result = MathProblemResult(problem: problem, isCorrect: isCorrect)
        results.append(result)
        lastResult = result
        lastSubmittedAnswer = value
        showFeedback = true
    }

    @ViewBuilder
    private var feedbackSection: some View {
        if showFeedback, let result = lastResult {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: result.isCorrect ? "checkmark.seal.fill" : "xmark.octagon.fill")
                        .font(.largeTitle)
                        .foregroundStyle(result.isCorrect ? CQTheme.greenSecondary : Color.red)
                    Text(result.isCorrect ? "Correct!" : "Not quite.")
                        .font(.cqBody1)
                        .foregroundStyle(result.isCorrect ? CQTheme.greenSecondary : Color.red)
                }
                if let submitted = lastSubmittedAnswer, !result.isCorrect {
                    Text("You answered \(submitted). The correct answer is \(result.problem.correctAnswer).")
                        .font(.cqBody2)
                        .foregroundStyle(CQTheme.textSecondary)
                        .multilineTextAlignment(.center)
                } else if result.isCorrect {
                    Text("Great job! Keep the streak alive.")
                        .font(.cqBody2)
                        .foregroundStyle(CQTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(result.isCorrect ? CQTheme.greenSecondary.opacity(0.18) : Color.red.opacity(0.12))
            )
        }
    }

    private func advanceAfterFeedback() {
        guard let lastProblem = lastResult?.problem else { return }
        showFeedback = false
        lastResult = nil
        lastSubmittedAnswer = nil
        answers[lastProblem.id] = nil
        submissionError = false

        if currentIndex == route.problems.count - 1 {
            completeSession()
        } else {
            currentIndex += 1
        }
        hintUsed = false
    }

    private func completeSession() {
        do {
            try progressStore.recordSession(for: route.subject, results: results)
            celebrationID = UUID()
            completed = true
        } catch {
            assertionFailure("Failed to save session: \(error)")
        }
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            ZStack {
#if canImport(UIKit)
                LottieView(animationName: "confetti")
                    .id(celebrationID)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
#endif
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(CQTheme.cardBackground)
                    .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: 16)
                VStack(spacing: 16) {
                    Text("🎉")
                        .font(.system(size: 80))
                    Text("Quest Complete!")
                        .font(.cqTitle2)
                        .foregroundStyle(CQTheme.textPrimary)
                    Text("You answered \(correctAnswerCount) of \(route.problems.count) questions correctly.")
                        .font(.cqBody2)
                        .foregroundStyle(CQTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    Text("Stars Earned: ⭐️ \(correctAnswerCount * 2)")
                        .font(.cqBody1)
                        .foregroundStyle(CQTheme.yellowAccent)
                }
                .padding(32)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)

            Button {
                dismiss()
            } label: {
                Text("Back to Map")
                    .font(.cqButton)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
            }
            .buttonStyle(.borderedProminent)
            .tint(CQTheme.bluePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .padding(.top, 40)
    }
}

#Preview {
    let controller = PersistenceController.preview
    let store = ProgressStore(viewContext: controller.container.viewContext)
    var generatorSource: any RandomNumberGenerator = SystemRandomNumberGenerator()
    let generator = MathProblemGenerator()
    let problems = (0..<5).map { _ in generator.generateProblem(for: .additionWithin10, proficiency: 0, randomSource: &generatorSource) }
    NavigationStack {
        MathExerciseView(route: ExerciseRoute(subject: .math, problems: problems), progressStore: store)
    }
}
