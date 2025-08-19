import Foundation
import SwiftData

struct RoutineService {
    let modelContext: ModelContext

    func fetchActiveRoutine() -> Routine? {
        var descriptor = FetchDescriptor<Routine>(predicate: #Predicate { $0.isActive == true })
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    func fetchAllRoutines() -> [Routine] {
        let descriptor = FetchDescriptor<Routine>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func createRoutine(name: String) -> Routine {
        let routine = Routine(name: name, isActive: false, days: [])
        modelContext.insert(routine)
        return routine
    }

    func addDay(to routine: Routine, name: String, order: Int) -> RoutineDay {
        let day = RoutineDay(order: order, name: name, exercises: [])
        routine.days.append(day)
        return day
    }

    func renameDay(_ day: RoutineDay, to newName: String) {
        day.name = newName
    }

    func addExercise(to day: RoutineDay, name: String, tag: ExerciseTag?) {
        let exercise = RoutineExerciseTemplate(name: name, tag: tag)
        day.exercises.append(exercise)
    }

    func removeExercise(from day: RoutineDay, at indexSet: IndexSet) {
        day.exercises.remove(atOffsets: indexSet)
    }

    func reorderDays(_ routine: Routine, fromOffsets: IndexSet, toOffset: Int) {
        routine.days.sort { $0.order < $1.order }
        routine.days.move(fromOffsets: fromOffsets, toOffset: toOffset)
        for (i, day) in routine.days.enumerated() {
            day.order = i
        }
    }

    func setActiveRoutine(_ routine: Routine) {
        let all = fetchAllRoutines()
        for r in all {
            r.isActive = (r.id == routine.id)
        }
    }

    func save() {
        try? modelContext.save()
    }
}



