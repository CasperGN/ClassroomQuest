import SwiftUI

struct PlacementPromptView: View {
    @State private var selectedGrade: GradeBand
    private let allowDismiss: Bool
    private let onConfirm: (GradeBand) -> Void

    init(initialSelection: GradeBand?, allowDismiss: Bool, onConfirm: @escaping (GradeBand) -> Void) {
        _selectedGrade = State(initialValue: initialSelection ?? .grade2)
        self.allowDismiss = allowDismiss
        self.onConfirm = onConfirm
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Let's start with the right challenge.")
                            .font(.headline)
                        Text("Pick the grade level that best matches the learner today. We'll tune upcoming quests so they grow from there.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Current Level") {
                    Picker("Grade Band", selection: $selectedGrade) {
                        ForEach(GradeBand.allCases) { grade in
                            Text(grade.displayName).tag(grade)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .accessibilityLabel("Grade Level")
                }
            }
            .navigationTitle("Choose Your Level")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onConfirm(selectedGrade)
                    } label: {
                        Text("Continue")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .buttonBorderShape(.capsule)
                    .accessibilityLabel("Start at \(selectedGrade.displayName)")
                }
            }
        }
        .interactiveDismissDisabled(!allowDismiss)
    }
}

#Preview {
    PlacementPromptView(initialSelection: nil, allowDismiss: false) { _ in }
}
