import Foundation
import SwiftData

enum UserGoal: String, Codable, CaseIterable, Identifiable {
    case gain
    case lose
    case recomp

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .gain: return "Gain Weight"
        case .lose: return "Lose Weight"
        case .recomp: return "Recomp"
        }
    }
}

@Model
class UserProfile {
    @Attribute(.unique) var id: UUID = UUID()
    var heightCm: Int
    var weightKg: Int
    var age: Int
    private var goalRaw: String
    var gymDaysPerWeek: Int
    var createdAt: Date
    var updatedAt: Date

    var goal: UserGoal {
        get { UserGoal(rawValue: goalRaw) ?? .recomp }
        set { goalRaw = newValue.rawValue }
    }

    init(heightCm: Int, weightKg: Int, age: Int, goal: UserGoal, gymDaysPerWeek: Int, createdAt: Date = .now, updatedAt: Date = .now) {
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.age = age
        self.goalRaw = goal.rawValue
        self.gymDaysPerWeek = gymDaysPerWeek
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


