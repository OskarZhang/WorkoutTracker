//
//  Data.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftData
import SwiftUI

@Model
class Workout {
    var id: UUID
    var name: String
    var type: WorkoutType
    var date: Date
    
    init(id: UUID = UUID(), name: String, type: WorkoutType, date: Date) {
        self.id = id
        self.name = name
        self.type = type
        self.date = date
    }
}

enum WorkoutType: Codable, Equatable {
    case strength(weight: Int, repCount: Int, setCount: Int)
    case cardio(durationMinutes: Int)
}
