//
//  LoadManagementApp.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 4.11.2024.
//

import SwiftUI
import SwiftData

@main
struct LoadManagementApp: App {
    @State var recordingViewModel = RecordingViewModel()
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
            HomeView()
                .environment(recordingViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
