import SwiftUI
import Combine
import SwiftUIIntrospect

struct ExercisePickerView: View {
    @StateObject var viewModel: AddWorkoutViewModel

    @Binding var isPresented: Bool
    @Binding var selectedExercise: String

    @FocusState private var isNameFocused
    @State private var hasSetInitialFocus = false

    @StateObject private var searchContext = SearchContext()
    @State private var allExercises: [String] = []




    var filteredExercises: [String] {
        if searchContext.debouncedSearchText.isEmpty {
            return allExercises
        } else {
            return allExercises.filter { $0.lowercased().contains(searchContext.debouncedSearchText.lowercased()) }
        }
    }

    var body: some View {
        VStack {
            TextField("Enter exercise", text: $searchContext.searchText)
                .textFieldStyle(.plain)
                .listRowSeparator(.hidden)
                .autocorrectionDisabled(true)
                .padding()
                .focused($isNameFocused)
                .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18), customize: { textField in
                    if !hasSetInitialFocus && isPresented {
                        textField.becomeFirstResponder()
                        hasSetInitialFocus = true
                    }
                })
                .onSubmit {
                    selectedExercise = searchContext.searchText
                }

            Divider()
            List(viewModel.matchExercise(name: searchContext.searchText), id: \.self) { exercise in
                Button(action: {
                    selectedExercise = exercise.name
                }) {
                    Text(exercise.name)
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            isNameFocused = true

        }
        .navigationBarItems(trailing: Button("Next") {
            selectedExercise = searchContext.searchText
        })
    }

}
