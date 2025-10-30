import SwiftUI
internal import CoreData

struct ContentView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var purchaseManager: MockPurchaseManager
    @EnvironmentObject private var gameCenterManager: GameCenterManager
    @State private var selectedTab: MainTab = .quests
    @State private var showParentalGate = false
    @State private var showSettings = false
    @State private var pendingAction: (() -> Void)?
    @State private var showUpgradeDialog = false
    @State private var showPlacementPrompt = false
    @State private var placementError: String?
    @AppStorage("placementGradeBand") private var placementGradeRaw: String = ""

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
            QuestMapView()
                .tabItem { Label("Quests", systemImage: "map.fill") }
                .tag(MainTab.quests)

            AvatarCustomizationView(starBalance: starBalance)
                .tabItem { Label("Avatar", systemImage: "person.crop.circle") }
                .tag(MainTab.avatar)

            ShopView(starBalance: starBalance, onSpend: { _ in })
                .tabItem { Label("Shop", systemImage: "bag.fill") }
                .tag(MainTab.shop)

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
        .task {
            gameCenterManager.authenticate()
        }
    }

    private var starBalance: Int {
        guard let progress = try? progressStore.subjectProgress(for: .math) else { return 0 }
        let correct = Int(progress.totalCorrectAnswers)
        return Int(progress.totalSessions) * 12 + correct
    }

    private enum MainTab: Hashable {
        case quests, avatar, shop, parents
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

