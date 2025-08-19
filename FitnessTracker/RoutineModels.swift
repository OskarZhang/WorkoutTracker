import Foundation
import SwiftData

@Model
class Routine {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var isActive: Bool
    @Relationship(deleteRule: .cascade) var days: [RoutineDay]

    init(name: String, isActive: Bool = false, days: [RoutineDay] = []) {
        self.name = name
        self.isActive = isActive
        self.days = days
    }
}

@Model
class RoutineDay {
    @Attribute(.unique) var id: UUID = UUID()
    var order: Int
    var name: String
    @Relationship(deleteRule: .cascade) var exercises: [RoutineExerciseTemplate]

    init(order: Int, name: String, exercises: [RoutineExerciseTemplate] = []) {
        self.order = order
        self.name = name
        self.exercises = exercises
    }
}

@Model
class RoutineExerciseTemplate {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var tagRaw: String?

    var tag: ExerciseTag? {
        get { tagRaw.flatMap { ExerciseTag(rawValue: $0) } }
        set { tagRaw = newValue?.rawValue }
    }

    init(name: String, tag: ExerciseTag? = nil) {
        self.name = name
        self.tagRaw = tag?.rawValue
    }
}



