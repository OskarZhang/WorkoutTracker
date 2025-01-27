//
//  WorkoutService.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 1/23/25.
//

import SwiftUI
import SwiftData

struct WorkoutService {
    @Query(sort: \Workout.date, order: .reverse) private var allWorkouts: [Workout] = []
}
