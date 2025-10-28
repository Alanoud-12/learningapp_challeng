import SwiftUI
import Combine
import Foundation

// Main ObservableObject holding the application's state and logic
class ActivityViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Persisted State (@AppStorage)
    @AppStorage("learningAppV1Data") private var appDataEncoded: Data = Data()
    private let persistenceEnabled: Bool = true // Toggle persistence on/off

    // MARK: - Published Properties (Drive UI Updates)
    @Published private(set) var appData: AppData = AppData()
    @Published var selectedDate: Date = Date().startOfDay // For calendar interaction

    // Derived flags for routing and UI state changes
    @Published private(set) var isConfigured: Bool = false
    @Published private(set) var isGoalCompleted: Bool = false

    // MARK: - Initialization & Persistence
    init() {
        decodeData() // Load saved data on launch (no-op if disabled)
        setupSubscriptions() // Set up Combine pipelines (save is no-op if disabled)
        // Ensure initial state reflects loaded data
        selectedDate = Date().startOfDay
        checkGoalCompletion() // Initial completion check
        print("ViewModel Initialized. Goal set: \(isConfigured). Goal completed: \(isGoalCompleted). Freezes: \(appData.freezesUsed)/\(maxFreezes)")
    }

    private func decodeData() {
        guard persistenceEnabled else {
            self.appData = AppData()
            self.isConfigured = false
            checkGoalCompletion()
            return
        }
        if let decoded = try? JSONDecoder().decode(AppData.self, from: appDataEncoded) {
            self.appData = decoded
        } else {
            self.appData = AppData() // Start fresh if no data or error
        }
        // Immediately update derived properties based on loaded data
        self.isConfigured = self.appData.goal != nil
        checkGoalCompletion()
    }

    private func saveData() {
        guard persistenceEnabled else { return }
        if let encoded = try? JSONEncoder().encode(appData) {
            appDataEncoded = encoded
        }
    }

    private func setupSubscriptions() {
        // Automatically save data when appData changes (after a short delay)
        if persistenceEnabled {
            $appData
                .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in self?.saveData() }
                .store(in: &cancellables)
        }

        // Update isConfigured flag based on goal presence
        $appData
            .map { $0.goal != nil }
            .removeDuplicates()
            .assign(to: \.isConfigured, on: self)
            .store(in: &cancellables)

        // Update isGoalCompleted flag based on learned days vs target
        $appData
            .map { data -> Bool in
                guard let goal = data.goal else { return false }
                let learnedCount = data.streakHistory.values.filter { $0 == .learned }.count
                return learnedCount >= goal.duration.targetDays
            }
            .removeDuplicates()
            .assign(to: \.isGoalCompleted, on: self)
            .store(in: &cancellables)
    }

    // Recalculates goal completion status.
    private func checkGoalCompletion() {
        guard let goal = appData.goal else {
            if isGoalCompleted { isGoalCompleted = false }
            return
        }
        let learnedCount = appData.streakHistory.values.filter { $0 == .learned }.count
        let completed = learnedCount >= goal.duration.targetDays
        if isGoalCompleted != completed { isGoalCompleted = completed }
    }

    // Public function for views to call on appear if needed
    func refreshDataOnAppear() {
         decodeData()
         selectedDate = Date().startOfDay
         print("Data refreshed on appear.")
    }

    // MARK: - Goal Management
    func setGoal(topic: String, duration: LearningDuration) {
        let newGoal = Goal(topic: topic, duration: duration, startDate: Date().startOfDay)
        var nextData = appData
        if let existing = nextData.goal { nextData.goalsHistory.append(existing) }
        nextData.goal = newGoal
        nextData.streakHistory = [:]
        nextData.freezesUsed = 0
        appData = nextData // Reset but keep history
        selectedDate = Date().startOfDay
        print("New goal set: \(topic), Duration: \(duration.rawValue)")
    }

    func repeatGoal() {
        guard let currentGoal = appData.goal else { return }
        setGoal(topic: currentGoal.topic, duration: currentGoal.duration)
        print("Goal repeated: \(currentGoal.topic)")
    }

    // Implicitly handled by setGoal, but could add an explicit reset if needed
    // func clearGoalAndReset() { ... }

    // MARK: - Computed Properties for UI Display
    var currentLearningTopic: String { appData.goal?.topic ?? "No Goal Set" }
    var learningDuration: LearningDuration? { appData.goal?.duration }
    var daysLearned: Int { appData.streakHistory.values.filter { $0 == .learned }.count }
    var maxFreezes: Int { appData.goal?.duration.maxFreezes ?? 0 }
    var freezesUsedDisplay: Int { appData.freezesUsed }
    var freezesRemaining: Int { maxFreezes - appData.freezesUsed }
    
    // Grammar helpers for proper singular/plural display
    var learnedPlural: String { daysLearned == 1 ? "Day" : "Days" }
    var freezedPlural: String { freezesUsedDisplay == 1 ? "Day" : "Days" }

    func getStatus(for date: Date) -> DayStatus {
        appData.streakHistory[date.startOfDay] ?? .none // Use .none default
    }

    func isDayLogged(for date: Date) -> Bool {
        getStatus(for: date) != .none // Check against .none
    }

    // Button disabling logic for the SELECTED date
    var isLogLearnedButtonDisabled: Bool {
        isDayLogged(for: selectedDate) || isGoalCompleted || selectedDate.startOfDay > Date().startOfDay
    }
    var isLogFreezedButtonDisabled: Bool {
        isDayLogged(for: selectedDate) || freezesRemaining <= 0 || isGoalCompleted || selectedDate.startOfDay > Date().startOfDay
    }

    // MARK: - Daily Logging Actions (Apply to SELECTED date)
    func logDayAsLearned() {
        let dayToLog = selectedDate.startOfDay
        guard !isLogLearnedButtonDisabled else { return }

        var updatedData = appData
        updatedData.streakHistory[dayToLog] = .learned
        appData = updatedData // Triggers save

        checkGoalCompletion() // Re-check
        print("Logged \(dayToLog.formatted(.dateTime.day().month().year())) as Learned.")

        // Advance selection to next day (to the right) after logging
        // Advance selection to next day, but never exceed today
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            let clamped = min(nextDay.startOfDay, Date().startOfDay)
            selectedDate = clamped
        }
    }

    func logDayAsFreezed() {
        let dayToLog = selectedDate.startOfDay
        guard !isLogFreezedButtonDisabled else { return }

        var updatedData = appData
        updatedData.streakHistory[dayToLog] = .freezed
        updatedData.freezesUsed += 1
        appData = updatedData // Triggers save

        print("Logged \(dayToLog.formatted(.dateTime.day().month().year())) as Freezed. Freezes used: \(appData.freezesUsed)")
    }

    // MARK: - Reset / Clear Persistence
    func clearAllAppData() {
        appData = AppData()
        if persistenceEnabled {
            appDataEncoded = Data()
        }
        selectedDate = Date().startOfDay
        isGoalCompleted = false
        isConfigured = false
    }

    // MARK: - Calendar Navigation
    func changeWeek(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: offset * 7, to: selectedDate) {
            selectedDate = newDate.startOfDay
        }
    }

    func changeMonth(by offset: Int) {
        // Logic to change month while trying to preserve day (handles end-of-month)
         if let newMonthDate = Calendar.current.date(byAdding: .month, value: offset, to: selectedDate) {
             let calendar = Calendar.current
             let currentDay = calendar.component(.day, from: selectedDate)
             var targetComponents = calendar.dateComponents([.year, .month], from: newMonthDate)
             targetComponents.day = currentDay

             if let candidateDate = calendar.date(from: targetComponents),
                let range = calendar.range(of: .day, in: .month, for: newMonthDate),
                currentDay <= range.count {
                 selectedDate = candidateDate.startOfDay // Day exists in new month
             } else {
                 // Day doesn't exist, go to last day of target month
                 if let startOfMonth = newMonthDate.startOfMonth,
                    let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) {
                     selectedDate = endOfMonth.startOfDay
                 } else {
                     selectedDate = newMonthDate.startOfDay // Fallback
                 }
             }
         }
     }
}

// Helper extension for startOfMonth calculation, private to this file
fileprivate extension Date {
    var startOfMonth: Date? {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))
    }
}
