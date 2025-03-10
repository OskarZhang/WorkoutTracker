//
//  Recommender.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 3/9/25.
//

import SwiftData
import Foundation

class WorkoutService {
    
    static private let StartOfDayWorkoutToken: String = "StartOfDay"
    
    private let modelContext: ModelContext
    private var transitions: [String: [String: Int]] = [:]
    private var transitionProbabilities: [String: [String : Double]] = [:]
    private var workouts: [Workout] = []

    init(_ modelContext: ModelContext) {
        self.modelContext = modelContext
        self.workouts = fetchWorkouts()
        Task {
            await buildTransitionProbabilityMatrix(data: self.workouts)
        }
    }
    
    /// build a Markov Chain prediction matrix with workout data
    private func buildTransitionProbabilityMatrix(data: [Workout]) async {
        // Group exercises by date
        let calendar = Calendar.current
        let groupedByDate = Dictionary(grouping: data) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        // Calculate transitions
        for (_, exercises) in groupedByDate {
            let sortedExercises = exercises.sorted { $0.date < $1.date }
            
            // allows us to also
            let names = [""] + sortedExercises.map { $0.name }
            
            for i in 0..<(names.count - 1) {
                let pair = (names[i], names[i + 1])
                transitions[pair.0] = transitions[pair.0] ?? [:]
                if let value = transitions[pair.0]?[pair.1] {
                    transitions[pair.0]?[pair.1] = value + 1
                } else {
                    transitions[pair.0]?[pair.1] = 1
                }
            }
        }
        
        // Calculate probabilities
        for (prevEx, nextExercises) in transitions {
            let total = Double(nextExercises.values.reduce(0, +))
            transitionProbabilities[prevEx] = [:]
            
            for (nextEx, count) in nextExercises {
                transitionProbabilities[prevEx]?[nextEx] = Double(count) / total
            }
        }
    }
    
    func predictNextWorkout() -> [Workout] {
        var lastWorkoutName: String = WorkoutService.StartOfDayWorkoutToken
        if let mostRecentWorkout = workouts.first,
           Calendar.current.isDateInToday(mostRecentWorkout.date)
        {
            lastWorkoutName = mostRecentWorkout.name
        }
        guard let nextExercises = transitionProbabilities[lastWorkoutName] else {
            return Array(workouts.prefix(10))
        }

        // Sort exercises by probability
        let res = nextExercises.sorted { $0.value > $1.value }.map { $0.key }.compactMap { getMostRecentWorkout(workoutName: $0)}
        return res
    }
    
    func addWorkout(workout: Workout) {
        modelContext.insert(workout)
        workouts.insert(workout, at: 0)
    }
    
    func matchWorkout(workoutName: String) -> [Workout] {
        let finalList = workouts.filter { $0.name.lowercased().contains(workoutName.lowercased())}
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
    
    private func getMostRecentWorkout(workoutName: String) -> Workout? {
        var descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.name == workoutName }, sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }
    
    private func fetchWorkouts() -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
}
