import SwiftUI

// The root view, responsible for routing based on goal configuration
struct ContentView: View {
    // Creates and owns the single instance of ActivityViewModel
    @StateObject private var activityViewModel = ActivityViewModel()

    var body: some View {
        Group {
            // Check the isConfigured flag (derived from goal != nil in ViewModel)
            if activityViewModel.isConfigured {
                // Goal exists: Show ActivityView within NavigationStack
                NavigationStack {
                    ActivityView(viewModel: activityViewModel)
                }
            } else {
                // No goal: Show OnboardingView
                // Create its ViewModel here, passing the shared ActivityViewModel
                OnboardingView(viewModel: OnboardingViewModel(activityViewModel: activityViewModel))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
