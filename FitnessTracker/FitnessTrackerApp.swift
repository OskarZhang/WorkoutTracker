//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftUI
import SwiftData

@main
struct FitnessTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(restTimerManager)
        }
        .modelContainer(for: Exercise.self)
    }
}
