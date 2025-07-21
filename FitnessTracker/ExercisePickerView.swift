import SwiftUI
import Combine

struct ExercisePickerView: View {
    @Binding var isPresented: Bool
    @Binding var selectedExercise: String

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
        NavigationView {
            VStack {
                List(filteredExercises, id: \.self) { exercise in
                    Button(action: {
                        selectedExercise = exercise
                        isPresented = false
                    }) {
                        Text(exercise)
                    }
                }
                .searchable(text: $searchContext.searchText)
            }
            .navigationTitle("Select Exercise")
            .onAppear(perform: loadExercises)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
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
