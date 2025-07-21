import SwiftUI

struct AddWorkoutView: View {
    @State private var showingExercisePicker = true
    @State private var showingSetLogging = false
    @State private var selectedExercise: String = ""

    @Binding var isPresented: Bool
    let exerciseService: ExerciseService

    var body: some View {
        VStack {
            EmptyView()
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(
                isPresented: $showingExercisePicker,
                selectedExercise: $selectedExercise
            )
            .onDisappear(perform: {
                if !selectedExercise.isEmpty {
                    showingSetLogging = true
                } else {
                    isPresented = false
                }
            })
        }
        .sheet(isPresented: $showingSetLogging) {
            SetLoggingView(
                isPresented: $showingSetLogging,
                exerciseName: selectedExercise,
                onSave: { sets in
                    let exercise = Exercise(
                        name: selectedExercise,
                        type: .strength,
                        sets: sets
                    )
                    exerciseService.addExercise(exercise)
                    isPresented = false
                }
            )
        }
    }
}
