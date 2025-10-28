import SwiftUI

struct UpdateLearningGoalView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 25) {
                    Spacer(minLength: 50)
                    
                    // Topic Input
                    VStack(alignment: .leading, spacing: 5) {
                        Text("I want to learn")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.themeText)
                        HStack {
                            TextField("", text: $viewModel.topic)
                                .foregroundColor(.themeText)
                                .accentColor(.themeOrange)
                                .padding(.vertical, 8)
                            if !viewModel.topic.isEmpty {
                                Button { viewModel.topic = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 5)
                            }
                        }
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.themeSubtleText.opacity(0.5)),
                            alignment: .bottom
                        )
                    }
                    
                    // Duration Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("I want to learn it in a")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.themeText)
                        HStack(spacing: 12) {
                            ForEach(LearningDuration.allCases) { duration in
                                Button(duration.rawValue) {
                                    viewModel.duration = duration
                                }
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
                                            viewModel.duration == duration ?
                                                Color.themeOrange.opacity(0.5) :
                                                Color.white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .animation(.easeInOut(duration: 0.2), value: viewModel.duration)
                            }
                        }
                    }
                    .padding(.top, 15)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
            .navigationTitle("Learning Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.topic.isEmpty {
                            viewModel.startLearning()
                            dismiss()
                        } else {
                            showConfirmAlert = true
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.themeOrange)
                    }
                }
            }
            .alert("Update Learning goal", isPresented: $showConfirmAlert) {
                Button("Dismiss", role: .cancel) {}
                Button("Update") {
                    viewModel.startLearning()
                    dismiss()
                }
            } message: {
                Text("If you update now, your streak will start over.")
            }
        }
    }
}

#Preview {
    UpdateLearningGoalView(viewModel: OnboardingViewModel(activityViewModel: ActivityViewModel()))
}

