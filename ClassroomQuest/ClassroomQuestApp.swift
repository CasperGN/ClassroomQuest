import SwiftUI
internal import CoreData

@main
struct ClassroomQuestApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var progressStore: ProgressStore
    @StateObject private var purchaseManager: MockPurchaseManager
    @StateObject private var gameCenterManager: GameCenterManager

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
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(progressStore)
                .environmentObject(purchaseManager)
                .environmentObject(gameCenterManager)
        }
    }
}
