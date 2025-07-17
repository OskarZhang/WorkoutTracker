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
    var exerciseName = ""
    var weight = 0
    var repCount = 5
    var setCount = 5
    var exerciseDate = Date()

    private let exerciseService: ExerciseService

    init(service: ExerciseService) {
        self.exerciseService = service
    }

    var isValidInput: Bool {
        return !exerciseName.isEmpty
    }

    func save() {
        let sets = (0..<setCount).map { _ in StrengthSet(weightInLbs: Double(weight), reps: repCount, restSeconds: nil) }
        let newWorkout = Exercise(date: exerciseDate, name: exerciseName.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression), type: .strength, sets: sets)
        exerciseService.addWorkout(exercise: newWorkout)
    }

    func suggestWorkoutNames() -> [Exercise] {
        exerciseService.getWorkoutSuggestion(exerciseName: exerciseName)
    }

}
