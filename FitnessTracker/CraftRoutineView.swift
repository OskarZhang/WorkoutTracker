import SwiftUI
import SwiftData

struct CraftRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var routineName: String = "New Routine"
    @State private var routine: Routine?
    @State private var selectedDayId: UUID? = nil
    @State private var isShowingExerciseSheet: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Routine Name")) {
                    TextField("Enter routine name", text: $routineName)
                }

                Section {
                    Button(action: addDay) {
                        Label("Add Day", systemImage: "plus.circle")
                    }
                }

                if let routine {
                    ForEach(routine.days.sorted(by: { $0.order < $1.order })) { day in
                        Section(header: HStack {
                            TextField("Day name", text: Binding(
                                get: { day.name },
                                set: { newValue in
                                    day.name = newValue
                                }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }) {
                            if day.exercises.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Suggested")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    SuggestionsList { name, tag in
                                        addExercise(to: day, name: name, tag: tag)
                                    }
                                    .frame(maxHeight: 180)
                                }
                            } else {
                                ForEach(day.exercises) { ex in
                                    HStack {
                                        Text(ex.name)
                                        if let t = ex.tag {
                                            Spacer()
                                            Text(t.rawValue)
                                                .font(.caption2)
                                                .fontWeight(.semibold)
                                                .padding(.vertical, 2)
                                                .padding(.horizontal, 6)
                                                .background(t.color.opacity(0.15))
                                                .foregroundColor(t.color)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .onDelete { indexSet in
                                    let service = RoutineService(modelContext: modelContext)
                                    service.removeExercise(from: day, at: indexSet)
                                }
                            }

                            Button(action: { selectedDayId = day.id; isShowingExerciseSheet = true }) {
                                Label("Add Exercise", systemImage: "plus")
                            }
                        }
                    }
                    .onMove { indexSet, to in
                        let service = RoutineService(modelContext: modelContext)
                        service.reorderDays(routine, fromOffsets: indexSet, toOffset: to)
                    }
                }
            }

            Button(action: saveRoutine) {
                Text("Save Routine")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding()
            }
        }
        .onAppear(perform: ensureDraft)
        .sheet(isPresented: $isShowingExerciseSheet) {
            ExerciseSearchSheet(onPick: { name, tag in
                guard let routine, let dayId = selectedDayId, let day = routine.days.first(where: { $0.id == dayId }) else { return }
                addExercise(to: day, name: name, tag: tag)
                isShowingExerciseSheet = false
            })
        }
    }

    private func ensureDraft() {
        if routine == nil {
            let service = RoutineService(modelContext: modelContext)
            routine = service.createRoutine(name: routineName)
        }
    }

    private func addDay() {
        guard let routine else { return }
        let defaultNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let service = RoutineService(modelContext: modelContext)
        let nextIndex = routine.days.count
        let name = nextIndex < defaultNames.count ? defaultNames[nextIndex] : "Day \(nextIndex + 1)"
        _ = service.addDay(to: routine, name: name, order: nextIndex)
    }

    private func addExercise(to day: RoutineDay, name: String, tag: ExerciseTag?) {
        let service = RoutineService(modelContext: modelContext)
        service.addExercise(to: day, name: name, tag: tag)
    }

    private func saveRoutine() {
        guard let routine else { return }
        routine.name = routineName
        let service = RoutineService(modelContext: modelContext)
        service.setActiveRoutine(routine)
        service.save()
    }
}

private struct ExerciseSearchSheet: View {
    @Environment(\.modelContext) private var modelContext
    var onPick: (String, ExerciseTag?) -> Void
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search exercise", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                SuggestionsList(query: searchText) { name, tag in
                    onPick(name, tag)
                }
            }
            .navigationTitle("Select Exercise")
        }
    }
}

private struct SuggestionsList: View {
    @Environment(\.modelContext) private var modelContext

    var query: String = ""
    var onSelect: (String, ExerciseTag?) -> Void

    var body: some View {
        let service = ExerciseService(modelContext: modelContext)
        let suggestions = service.getWorkoutSuggestion(exerciseName: query)
        List(suggestions, id: \.id) { ex in
            Button(action: { onSelect(ex.name, ex.tag) }) {
                HStack {
                    Text(ex.name)
                    if let tag = ex.tag {
                        Spacer()
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
        }
        .listStyle(.plain)
    }
}


