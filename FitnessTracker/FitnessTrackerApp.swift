//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftUI

@main
struct FitnessTrackerApp: App {
    
    @StateObject private var restTimerManager = RestTimerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(restTimerManager)
        }
        .modelContainer(for: Workout.self)
    }
}
