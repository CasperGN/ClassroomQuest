import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: MockPurchaseManager
    @EnvironmentObject private var progressStore: ProgressStore
    
    @State private var selectedGrade: GradeBand = .grade2

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    if purchaseManager.isUnlocked {
                        Label("ClassroomQuest Unlimited", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Button("Reset Unlock") {
                            purchaseManager.resetUnlock()
                        }
                    } else {
                        Label("ClassroomQuest Unlimited", systemImage: "lock.circle")
                        Button("Unlock (Mock)") {
                            purchaseManager.unlock()
                        }
                    }
                }

                Section("Progress") {
                    Text("Parent dashboards arrive in a later release.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Initial Placement") {
                    Picker("Grade Band", selection: $selectedGrade) {
                        Text("Kindergarten").tag(GradeBand.kindergarten)
                        Text("Grade 1").tag(GradeBand.grade1)
                        Text("Grade 2").tag(GradeBand.grade2)
                        Text("Grade 3").tag(GradeBand.grade3)
                        Text("Grade 4").tag(GradeBand.grade4)
                        Text("Grade 5").tag(GradeBand.grade5)
                    }
                    .pickerStyle(.menu)

                    Button("Apply Placement") {
                        let profile = PlacementProfile(gradeBand: selectedGrade)
                        do {
                            try progressStore.applyPlacement(profile: profile)
                        } catch {
                            // In a production app, surface an error UI; for now, assert.
                            assertionFailure("Failed to apply placement: \(error)")
                        }
                    }
                }

                Section("About") {
                    Text("ClassroomQuest is an offline learning adventure designed for kids.")
                }
            }
            .navigationTitle("Parent Settings")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MockPurchaseManager.preview)
}
