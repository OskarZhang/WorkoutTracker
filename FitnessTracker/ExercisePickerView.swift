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

    let confirmationImpact = UIImpactFeedbackGenerator(style: .medium)


    var filteredExercises: [Exercise] {
        let source: [Exercise]
        if searchContext.debouncedSearchText.isEmpty {
            source = viewModel.allStockExercises()
        } else {
            source = viewModel.matchExercise(name: searchContext.debouncedSearchText)
        }
        return filteredByTag(source)
    }

    var body: some View {
        VStack {

            TextField("Enter exercise", text: $searchContext.searchText)
                .textFieldStyle(.plain)
                .listRowSeparator(.hidden)
                .autocorrectionDisabled(true)
                .font(.system(size: 28))
                .fontWeight(.medium)

                .padding()
                .focused($isNameFocused)
                .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18), customize: { textField in
                    if !hasSetInitialFocus && isPresented {
                        textField.becomeFirstResponder()
                        hasSetInitialFocus = true
                    }
                })
                .onSubmit {
                    if searchContext.searchText.isEmpty {
                        isNameFocused = true
                        return
                    }
                    selectedExercise = searchContext.searchText
                    confirmationImpact.impactOccurred()
                }
                .padding(.top, 8)

            HStack {
                Menu {
                    Picker("Tag", selection: Binding(
                        get: { viewModel.selectedTag ?? .other },
                        set: { viewModel.selectedTag = $0 }
                    )) {
                        ForEach(ExerciseTag.allCases, id: \.self) { tag in
                            Text(tag.rawValue).tag(tag)
                        }
                    }
                } label: {
                    Label(viewModel.selectedTag?.rawValue ?? "Filter by Tag", systemImage: "line.3.horizontal.decrease.circle")
                }
                Spacer()
            }
            .padding(.horizontal)

            List(filteredExercises, id: \.self) { exercise in
                Button(action: {
                    selectedExercise = exercise.name
                    confirmationImpact.impactOccurred()
                }) {
                    HStack(spacing: 8) {
                        Text(exercise.name)
                            .font(.system(size: 18))
                        if let tag = exercise.tag {
                            Text(tag.rawValue)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 6)
                                .background(tag.color.opacity(0.15))
                                .foregroundColor(tag.color)
                                .clipShape(Capsule())
                        }
                    }
                }
                .listRowSeparator(.hidden)

            }
            .listStyle(.plain)
        }
        .onAppear {
            isNameFocused = true

        }
    }

    private func filteredByTag(_ exercises: [Exercise]) -> [Exercise] {
        guard let selectedTag = viewModel.selectedTag else { return exercises }
        return exercises.filter { $0.tag ?? ExerciseService.tagForExerciseName($0.name) == selectedTag }
    }

}
