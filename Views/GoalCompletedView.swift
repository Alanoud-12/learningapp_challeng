import SwiftUI

// Standalone view primarily for previewing the goal completed state.
// The main display logic is handled by GoalCompletedContentView inside ActivityView.
struct GoalCompletedView: View {
    // Properties needed for display in preview
    let topic: String
    let days: Int
    // Callbacks are placeholders here
    var onSetNewGoal: () -> Void = { print("Preview: Set new goal") }
    var onRepeatGoal: () -> Void = { print("Preview: Repeat goal") }

    var body: some View {
        ZStack {
            Color.themeBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer(minLength: 50)
                Image(systemName: "hands.and.sparkles.fill")
                    .font(.system(size: 50)).foregroundColor(.themeOrange).padding(.bottom, 5)
                Text("Well done!").font(.title2).fontWeight(.bold).foregroundColor(.themeText)
                Text("Goal completed! You learned **\(topic)** for **\(days.dayPlural)**.")
                    .font(.footnote).foregroundColor(.themeSubtleText)
                    .multilineTextAlignment(.center).padding(.horizontal, 40).padding(.bottom, 15)

                // Example Buttons (Non-functional placeholders for preview)
                Button("Set new learning goal") { onSetNewGoal() }
                .fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Color.themeOrange).foregroundColor(.themeText).cornerRadius(14)

                Button("Set same learning goal") { onRepeatGoal() }
                .font(.caption).fontWeight(.medium).foregroundColor(.themeOrange).padding(.top, 0)

                Spacer()
            }
            .padding(.horizontal, 30).padding(.vertical, 40)
        }
    }
}

// MARK: - Preview
#Preview {
    GoalCompletedView(topic: "SwiftUI Mastery", days: 30)
    .preferredColorScheme(.dark)
}
