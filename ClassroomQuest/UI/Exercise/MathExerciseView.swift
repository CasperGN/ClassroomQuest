import SwiftUI

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
    @State private var submissionError = false
    @State private var showFeedback = false
    @State private var lastResult: MathProblemResult?
    @State private var lastSubmittedAnswer: Int?

    private var currentProblem: MathProblem { route.problems[currentIndex] }
    private var correctAnswerCount: Int { results.filter { $0.isCorrect }.count }

    var body: some View {
        VStack(spacing: 24) {
            if completed {
                completionView
            } else {
                progressHeader
                problemCard
                controlSection
            }
        }
        .padding()
        .navigationTitle("\(route.subject.displayName) Quest")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            Text("Question \(currentIndex + 1) of \(route.problems.count)")
                .font(.headline)
            ProgressView(
                value: Double(currentIndex) + (showFeedback ? 1 : 0),
                total: Double(route.problems.count)
            )
                .tint(route.subject.accentColor)
        }
    }

    private var problemCard: some View {
        VStack(spacing: 16) {
            Text(currentProblem.prompt)
                .font(.title2)
                .multilineTextAlignment(.center)

            TextField("Type your answer", text: Binding(
                get: { answers[currentProblem.id, default: ""] },
                set: { answers[currentProblem.id] = $0 }
            ))
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .font(.title3)
            .multilineTextAlignment(.center)
            .disabled(showFeedback)

            if submissionError {
                Text("Please enter a number to continue.")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            feedbackSection
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private var controlSection: some View {
        if showFeedback {
            Button(action: advanceAfterFeedback) {
                Text(currentIndex == route.problems.count - 1 ? "See Results" : "Next Question")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button(action: submitAnswer) {
                Text("Check Answer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
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
                Text(result.isCorrect ? "Correct!" : "Not quite.")
                    .font(.headline)
                    .foregroundStyle(result.isCorrect ? Color.green : Color.red)
                if let submitted = lastSubmittedAnswer, !result.isCorrect {
                    Text("You answered \(submitted). The correct answer is \(result.problem.correctAnswer).")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                } else if result.isCorrect {
                    Text("Nice work! Keep it up.")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(result.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
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
    }

    private func completeSession() {
        do {
            try progressStore.recordSession(for: route.subject, results: results)
            completed = true
        } catch {
            assertionFailure("Failed to save session: \(error)")
        }
    }

    private var completionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(route.subject.accentColor)
            Text("Great work!")
                .font(.title)
                .fontWeight(.bold)
            Text("You answered \(correctAnswerCount) out of \(route.problems.count) correctly.")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Come back tomorrow for a new quest.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
