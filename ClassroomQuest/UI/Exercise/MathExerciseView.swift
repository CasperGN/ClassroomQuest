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

    private var currentProblem: MathProblem { route.problems[currentIndex] }

    var body: some View {
        VStack(spacing: 24) {
            if completed {
                completionView
            } else {
                progressHeader
                problemCard
                submitButton
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
            ProgressView(value: Double(currentIndex), total: Double(route.problems.count))
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

            if submissionError {
                Text("Please enter a number to continue.")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var submitButton: some View {
        Button(action: submitAnswer) {
            Text(currentIndex == route.problems.count - 1 ? "Finish" : "Next")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }

    private func submitAnswer() {
        submissionError = false
        guard let text = answers[currentProblem.id]?.trimmingCharacters(in: .whitespacesAndNewlines),
              let value = Int(text) else {
            submissionError = true
            return
        }

        let isCorrect = value == currentProblem.correctAnswer
        results.append(MathProblemResult(problem: currentProblem, isCorrect: isCorrect))

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
