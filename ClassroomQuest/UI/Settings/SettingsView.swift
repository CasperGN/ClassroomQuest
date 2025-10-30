internal import CoreData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: MockPurchaseManager
    @EnvironmentObject private var progressStore: ProgressStore

    @AppStorage("placementGradeBand") private var placementGradeRaw: String = ""
    @AppStorage("curriculumPlacementGrade") private var curriculumPlacementRaw: String = CurriculumGrade.preK.rawValue
    @State private var selectedGrade: GradeBand = .grade2
    @State private var selectedCurriculumGrade: CurriculumGrade = .preK

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
                    if let stored = GradeBand(rawValue: placementGradeRaw), !placementGradeRaw.isEmpty {
                        Label("Current level: \(stored.displayName)", systemImage: "graduationcap")
                    }
                    Picker("Grade Band", selection: $selectedGrade) {
                        ForEach(GradeBand.allCases) { grade in
                            Text(grade.displayName).tag(grade)
                        }
                    }
                    .pickerStyle(.menu)

                    Button("Apply Placement") {
                        let profile = PlacementProfile(gradeBand: selectedGrade)
                        do {
                            try progressStore.applyPlacement(profile: profile)
                            placementGradeRaw = selectedGrade.rawValue
                        } catch {
                            // In a production app, surface an error UI; for now, assert.
                            assertionFailure("Failed to apply placement: \(error)")
                        }
                    }
                }

                Section("Quest Map Level") {
                    if let stored = CurriculumGrade(rawValue: curriculumPlacementRaw) {
                        Label("Current quest grade: \(stored.displayName)", systemImage: "map")
                    }

                    Picker("Quest Grade", selection: $selectedCurriculumGrade) {
                        ForEach(CurriculumGrade.allCases) { grade in
                            Text(grade.displayName).tag(grade)
                        }
                    }

                    Button("Apply Quest Grade") {
                        progressStore.applyCurriculumPlacement(grade: selectedCurriculumGrade)
                        curriculumPlacementRaw = selectedCurriculumGrade.rawValue
                    }
                }

                Section("About") {
                    Text("ClassroomQuest is an offline learning adventure designed for kids.")
                }
            }
            .navigationTitle("Parent Settings")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
        .onAppear {
            if let stored = GradeBand(rawValue: placementGradeRaw), !placementGradeRaw.isEmpty {
                selectedGrade = stored
            }
            if let storedQuestGrade = CurriculumGrade(rawValue: curriculumPlacementRaw) {
                selectedCurriculumGrade = storedQuestGrade
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MockPurchaseManager.preview)
        .environmentObject(ProgressStore(viewContext: PersistenceController.preview.container.viewContext))
}
