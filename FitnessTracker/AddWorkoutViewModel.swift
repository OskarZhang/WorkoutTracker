//
//  AddWorkoutViewModel.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 1/27/25.
//

import Foundation
import Combine
import SwiftData
import SwiftUI

@Observable
class AddWorkoutViewModel {
    var workoutName = ""
    var weight = 0
    var repCount = 5
    var setCount = 5
    var workoutDate = Date()
    
    private let workoutService: WorkoutService
    
    init(service: WorkoutService) {
        self.workoutService = service
    }
    
    var isValidInput: Bool {
        return !workoutName.isEmpty
    }

    func save() {
        let workoutType = WorkoutType.strength(weight: weight, repCount: repCount, setCount: setCount)
        let newWorkout = Workout(name: workoutName.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression), type: workoutType, date: workoutDate)
        workoutService.addWorkout(workout: newWorkout)
    }

    func suggestWorkoutNames() -> [Workout] {
        if workoutName.isEmpty {
            return workoutService.predictNextWorkout()
        } else {
            return workoutService.matchWorkout(workoutName: workoutName)
        }
    }

}
