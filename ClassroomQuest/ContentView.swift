import SwiftUI
internal import CoreData

struct ContentView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var purchaseManager: MockPurchaseManager
    @State private var path: [ExerciseRoute] = []
    @State private var selectedTab: MainTab = .learn
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
        let selection = Binding(
            get: { selectedTab },
            set: { newValue in
                guard newValue != selectedTab else { return }
                if newValue == .parents {
                    requestParentalAccess {
                        selectedTab = .parents
                    }
                } else {
                    selectedTab = newValue
                }
            }
        )

        return TabView(selection: selection) {
            NavigationStack(path: $path) {
                LearnDashboardView(
                    subjectSummaries: LearningSubject.allCases.map { subject in
                        LearnDashboardSubject(subject: subject, summary: summary(for: subject))
                    },
                    xpProgress: overallXPProgress,
                    starBalance: starBalance,
                    isUnlimitedUnlocked: purchaseManager.isUnlocked,
                    onStartSubject: { subject in
                        startExercise(for: subject)
                    },
                    onOpenShop: {
                        selectedTab = .shop
                    },
                    onUpgrade: {
                        if purchaseManager.isUnlocked {
                            showUpgradeDialog = true
                        } else {
                            requestParentalAccess {
                                purchaseManager.unlock()
                            }
                        }
                    },
                    onShowSettings: {
                        requestParentalAccess {
                            showSettings = true
                        }
                    }
                )
                .navigationDestination(for: ExerciseRoute.self) { route in
                    MathExerciseView(route: route, progressStore: progressStore)
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            .tabItem { Label("Learn", systemImage: "function") }
            .tag(MainTab.learn)

            AvatarCustomizationView(starBalance: starBalance)
                .tabItem { Label("Avatar", systemImage: "person.crop.circle") }
                .tag(MainTab.avatar)

            ShopView(starBalance: starBalance, onSpend: { _ in })
                .tabItem { Label("Shop", systemImage: "bag.fill") }
                .tag(MainTab.shop)

            QuestMapView()
                .tabItem { Label("Quests", systemImage: "map.fill") }
                .tag(MainTab.quests)

            ParentDashboardView(progressStore: progressStore)
                .tabItem { Label("Parents", systemImage: "gearshape.fill") }
                .tag(MainTab.parents)
        }
        .accentColor(CQTheme.bluePrimary)
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

    private var starBalance: Int {
        guard let progress = try? progressStore.subjectProgress(for: .math) else { return 0 }
        let correct = Int(progress.totalCorrectAnswers)
        return Int(progress.totalSessions) * 12 + correct
    }

    private var overallXPProgress: Double {
        normalizedMasteryProgress(for: .math)
    }

    private enum MainTab: Hashable {
        case learn, avatar, shop, quests, parents
    }

    private func summary(for subject: LearningSubject) -> SubjectProgressSummary {
        do {
            let progress = try progressStore.subjectProgress(for: subject)
            let focusSkill = progressStore.focusSkill(for: subject)
            let normalizedMastery = normalizedMasteryProgress(for: subject)
            let canStart = purchaseManager.isUnlocked || progress.dailyExerciseCount < 1
            let completedText: String = {
                guard progress.totalSessions > 0 else { return "" }
                return String(localized: " • \(progress.totalSessions) quests completed", comment: "Suffix showing how many quests the learner completed today")
            }()
            let detailPrefix = String(localized: "Next skill: \(focusSkill.displayName)", comment: "Label describing the next focus skill")

            if canStart {
                if purchaseManager.isUnlocked {
                    let detail = String(localized: "Unlimited mode active • \(focusSkill.displayName)", comment: "Detail shown when unlimited mode is active for the current focus skill")
                    return SubjectProgressSummary(
                        statusText: String(localized: "Unlimited"),
                        detailText: detail,
                        statusTint: subject.accentColor,
                        ctaTitle: String(localized: "Start Quest"),
                        canStart: true,
                        focusSkillName: focusSkill.displayName,
                        masteryProgress: normalizedMastery,
                        starRating: normalizedMastery * 5
                    )
                } else {
                    let detail = detailPrefix + completedText
                    return SubjectProgressSummary(
                        statusText: String(localized: "Ready"),
                        detailText: detail,
                        statusTint: subject.accentColor,
                        ctaTitle: String(localized: "Start Quest"),
                        canStart: true,
                        focusSkillName: focusSkill.displayName,
                        masteryProgress: normalizedMastery,
                        starRating: normalizedMastery * 5
                    )
                }
            } else {
                return SubjectProgressSummary(
                    statusText: String(localized: "Done"),
                    detailText: String(localized: "You've completed today's quest. See you tomorrow!"),
                    statusTint: CQTheme.yellowAccent,
                    ctaTitle: String(localized: "All Done"),
                    canStart: false,
                    focusSkillName: focusSkill.displayName,
                    masteryProgress: normalizedMastery,
                    starRating: normalizedMastery * 5
                )
            }
        } catch {
            return SubjectProgressSummary(
                statusText: String(localized: "Loading"),
                detailText: String(localized: "Hang tight while we fetch your progress."),
                statusTint: CQTheme.textSecondary,
                ctaTitle: String(localized: "Start Quest"),
                canStart: false,
                focusSkillName: subject.displayName,
                masteryProgress: 0,
                starRating: 0
            )
        }
    }

    private func normalizedMasteryProgress(for subject: LearningSubject) -> Double {
        let proficiency = progressStore.focusSkillProficiency(for: subject)
        let normalized = (proficiency + 2.5) / 5.0
        return min(max(normalized, 0), 1)
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
        let desiredCount = 15
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

