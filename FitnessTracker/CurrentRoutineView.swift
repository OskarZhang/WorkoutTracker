import SwiftUI
import SwiftData

struct CurrentRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var activeRoutine: Routine?

    @State private var isShowingSetLogging: Bool = false
    @State private var loggingExerciseName: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            if let routine = activeRoutine {
                List {
                    ForEach(routine.days.sorted(by: { $0.order < $1.order })) { day in
                        Section(header: Text(day.name).font(.headline)) {
                            if day.exercises.isEmpty {
                                Text("No exercises added")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(day.exercises) { ex in
                                    HStack(spacing: 8) {
                                        Text(ex.name)
                                        if let t = ex.tag {
                                            Text(t.rawValue)
                                                .font(.caption2)
                                                .fontWeight(.semibold)
                                                .padding(.vertical, 2)
                                                .padding(.horizontal, 6)
                                                .background(t.color.opacity(0.15))
                                                .foregroundColor(t.color)
                                                .clipShape(Capsule())
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.secondary)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        loggingExerciseName = ex.name
                                        isShowingSetLogging = true
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                VStack(spacing: 12) {
                    Text("No current routine")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("Create a routine in the Craft Routine tab.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear(perform: load)
        .sheet(isPresented: $isShowingSetLogging) {
            let exerciseService = ExerciseService(modelContext: modelContext)
            let lastSets = exerciseService.lastExerciseSession(matching: loggingExerciseName)?.sets
            SetLoggingView(
                sets: lastSets,
                isPresented: $isShowingSetLogging,
                exerciseName: loggingExerciseName,
                onSave: { sets in
                    print("[Routine] Saving exercise \(loggingExerciseName) with \(sets.count) sets")
                    let rebuiltSets = sets.map { s in
                        StrengthSet(weightInLbs: s.weightInLbs, reps: s.reps, restSeconds: s.restSeconds, rpe: s.rpe)
                    }
                    let newExercise = Exercise(
                        date: .now,
                        name: loggingExerciseName,
                        type: .strength,
                        tag: ExerciseService.tagForExerciseName(loggingExerciseName),
                        sets: rebuiltSets
                    )
                    exerciseService.addExercise(newExercise)
                    print("[Routine] Saved exercise")
                }
            )
        }
    }

    private func load() {
        let service = RoutineService(modelContext: modelContext)
        activeRoutine = service.fetchActiveRoutine()
    }
}


