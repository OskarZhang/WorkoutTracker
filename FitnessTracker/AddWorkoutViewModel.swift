import Foundation
import Combine

class AddWorkoutViewModel: ObservableObject {
    @Published var selectedExercise: String? {
        didSet {
            if selectedExercise != nil {
                isShowingSetLogging = true
            }
        }
    }
    @Published var sets: [StrengthSet] = []

    @Published var isShowingSetLogging = false

    private let exerciseService: ExerciseService

    init(exerciseService: ExerciseService) {
        self.exerciseService = exerciseService
    }

    func saveWorkout() {
        guard let selectedExercise else {
            return
        }
        let exercise = Exercise(
            name: selectedExercise,
            type: .strength,
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
}
