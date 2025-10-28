import Foundation

// MARK: - Enums

/// Defines the goal duration. Conforms to Codable for persistence.
enum LearningDuration: String, CaseIterable, Codable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { self.rawValue }

    /// Max freezes allowed per duration (Dev Note: 2, 8, 96)
    var maxFreezes: Int {
        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }

    /// Target learned days for goal completion.
    var targetDays: Int {
        switch self {
        case .week: return 7
        case .month: return 30 // Approximation
        case .year: return 365 // Approximation
        }
    }
}

/// Status of a specific day. Codable for persistence.
enum DayStatus: String, Codable {
    case learned  // Day was learned
    case freezed  // Day was freezed
    case none      // Day not logged yet
}

// MARK: - Data Models

/// Represents the learning goal. Codable for persistence.
struct Goal: Codable, Equatable {
    let topic: String
    let duration: LearningDuration
    let startDate: Date // Automatically Codable

    // Equatable needed for state comparison
    static func == (lhs: Goal, rhs: Goal) -> Bool {
        return lhs.topic == rhs.topic && lhs.duration == rhs.duration && lhs.startDate == rhs.startDate
    }
}

/// Holds all persistent app data. Codable for persistence via AppStorage.
struct AppData: Codable {
    var goal: Goal? = nil
    var streakHistory: [Date: DayStatus] = [:] // Key is startOfDay Date
    var freezesUsed: Int = 0
    var goalsHistory: [Goal] = [] // All goals created by the user

    // Default initializer for creating an empty state
    init(goal: Goal? = nil, streakHistory: [Date : DayStatus] = [:], freezesUsed: Int = 0, goalsHistory: [Goal] = []) {
        self.goal = goal
        self.streakHistory = streakHistory
        self.freezesUsed = freezesUsed
        self.goalsHistory = goalsHistory
    }
}
