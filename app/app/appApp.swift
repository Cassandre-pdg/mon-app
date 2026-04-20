//
//  appApp.swift
//  app
//
//  Created by Cassandre Rollet on 13/04/2026.
//

import SwiftUI

@main
struct appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
