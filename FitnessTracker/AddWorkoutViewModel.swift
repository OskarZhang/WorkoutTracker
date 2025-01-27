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
    
    var workouts: [Workout] = []
    
    let modelContext: ModelContext
    
    init(_ modelContext: ModelContext) {
        self.modelContext = modelContext
        self.workouts = fetchWorkouts()
    }
    
    var isValidInput: Bool {
        return !workoutName.isEmpty
    }

    func save() {
        let workoutType = WorkoutType.strength(weight: weight, repCount: repCount, setCount: setCount)
        let newWorkout = Workout(name: workoutName.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression), type: workoutType, date: workoutDate)
        modelContext.insert(newWorkout)
    }

    func suggestWorkoutNames() -> [Workout] {
        let finalList = (workoutName.isEmpty ? Array(workouts.prefix(10)) : workouts.filter { $0.name.lowercased().contains(workoutName.lowercased())})
            .reduce((uniqueWorkoutNames: Set<String>(), list: [Workout]())) { partialResult, workout in
                if (partialResult.uniqueWorkoutNames.contains(workout.name)) {
                    return partialResult
                }
                var uniqueNames = partialResult.uniqueWorkoutNames
                var list = partialResult.list
                list.append(workout)
                uniqueNames.insert(workout.name)
                return (uniqueNames, list)
            }
            .list
        if (finalList.count == 1 && workoutName == finalList.first?.name) {
            // no need to provide suggestions for the exact match
            return []
        }
        return finalList
    }
    
    private func fetchWorkouts() -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    
}
