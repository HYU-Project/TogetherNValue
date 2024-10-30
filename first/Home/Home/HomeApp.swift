//
//  HomeApp.swift
//  Home
//
//  Created by 김현경 on 10/15/24.
//

import SwiftUI
import SwiftData

@main
struct HomeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ConsentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
