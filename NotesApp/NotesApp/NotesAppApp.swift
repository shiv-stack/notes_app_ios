// NotesAppApp.swift
// NotesApp
//
// App entry point. Sets up the SwiftData model container and injects
// the persistent store into the environment.

import SwiftUI
import SwiftData

@main
struct NotesAppApp: App {

    // Create the persistent SwiftData container for both models
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
            ChecklistItem.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
