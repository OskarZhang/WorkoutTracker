import SwiftData
import Foundation

class TodayRecommendationService {
    private let modelContext: ModelContext
    private let exerciseService: ExerciseService
    
    init(modelContext: ModelContext, exerciseService: ExerciseService) {
        self.modelContext = modelContext
        self.exerciseService = exerciseService
    }
    
    func getTodayRecommendations() -> [Exercise] {
        let allExercises = fetchAllExercises()
        
        if allExercises.isEmpty {
            return getStarterRecommendations()
        }
        
        var recommendations: [Exercise] = []
        
        // Strategy 1: Same day last week
        recommendations.append(contentsOf: getSameDayLastWeekExercises(from: allExercises))
        
        // Strategy 2: Neglected muscle groups (exercises not done this week)
        recommendations.append(contentsOf: getNeglectedExercises(from: allExercises))
        
        // Strategy 3: Use existing Markov chain predictions
        recommendations.append(contentsOf: exerciseService.getWorkoutSuggestion(exerciseName: ""))
        
        // Remove duplicates while preserving order
        var uniqueNames = Set<String>()
        let uniqueRecommendations = recommendations.compactMap { exercise -> Exercise? in
            if uniqueNames.contains(exercise.name) {
                return nil
            }
            uniqueNames.insert(exercise.name)
            return exercise
        }
        
        return Array(uniqueRecommendations.prefix(8))
    }
    
    private func getSameDayLastWeekExercises(from allExercises: [Exercise]) -> [Exercise] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today) else {
            return []
        }
        
        let lastWeekExercises = allExercises.filter { exercise in
            calendar.isDate(exercise.date, inSameDayAs: lastWeek)
        }
        
        // Return most recent version of each unique exercise name
        var uniqueExercises: [String: Exercise] = [:]
        for exercise in lastWeekExercises {
            if let existing = uniqueExercises[exercise.name] {
                if exercise.date > existing.date {
                    uniqueExercises[exercise.name] = exercise
                }
            } else {
                uniqueExercises[exercise.name] = exercise
            }
        }
        
        return Array(uniqueExercises.values).sorted { $0.date > $1.date }
    }
    
    private func getNeglectedExercises(from allExercises: [Exercise]) -> [Exercise] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }
        
        // Get exercises done this week
        let thisWeekExercises = allExercises.filter { exercise in
            exercise.date >= startOfWeek
        }
        let thisWeekNames = Set(thisWeekExercises.map { $0.name })
        
        // Get all unique exercise names from history
        let allExerciseNames = Set(allExercises.map { $0.name })
        
        // Find exercises not done this week
        let neglectedNames = allExerciseNames.subtracting(thisWeekNames)
        
        // Get most recent version of each neglected exercise
        var neglectedExercises: [Exercise] = []
        for name in neglectedNames {
            if let recentExercise = allExercises.first(where: { $0.name == name }) {
                neglectedExercises.append(recentExercise)
            }
        }
        
        // Sort by how long ago they were last performed
        return neglectedExercises.sorted { $0.date < $1.date }.prefix(4).map { $0 }
    }
    
    private func getStarterRecommendations() -> [Exercise] {
        let starterExercises = [
            "Push-ups",
            "Squats", 
            "Pull-ups",
            "Plank",
            "Bench Press",
            "Deadlift"
        ]
        
        return starterExercises.map { Exercise(name: $0, type: .strength) }
    }
    
    private func fetchAllExercises() -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}