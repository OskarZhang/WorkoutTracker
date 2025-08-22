import SwiftUI

struct AddWorkoutView: View {
    @StateObject var viewModel: AddWorkoutViewModel
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>, exerciseService: ExerciseService, prefilledExerciseName: String? = nil) {
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: AddWorkoutViewModel(exerciseService: exerciseService, prefilledExerciseName: prefilledExerciseName))
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.hasPrefilledExercise {
                    SetLoggingView(
                        sets: viewModel.lastExerciseSession(),
                        isPresented: $isPresented,
                        exerciseName: viewModel.selectedExercise ?? "",
                        onSave: { sets in
                            viewModel.sets = sets
                            viewModel.saveWorkout()
                            isPresented = false
                        }
                    )
                } else {
                    VStack {
                        ExercisePickerView(
                            viewModel: viewModel,
                            isPresented: $isPresented,
                            selectedExercise: Binding(
                                get: { viewModel.selectedExercise ?? "" },
                                set: { viewModel.selectedExercise = $0 }
                            )
                        )
                        NavigationLink(
                            destination: SetLoggingView(
                                sets: viewModel.lastExerciseSession(),
                                isPresented: $viewModel.isShowingSetLogging,
                                exerciseName: viewModel.selectedExercise ?? "",
                                onSave: { sets in
                                    viewModel.sets = sets
                                    viewModel.saveWorkout()
                                    viewModel.isShowingSetLogging = false
                                    isPresented = false
                                }
                            ),
                            isActive: $viewModel.isShowingSetLogging
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}
