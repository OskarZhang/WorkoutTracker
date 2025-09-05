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
            RootView()
        }
        .modelContainer(for: [
            Exercise.self,
            StrengthSet.self,
            Routine.self,
            RoutineDay.self,
            RoutineExerciseTemplate.self,
            UserProfile.self
        ])
    }
}
