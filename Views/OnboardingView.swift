import SwiftUI

struct OnboardingView: View {
    // ViewModel is created by the parent (ContentView or sheet presenter)
    @StateObject var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            Color.themeBackground.edgesIgnoringSafeArea(.all)

            // Subtle background decorative elements
            Circle()
                .fill(Color.themeOrange.opacity(0.15)).blur(radius: 120)
                .offset(x: -180, y: -300).allowsHitTesting(false)
             Circle()
                .fill(Color.themeTeal.opacity(0.1)).blur(radius: 100)
                .offset(x: 150, y: 200).allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 25) {
                Spacer(minLength: 50)
                // Logo/Icon - Matches design 1.png
                HStack {
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.themeOrange)
                        .padding(20)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: Gradient(colors: [
                                                    Color.themeOrange.opacity(0.3),
                                                    Color.themeOrange.opacity(0.05)
                                                ]),
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 60
                                            )
                                        )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    Spacer()
                }.padding(.bottom, 20)

                // Header Text
                Text("Hello Learner").font(.largeTitle).bold().foregroundColor(.themeText)
                Text("This app will help you learn everyday!").font(.callout).foregroundColor(.themeSubtleText)
                    .padding(.bottom, 30)

                // Topic Input - Underline style
                VStack(alignment: .leading, spacing: 5) {
                    Text("I want to learn").font(.subheadline).fontWeight(.medium).foregroundColor(.themeText)
                    HStack {
                        TextField("", text: $viewModel.topic)
                            .foregroundColor(.themeText).accentColor(.themeOrange).padding(.vertical, 8)
                            .placeholder(when: viewModel.topic.isEmpty) {
                                Text("").foregroundColor(.themeSubtleText.opacity(0.7))
                             }
                         if !viewModel.topic.isEmpty {
                             Button { viewModel.topic = "" } label: {
                                 Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                             }.padding(.leading, 5)
                         }
                    }
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.themeSubtleText.opacity(0.5)), alignment: .bottom)
                }

                // Duration Selector - Button style
                VStack(alignment: .leading, spacing: 8) {
                    Text("I want to learn it in a")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.themeText)
                    HStack(spacing: 12) {
                        ForEach(LearningDuration.allCases) { duration in
                            Button(duration.rawValue) { viewModel.duration = duration }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    Group {
                                        if viewModel.duration == duration {
                                            ZStack {
                                                Color.themeOrange
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.15),
                                                        Color.clear
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            }
                                        } else {
                                            Color.themeCardBackground
                                        }
                                    }
                                )
                                .foregroundColor(.themeText)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.duration == duration
                                                ? Color.themeOrange.opacity(0.5)
                                                : Color.white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .animation(.easeInOut(duration: 0.2), value: viewModel.duration)
                        }
                    }
                }
                .padding(.top, 15)

                Spacer()

                // Start Button
                Button(action: viewModel.startLearning) {
                    Text("Start learning")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                Color.themeOrange
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .foregroundColor(.themeText)
                        .cornerRadius(14)
                }
                .disabled(!viewModel.isStartButtonEnabled)
                .opacity(viewModel.isStartButtonEnabled ? 1.0 : 0.5)
                .padding(.bottom, 30)

            }
            .padding(.horizontal, 30)
        }
         .interactiveDismissDisabled() // Prevent sheet dismissal
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(viewModel: OnboardingViewModel(activityViewModel: ActivityViewModel()))
        .preferredColorScheme(.dark)
}
