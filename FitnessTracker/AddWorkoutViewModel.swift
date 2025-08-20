import Foundation
import Combine

class AddWorkoutViewModel: ObservableObject {
    @Published var selectedExercise: String? {
        didSet {
            if selectedExercise != nil && !hasPrefilledExercise {
                isShowingSetLogging = true
            }
        }
    }
    @Published var sets: [StrengthSet] = []
    @Published var selectedTag: ExerciseTag? = nil

    @Published var isShowingSetLogging = false
    
    let hasPrefilledExercise: Bool

    private let exerciseService: ExerciseService

    init(exerciseService: ExerciseService, prefilledExerciseName: String? = nil) {
        self.exerciseService = exerciseService
        self.hasPrefilledExercise = prefilledExerciseName != nil
        self.selectedExercise = prefilledExerciseName
    }

    func saveWorkout() {
        guard let selectedExercise else {
            return
        }
        let exercise = Exercise(
            name: selectedExercise,
            type: .strength,
            tag: selectedTag,
            sets: sets
        )
        exerciseService.addExercise(exercise)
    }

    func lastExerciseSession() -> [StrengthSet]? {
        if let selectedExercise,
           let lastExercise = exerciseService.lastExerciseSession(matching: selectedExercise)
        {
            return lastExercise.sets
        }
        return nil
    }

    func matchExercise(name: String) -> [Exercise] {
        return exerciseService.getWorkoutSuggestion(exerciseName: name)
    }

    func allStockExercises() -> [Exercise] {
        return exerciseService.exerciseNamesFromCSV.map { name in
            let tag = exerciseService.exerciseNameToTagFromCSV[name] ?? ExerciseService.tagForExerciseName(name)
            return Exercise(name: name, type: .strength, tag: tag)
        }
    }
}
