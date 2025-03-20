//
//  Data.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftData
import SwiftUI

//enum WorkoutType: Codable, Equatable {
//    case strength(weight: Int, repCount: Int, setCount: Int)
//    case cardio(durationMinutes: Int)
//}
//

typealias ExcerciseDataType = Exercise


enum ExerciseType: String, Codable {
    case strength
    case cardio
}

@Model
class Exercise {
    @Attribute(.unique) var id: UUID = UUID()
    var type: ExerciseType
    var name: String
    var date: Date
    var notes: String?

    // Strength-specific
    @Relationship(deleteRule: .cascade) var sets: [StrengthSet]?

    // Cardio-specific
    var distanceInMiles: Double?
    var durationInSeconds: Int?
    var averageHeartRate: Int?

    init(
        date: Date = .now,
        notes: String? = nil,
        name: String,
        type: ExerciseType,
        sets: [StrengthSet]? = nil,
        distanceInMiles: Double? = nil,
        durationInSeconds: Int? = nil,
        averageHeartRate: Int? = nil
    ) {
        self.date = date
        self.notes = notes
        self.name = name
        self.type = type
        self.sets = sets
        self.distanceInMiles = distanceInMiles
        self.durationInSeconds = durationInSeconds
        self.averageHeartRate = averageHeartRate
    }
}

@Model
class StrengthSet {
    var weightInLbs: Double
    var reps: Int
    var restSeconds: Int?
    var rpe: Int?

    init(weightInLbs: Double, reps: Int, restSeconds: Int? = nil, rpe: Int? = nil) {
        self.weightInLbs = weightInLbs
        self.reps = reps
        self.restSeconds = restSeconds
        self.rpe = rpe
    }
}


//enum WorkoutMigrationPlan: SchemaMigrationPlan {
//
//  static var stages: [MigrationStage] {
//      [migrateV1toV2]
//  }
//
//  static var schemas: [any VersionedSchema.Type] {
//    [WorkoutSchemaV1.self, WorkoutSchemaV2.self]
//  }
//
//  // for some reason this migration never gets anything written to the new schema. fucku apple
//    static let migrateV1toV2 = MigrationStage.custom(
//        fromVersion: WorkoutSchemaV1.self,
//        toVersion: WorkoutSchemaV2.self,
//        willMigrate: { context in
//            let oldWorkouts = try context.fetch(FetchDescriptor<WorkoutSchemaV1.Workout>())
//            let newExcercises: [WorkoutSchemaV2.Exercise] = oldWorkouts.compactMap { workout in
//                if case .strength(let weight, let repCount, let setCount) = workout.type {
//                    let sets = (0..<setCount).map { _ in WorkoutSchemaV2.StrengthSet(weightInLbs: Double(weight), reps: repCount, restSeconds: nil) }
//            let excercise = WorkoutSchemaV2.Exercise(date: workout.date, name: workout.name, type: .strength, sets: sets)
//            return excercise
//          }
//          return nil
//        }
//        print(newExcercises)
//        newExcercises.forEach { exercise in
//          context.insert(exercise)
//          print("saving!")
//        }
//
//        try context.save()
//
//      }, didMigrate: nil
//  )
//
//}


extension Exercise {
    var maxWeight: Double {
        sets?.map { $0.weightInLbs }.max() ?? 0.0
    }
    var maxRep: Int {
        sets?.map { $0.reps }.max() ?? 0
    }
}

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
