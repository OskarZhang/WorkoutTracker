import SwiftUI

struct AddWorkoutView: View {
    @StateObject private var viewModel: AddWorkoutViewModel
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>, exerciseService: ExerciseService) {
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: AddWorkoutViewModel(exerciseService: exerciseService))
    }

    var body: some View {
        NavigationView {
            VStack {
                ExercisePickerView(
                    isPresented: $isPresented,
                    selectedExercise: Binding(
                        get: { viewModel.selectedExercise ?? "" },
                        set: { viewModel.selectedExercise = $0 }
                    )
                )
                NavigationLink(
                    destination: SetLoggingView(
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
