import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    Label("ClassroomQuest Unlimited (coming soon)", systemImage: "lock.circle")
                        .foregroundStyle(.secondary)
                }

                Section("Progress") {
                    Text("Parent dashboards arrive in a later release.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
}
