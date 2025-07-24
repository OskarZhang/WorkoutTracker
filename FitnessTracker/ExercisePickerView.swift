import SwiftUI
import Combine
import SwiftUIIntrospect

struct ExercisePickerView: View {
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
            List(filteredExercises, id: \.self) { exercise in
                Button(action: {
                    selectedExercise = exercise
                }) {
                    Text(exercise)
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            isNameFocused = true
            loadExercises()
        }
        .navigationBarItems(trailing: Button("Next") {
            selectedExercise = searchContext.searchText
        })
    }

    private func loadExercises() {
        if let path = Bundle.main.path(forResource: "strength_workout_names", ofType: "csv") {
            do {
                let csvString = try String(contentsOfFile: path, encoding: .utf8)
                let lines = csvString.components(separatedBy: .newlines)
                // Skip the header line
                self.allExercises = Array(lines.dropFirst().filter{ !$0.isEmpty })
            } catch {
                print("Failed to load exercises from CSV: \(error)")
            }
        }
    }
}
