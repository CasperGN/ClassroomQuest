import SwiftUI
import CoreData

@main
struct ClassroomQuestApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var progressStore: ProgressStore

    init() {
        let context = persistenceController.container.viewContext
        _progressStore = StateObject(wrappedValue: ProgressStore(viewContext: context))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(progressStore)
        }
    }
}
