//
//  wordlyApp.swift
//  wordly
//
//

import SwiftUI

@main
struct wordlyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
