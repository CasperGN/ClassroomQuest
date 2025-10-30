import SwiftUI
internal import CoreData

@main
struct ClassroomQuestApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var progressStore: ProgressStore
    @StateObject private var purchaseManager: MockPurchaseManager
    @StateObject private var gameCenterManager: GameCenterManager
    @State private var hasFinishedSplash = false

    init() {
        let context = persistenceController.container.viewContext
        let progressStore = ProgressStore(viewContext: context)
        let gameCenterManager = GameCenterManager()
        let showAccessPoint = UserDefaults.standard.bool(forKey: "gameCenterAccessPointVisible")
        gameCenterManager.setAccessPointVisible(showAccessPoint)
        progressStore.achievementReporter = gameCenterManager
        _progressStore = StateObject(wrappedValue: progressStore)
        _purchaseManager = StateObject(wrappedValue: MockPurchaseManager())
        _gameCenterManager = StateObject(wrappedValue: gameCenterManager)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(hasFinishedSplash ? 1 : 0)

                if !hasFinishedSplash {
                    StartupSplashView {
                        withAnimation(.easeOut(duration: 0.35)) {
                            hasFinishedSplash = true
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: hasFinishedSplash)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(progressStore)
            .environmentObject(purchaseManager)
            .environmentObject(gameCenterManager)
        }
    }
}
