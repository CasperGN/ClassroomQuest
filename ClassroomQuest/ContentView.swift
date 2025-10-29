import SwiftUI
internal import CoreData

struct ContentView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var purchaseManager: MockPurchaseManager
    @State private var path: [ExerciseRoute] = []
    @State private var showParentalGate = false
    @State private var showSettings = false
    @State private var pendingAction: (() -> Void)?
    @State private var showUpgradeDialog = false
    @State private var showPlacementPrompt = false
    @State private var placementError: String?
    @AppStorage("placementGradeBand") private var placementGradeRaw: String = ""

    private let problemGenerator = MathProblemGenerator()

    private var storedPlacementGrade: GradeBand? {
        GradeBand(rawValue: placementGradeRaw)
    }

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
                        if !purchaseManager.isUnlocked {
                            requestParentalAccess {
                                purchaseManager.unlock()
                            }
                        } else {
                            showUpgradeDialog = true
                        }
                    } label: {
                        if purchaseManager.isUnlocked {
                            Label("Unlimited Unlocked", systemImage: "checkmark.seal")
                                .frame(maxWidth: .infinity)
                        } else {
                            Label("Upgrade to Unlimited", systemImage: "star.circle")
                                .frame(maxWidth: .infinity)
                        }
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
        .sheet(isPresented: $showPlacementPrompt) {
            PlacementPromptView(initialSelection: storedPlacementGrade, allowDismiss: storedPlacementGrade != nil) { grade in
                handlePlacementSelection(grade)
            }
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
        .alert("Unlimited Active", isPresented: Binding(get: { showUpgradeDialog && purchaseManager.isUnlocked }, set: { if !$0 { showUpgradeDialog = false } }), actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text("You have unlocked unlimited exercises. Enjoy!")
        })
        .alert("ClassroomQuest Unlimited", isPresented: Binding(get: { showUpgradeDialog && !purchaseManager.isUnlocked }, set: { if !$0 { showUpgradeDialog = false } }), actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text("Unlimited Mode unlocks unlimited exercises and more. Stay tuned!")
        })
        .alert("Placement Error", isPresented: Binding(get: { placementError != nil }, set: { if !$0 { placementError = nil } })) {
            Button("OK", role: .cancel) { placementError = nil }
        } message: {
            if let placementError {
                Text(placementError)
            }
        }
        .task {
            if storedPlacementGrade == nil {
                showPlacementPrompt = true
            }
        }
    }

    private func summary(for subject: LearningSubject) -> SubjectProgressSummary {
        do {
            let progress = try progressStore.subjectProgress(for: subject)
            let focusSkill = progressStore.focusSkill(for: subject)
            let canStart = purchaseManager.isUnlocked || progress.dailyExerciseCount < 1

            if canStart {
                if purchaseManager.isUnlocked {
                    let detail = "Unlimited mode active • Next skill: \(focusSkill.displayName)"
                    return SubjectProgressSummary(
                        statusText: "Unlimited",
                        detailText: detail,
                        statusTint: subject.accentColor,
                        ctaTitle: "Start Quest",
                        canStart: true
                    )
                } else {
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
                }
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
        guard let progress = try? progressStore.subjectProgress(for: subject), purchaseManager.isUnlocked || progress.dailyExerciseCount < 1 else {
            return
        }
        var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()
        let focusSkill = progressStore.focusSkill(for: subject)
        let proficiency = progressStore.proficiency(for: focusSkill, subject: subject)

        // Avoid recently used prompts across sessions and duplicates within the session.
        var problems: [MathProblem] = []
        var disallowed = progressStore.recentPrompts(for: focusSkill)
        let desiredCount = 5
        while problems.count < desiredCount {
            var attempts = 0
            var next = problemGenerator.generateProblem(for: focusSkill, proficiency: proficiency, randomSource: &rng)
            while (disallowed.contains(next.prompt) || problems.contains(where: { $0.prompt == next.prompt })) && attempts < 15 {
                next = problemGenerator.generateProblem(for: focusSkill, proficiency: proficiency, randomSource: &rng)
                attempts += 1
            }
            problems.append(next)
            disallowed.insert(next.prompt)
        }
        let route = ExerciseRoute(subject: subject, problems: problems)
        path.append(route)
    }

    private func requestParentalAccess(_ action: @escaping () -> Void) {
        pendingAction = action
        showParentalGate = true
    }

    private func handlePlacementSelection(_ grade: GradeBand) {
        let profile = PlacementProfile(gradeBand: grade)
        do {
            try progressStore.applyPlacement(profile: profile)
            placementGradeRaw = grade.rawValue
            showPlacementPrompt = false
        } catch {
            placementError = "We couldn't set your starting level. Please try again."
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProgressStore(viewContext: PersistenceController.preview.container.viewContext))
}

