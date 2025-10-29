import SwiftUI
internal import CoreData

@main
struct ClassroomQuestApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var progressStore: ProgressStore
    @StateObject private var purchaseManager: MockPurchaseManager

    init() {
        let context = persistenceController.container.viewContext
        _progressStore = StateObject(wrappedValue: ProgressStore(viewContext: context))
        _purchaseManager = StateObject(wrappedValue: MockPurchaseManager())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(progressStore)
                .environmentObject(purchaseManager)
        }
    }
}
