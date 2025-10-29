//
//  ClassroomQuestApp.swift
//  ClassroomQuest
//
//  Created by Casper Nielsen on 10/29/25.
//

import SwiftUI
import CoreData

@main
struct ClassroomQuestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
