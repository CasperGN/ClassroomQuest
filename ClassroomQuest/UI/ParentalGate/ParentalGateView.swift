import SwiftUI

struct ParentalGateChallenge {
    let question: String
    let answer: Int

    static func additionChallenge() -> ParentalGateChallenge {
        let a = Int.random(in: 6...9)
        let b = Int.random(in: 3...9)
        return ParentalGateChallenge(question: "What is \(a) + \(b)?", answer: a + b)
    }
}

struct ParentalGateView: View {
    let onSuccess: () -> Void
    let onCancel: () -> Void

    @State private var challenge = ParentalGateChallenge.additionChallenge()
    @State private var answer: String = ""
    @State private var showError: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Parents Only")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Please solve this to continue.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Text(challenge.question)
                    .font(.title3)
                    .padding(.top, 12)

                TextField("Answer", text: $answer)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)

                if showError {
                    Text("Try again")
                        .foregroundStyle(.red)
                }

                Button("Continue") {
                    validate()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 12)

                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .padding(.top, 4)
            }
            .padding()
            .navigationTitle("Parental Gate")
        }
    }

    private func validate() {
        guard let value = Int(answer.trimmingCharacters(in: .whitespaces)) else {
            showError = true
            answer = ""
            return
        }
        if value == challenge.answer {
            onSuccess()
        } else {
            showError = true
            answer = ""
            challenge = ParentalGateChallenge.additionChallenge()
        }
    }
}

#Preview {
    ParentalGateView(onSuccess: {}, onCancel: {})
}
