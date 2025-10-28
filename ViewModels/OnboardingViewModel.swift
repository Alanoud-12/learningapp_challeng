import SwiftUI
import Combine

// ViewModel specific to the OnboardingView's state and actions
class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties (Bound to UI controls)
    @Published var topic: String
    @Published var duration: LearningDuration

    // MARK: - Dependencies
    private let activityViewModel: ActivityViewModel // Reference to main state

    // MARK: - Callbacks
    var onComplete: (() -> Void)? // For dismissing sheet

    // MARK: - Initialization
    init(activityViewModel: ActivityViewModel, initialTopic: String = "", initialDuration: LearningDuration? = nil, onComplete: (() -> Void)? = nil) {
        self.activityViewModel = activityViewModel
        // Initialize @Published properties correctly
        _topic = Published(initialValue: initialTopic)
        _duration = Published(initialValue: initialDuration ?? .month) // Default to month
        self.onComplete = onComplete
    }

    // MARK: - Computed Properties for UI Logic
    var isStartButtonEnabled: Bool {
        !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions
    /// Called when the user taps "Start Learning" or "Update Goal"
    func startLearning() {
        let cleanedTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTopic.isEmpty else { return } // Prevent empty goals

        // Tell the main ActivityViewModel to set/update the goal
        activityViewModel.setGoal(topic: cleanedTopic, duration: duration)

        // Dismiss the view if presented modally
        onComplete?()
    }
}
