import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var path: [ExerciseRoute] = []
    @State private var showParentalGate = false
    @State private var showSettings = false
    @State private var pendingAction: (() -> Void)?
    @State private var showUpgradeDialog = false

    private let problemGenerator = MathProblemGenerator()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(LearningSubject.allCases) { subject in
                        SubjectCardView(subject: subject, progressSummary: summary(for: subject)) {
                            startExercise(for: subject)
                        }
                        .padding(.horizontal)
                    }

                    Button {
                        requestParentalAccess {
                            showUpgradeDialog = true
                        }
                    } label: {
                        Label("Upgrade to Unlimited", systemImage: "star.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .padding(.vertical, 32)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("ClassroomQuest")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        requestParentalAccess {
                            showSettings = true
                        }
                    } label: {
                        Label("Parent", systemImage: "lock")
                    }
                }
            }
            .navigationDestination(for: ExerciseRoute.self) { route in
                MathExerciseView(route: route, progressStore: progressStore)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showParentalGate) {
            ParentalGateView {
                showParentalGate = false
                let action = pendingAction
                pendingAction = nil
                action?()
            } onCancel: {
                showParentalGate = false
                pendingAction = nil
            }
        }
        .alert("ClassroomQuest Unlimited", isPresented: $showUpgradeDialog, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text("Unlimited Mode unlocks unlimited exercises and more. Stay tuned!")
        })
    }

    private func summary(for subject: LearningSubject) -> SubjectProgressSummary {
        do {
            let progress = try progressStore.subjectProgress(for: subject)
            let focusSkill = progressStore.focusSkill(for: subject)
            let canStart = progress.dailyExerciseCount < 1

            if canStart {
                var detail = "Next skill: \(focusSkill.displayName)"
                if progress.totalSessions > 0 {
                    detail += " • \(progress.totalSessions) quests completed"
                }
                return SubjectProgressSummary(
                    statusText: "Ready",
                    detailText: detail,
                    statusTint: subject.accentColor,
                    ctaTitle: "Start Quest",
                    canStart: true
                )
            } else {
                return SubjectProgressSummary(
                    statusText: "Done",
                    detailText: "You've completed today's quest. See you tomorrow!",
                    statusTint: .orange,
                    ctaTitle: "All Done",
                    canStart: false
                )
            }
        } catch {
            return SubjectProgressSummary(
                statusText: "Loading",
                detailText: "Preparing your quest...",
                statusTint: .secondary,
                ctaTitle: "Start",
                canStart: false
            )
        }
    }

    private func startExercise(for subject: LearningSubject) {
        guard let progress = try? progressStore.subjectProgress(for: subject), progress.dailyExerciseCount < 1 else {
            return
        }
        var rng = SystemRandomNumberGenerator()
        let focusSkill = progressStore.focusSkill(for: subject)
        let proficiency = progressStore.proficiency(for: focusSkill, subject: subject)
        let problems = problemGenerator.generateSession(for: focusSkill, proficiency: proficiency, problemCount: 5, randomSource: &rng)
        let route = ExerciseRoute(subject: subject, problems: problems)
        path.append(route)
    }

    private func requestParentalAccess(_ action: @escaping () -> Void) {
        pendingAction = action
        showParentalGate = true
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProgressStore(viewContext: PersistenceController.preview.container.viewContext))
}
