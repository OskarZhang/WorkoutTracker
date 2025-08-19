import SwiftData
import Foundation

class ExerciseService {

    static private let StartOfDayWorkoutToken: String = "StartOfDay"

    private let modelContext: ModelContext

    private var transitions: [String: [String: Int]] = [:]
    private var transitionProbabilities: [String: [String: Double]] = [:]
    private var exercises: [Exercise] = []


    lazy var exerciseNamesFromCSV: [String] = {
        guard let url = Bundle.main.url(forResource: "strength_workout_names", withExtension: "csv") else {
            print("CSV file not found")
            return []
        }
        do {
            let content = try String(contentsOf: url)
            var lines = content.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            guard !lines.isEmpty else { return [] }
            let header = lines.removeFirst().lowercased()
            if header.contains(",") {
                // Name,Tag format
                return lines.compactMap { row in
                    let parts = row.split(separator: ",", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
                    return parts.first
                }
            } else {
                // Single column of names
                return lines
            }
        } catch {
            print("Error reading CSV: \(error)")
            return []
        }
    }()

    lazy var exerciseNameToTagFromCSV: [String: ExerciseTag] = {
        guard let url = Bundle.main.url(forResource: "strength_workout_names", withExtension: "csv") else {
            return [:]
        }
        do {
            let content = try String(contentsOf: url)
            var lines = content.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            guard !lines.isEmpty else { return [:] }
            let header = lines.removeFirst().lowercased()
            var mapping: [String: ExerciseTag] = [:]
            if header.contains(",") {
                for row in lines {
                    let parts = row.split(separator: ",", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
                    guard parts.count == 2 else { continue }
                    let name = parts[0]
                    let tag = ExerciseTag(rawValue: parts[1]) ?? ExerciseService.tagForExerciseName(name)
                    mapping[name] = tag
                }
            }
            return mapping
        } catch {
            return [:]
        }
    }()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.exercises = fetchWorkouts()
        Task {
            await buildTransitionProbabilityMatrix(data: self.exercises)
        }
        Task { await backfillTagsIfNeeded() }
    }

    static func tagForExerciseName(_ name: String) -> ExerciseTag {
        let n = name.lowercased()
        func contains(_ terms: [String]) -> Bool { terms.first { n.contains($0) } != nil }

        if contains(["crunch", "plank", "russian twist", "leg raise", "knee raise", "dragon flag", "cable crunch", "woodchopper", "ab wheel"]) {
            return .abs
        }
        if contains(["trx push-up"]) { return .chest }
        if contains(["bench press", "incline bench", "decline bench", "close grip bench press", "push-up", "push up", "machine chest press", "pec deck", "dumbbell fly", "cable fly", "chest supported fly"]) {
            return .chest
        }
        if contains(["overhead press", "shoulder press", "arnold press", "lateral raise", "front raise", "upright row", "plate front raise", "cuban press", "push press", "landmine press"]) {
            return .shoulders
        }
        if contains(["curl", "bicep", "tricep", "skullcrusher", "tate press", "dip", "wrist curl", "reverse wrist curl", "plate pinch"]) {
            return .arms
        }
        if contains(["squat", "lunge", "leg press", "leg extension", "leg curl", "calf", "step up", "pistol squat", "hack squat", "split squat", "box squat", "nordic curl", "sissy squat"]) {
            return .legs
        }
        if contains(["hip thrust", "glute", "hip abductor", "hip adductor"]) {
            return .glutes
        }
        if contains(["trx row"]) { return .back }
        if contains(["deadlift", "row", "pulldown", "pull-up", "chin-up", "face pull", "reverse fly", "shrug", "rack pull", "meadows row", "pendlay row", "t-bar row", "renegade row", "seated row", "lat pulldown", "machine row", "machine pullover", "chest supported row", "band pull apart", "band pull down", "landmine row", "good morning"]) {
            return .back
        }
        if contains(["clean", "snatch", "jerk", "turkish get-up", "farmer's walk", "suitcase carry", "carry"]) {
            return .fullBody
        }
        if contains(["sled", "battle rope", "kettlebell swing"]) {
            return .cardio
        }
        if contains(["kettlebell"]) {
            return .fullBody
        }
        if contains(["trx"]) {
            return .fullBody
        }
        if contains(["smith machine press"]) { return .chest }
        if contains(["smith machine squat"]) { return .legs }
        if contains(["smith machine row"]) { return .back }

        return .other
    }

    private func backfillTagsIfNeeded() async {
        var didChange = false
        for exercise in exercises where exercise.tag == nil {
            exercise.tag = ExerciseService.tagForExerciseName(exercise.name)
            didChange = true
        }
        if didChange {
            try? modelContext.save()
        }
    }

    /// build a Markov Chain prediction matrix with exercise data
    private func buildTransitionProbabilityMatrix(data: [Exercise]) async {
        // Group exercises by date
        let calendar = Calendar.current
        let groupedByDate = Dictionary(grouping: data) { entry in
            calendar.startOfDay(for: entry.date)
        }

        // Calculate transitions
        for (_, exercises) in groupedByDate {
            let sortedExercises = exercises.sorted { $0.date < $1.date }

            // allows us to also
            let names = [""] + sortedExercises.map { $0.name }

            for idx in 0..<(names.count - 1) {
                let pair = (names[idx], names[idx + 1])
                transitions[pair.0] = transitions[pair.0] ?? [:]
                if let value = transitions[pair.0]?[pair.1] {
                    transitions[pair.0]?[pair.1] = value + 1
                } else {
                    transitions[pair.0]?[pair.1] = 1
                }
            }
        }

        // Calculate probabilities
        for (prevEx, nextExercises) in transitions {
            let total = Double(nextExercises.values.reduce(0, +))
            transitionProbabilities[prevEx] = [:]

            for (nextEx, count) in nextExercises {
                transitionProbabilities[prevEx]?[nextEx] = Double(count) / total
            }
        }
    }

    func getWorkoutSuggestion(exerciseName: String) -> [Exercise] {
        if exerciseName.isEmpty && exercises.isEmpty {
            // completely new user we just return the stock exercise names
            return exerciseNamesFromCSV.map {
                let tag = exerciseNameToTagFromCSV[$0] ?? ExerciseService.tagForExerciseName($0)
                return Exercise(name: $0, type: .strength, tag: tag)
            }
        } else if exerciseName.isEmpty {
            return predictNextWorkout()
        } else {
            return matchWorkout(exerciseName: exerciseName)
        }
    }

    func lastExerciseSession(matching name: String) -> Exercise? {
        return exercises.filter { $0.name.lowercased() == name.lowercased()}.first
    }

    private func predictNextWorkout() -> [Exercise] {
        var lastWorkoutName: String = ExerciseService.StartOfDayWorkoutToken
        if let mostRecentWorkout = exercises.first,
           Calendar.current.isDateInToday(mostRecentWorkout.date) {
            lastWorkoutName = mostRecentWorkout.name
        }
        guard let nextExercises = transitionProbabilities[lastWorkoutName] else {
            return Array(exercises.prefix(10))
        }

        // Sort exercises by probability
        let res = nextExercises.sorted { $0.value > $1.value }.map { $0.key }.compactMap { getMostRecentWorkout(exerciseName: $0)}

        return res
    }

    func addExercise(_ exercise: Exercise) {
        modelContext.insert(exercise)
        exercises.insert(exercise, at: 0)
        try? modelContext.save()
    }

    private func matchWorkout(exerciseName: String) -> [Exercise] {
        let existingWorkoutMatch = exercises.filter { $0.name.lowercased().contains(exerciseName.lowercased())}
            .reduce((uniqueWorkoutNames: Set<String>(), list: [Exercise]())) { partialResult, exercise in
                if partialResult.uniqueWorkoutNames.contains(exercise.name) {
                    return partialResult
                }
                var uniqueNames = partialResult.uniqueWorkoutNames
                var list = partialResult.list
                list.append(exercise)
                uniqueNames.insert(exercise.name)
                return (uniqueNames, list)
            }
            .list
        if existingWorkoutMatch.count == 1 && exerciseName == existingWorkoutMatch.first?.name {
            // no need to provide suggestions for the exact match
            return []
        }

        let stockWorkoutMatch = exerciseNamesFromCSV.filter { $0.lowercased().contains(exerciseName.lowercased()) }.map {
            let tag = exerciseNameToTagFromCSV[$0] ?? ExerciseService.tagForExerciseName($0)
            return Exercise(name: $0, type: .strength, tag: tag)
        }

        return existingWorkoutMatch + stockWorkoutMatch
    }

    private func getMostRecentWorkout(exerciseName: String) -> Exercise? {
        var descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == exerciseName }, sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    private func fetchWorkouts() -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

}
