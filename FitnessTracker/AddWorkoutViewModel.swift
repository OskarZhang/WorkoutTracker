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
        let sets = (0..<setCount).map { _ in StrengthSet(weightInLbs: Double(weight), reps: repCount, restSeconds: nil) }
        let newWorkout = Exercise(date: workoutDate, name: workoutName.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression), type: .strength, sets: sets)
        workoutService.addWorkout(workout: newWorkout)
    }

    func suggestWorkoutNames() -> [ExcerciseDataType] {
        workoutService.getWorkoutSuggestion(workoutName: workoutName)
    }

}
