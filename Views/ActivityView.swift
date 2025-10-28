import SwiftUI

// Main view for tracking daily activity
struct ActivityView: View {
    @ObservedObject var viewModel: ActivityViewModel
    @State private var showingChangeGoalSheet = false

    var body: some View {
        ZStack {
            Color.themeBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) { // No outer spacing

                // --- Custom Header ---
                ActivityHeaderView(
                    viewModel: viewModel,
                    onChangeGoalTapped: { showingChangeGoalSheet = true }
                )

                // --- Main Content Area ---
                 VStack(spacing: 20) { // Spacing for content blocks

                        // Learning Topic
                        Text(viewModel.currentLearningTopic)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.themeSubtleText)
                            .padding(.bottom, 15)

                        // Week Calendar with navigation
                        WeekCalendarView(viewModel: viewModel)
                            .padding(.bottom, 10)

                        // Metrics Cards
                        HStack(spacing: 15) {
                            MetricCardView(
                                title: viewModel.learnedPlural + " Learned",
                                value: "\(viewModel.daysLearned)",
                                iconName: "flame.fill", iconColor: .themeOrange,
                                backgroundColor: .themeCardBackground
                            )
                            MetricCardView(
                                title: viewModel.freezedPlural + " Freezed",
                                value: "\(viewModel.freezesUsedDisplay)",
                                iconName: "cube.fill", iconColor: .themeTeal,
                                backgroundColor: .themeCardBackground
                            )
                        }

                        // Divider under metrics like the design
                        Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.vertical, 6)

                        Spacer(minLength: 25) // Dynamic space

                        // --- Main Action Area ---
                        if viewModel.isGoalCompleted {
                            GoalCompletedContentView(viewModel: viewModel) {
                                showingChangeGoalSheet = true
                            }
                        } else if viewModel.isDayLogged(for: viewModel.selectedDate) {
                            DayLoggedView(viewModel: viewModel)
                        } else {
                            DefaultLoggingView(viewModel: viewModel)
                        }

                        Spacer(minLength: 10) // Bottom space

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                    .padding(.bottom, 30)


                // Apply the Liquid Glass background look
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(
                    ZStack {
                        // Black background for liquid glass effect
                        Color.black
                        
                        // Glass material effect on top
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                        
                        // Subtle overlay gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                    }
                )
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .overlay(
                    RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                        .stroke(
                            Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
                .edgesIgnoringSafeArea(.bottom)

            } // End Main VStack
        } // End ZStack
        .navigationBarHidden(true) // Use custom header
        .sheet(isPresented: $showingChangeGoalSheet) {
            OnboardingView(viewModel: OnboardingViewModel(
                activityViewModel: viewModel,
                initialTopic: viewModel.currentLearningTopic,
                initialDuration: viewModel.learningDuration,
                onComplete: { showingChangeGoalSheet = false }
            ))
        }
        .onAppear {
             // Ensure calendar shows today on appear
             viewModel.selectedDate = Date().startOfDay
             // viewModel.refreshDataOnAppear() // Optional: Force reload
        }
    }
}

// MARK: - Sub Components (Defined within ActivityView.swift)

struct ActivityHeaderView: View {
    @ObservedObject var viewModel: ActivityViewModel
    var onChangeGoalTapped: () -> Void

    var body: some View {
        HStack {
            NavigationLink(destination: FullCalendarView(viewModel: viewModel)) {
                Image(systemName: "calendar").font(.title3).foregroundColor(.themeText)
            }
            Spacer()
            Text("Activity").font(.title2).fontWeight(.bold).foregroundColor(.themeText)
            Spacer()
            Button(action: onChangeGoalTapped) {
                Image(systemName: "pencil.and.outline")
                    .font(.title3)
                    .foregroundColor(.themeText)
            }
        }
        .padding(.horizontal, 25).padding(.vertical, 12)
    }
}

struct WeekCalendarView: View {
    @ObservedObject var viewModel: ActivityViewModel
    var startOfWeekDate: Date { viewModel.selectedDate.startOfWeek }

    var body: some View {
        VStack(spacing: 12) {
            // Month/Year with chevron and week navigation arrows
            HStack {
                HStack(spacing: 4) {
                    Text(viewModel.selectedDate.formattedMonthYear())
                        .font(.headline)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.themeText)
                Spacer()
                
                // Week navigation arrows
                HStack(spacing: 20) {
                    Button { viewModel.changeWeek(by: 1) } label: {
                        Image(systemName: "chevron.left")
                            .font(.callout)
                    }
                    Button { viewModel.changeWeek(by: -1) } label: {
                        Image(systemName: "chevron.right")
                            .font(.callout)
                    }
                }
                .foregroundColor(.themeText.opacity(0.8))
            }
            
            // Weekday symbols
            HStack {
                ForEach(Date.veryShortWeekdaySymbols, id: \.self) { daySymbol in
                    Text(daySymbol)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.themeSubtleText)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Day circles for the week
            HStack(spacing: 6) {
                ForEach(0..<7) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfWeekDate)!
                    let dayStatus = viewModel.getStatus(for: date)
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                    DayCircleView(date: date, status: dayStatus, isSelected: isSelected)
                        .onTapGesture { viewModel.selectedDate = date.startOfDay }
                }
            }
        }
        .padding(.horizontal, 5)
    }
}

struct DayCircleView: View {
    let date: Date
    let status: DayStatus
    let isSelected: Bool

    var backgroundColor: Color {
        switch status {
        case .learned: return .themeOrange
        case .freezed: return .themeTeal
        case .none: return .clear
        }
    }
    
    var textColor: Color {
        if isSelected || status != .none {
            return .themeText
        } else {
            return .themeSubtleText
        }
    }

    var body: some View {
        Text(date.formattedDay())
            .font(.subheadline)
            .fontWeight(isSelected ? .bold : .medium)
            .foregroundColor(textColor)
            .frame(width: 38, height: 38)
            .background(backgroundColor)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.white.opacity(0.9) : Color.clear, lineWidth: 2)
            )
    }
}

struct MetricCardView: View {
    let title: String; let value: String; let iconName: String; let iconColor: Color; let backgroundColor: Color
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.footnote)
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.themeText)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.themeSubtleText)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct DefaultLoggingView: View {
    @ObservedObject var viewModel: ActivityViewModel
    var body: some View {
        VStack(spacing: 15) {
            Button { viewModel.logDayAsLearned() } label: {
                 ZStack {
                     // Solid orange button with liquid glass overlay
                     Circle()
                         .fill(Color.themeOrange)
                         .overlay(
                             Circle()
                                 .fill(
                                     RadialGradient(
                                         gradient: Gradient(colors: [
                                             Color.white.opacity(0.2),
                                             Color.white.opacity(0.05)
                                         ]),
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: 85
                                     )
                                 )
                         )
                     
                     // Inner content
                     Text("Log as\nLearned")
                         .font(.title3)
                         .fontWeight(.bold)
                         .foregroundColor(.themeText)
                         .multilineTextAlignment(.center)
                         .padding(.horizontal, 10)
                 }
                 .frame(width: 170, height: 170)
            }
            .disabled(viewModel.isLogLearnedButtonDisabled)
            .opacity(viewModel.isLogLearnedButtonDisabled ? 0.5 : 1.0)
            .padding(.bottom, 5)

            Button { viewModel.logDayAsFreezed() } label: {
                Text("Log as Freezed")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.isLogFreezedButtonDisabled ? .themeSubtleText : .themeTeal)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 35)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        Color.themeTeal.opacity(viewModel.isLogFreezedButtonDisabled ? 0.2 : 0.6),
                                        lineWidth: 1.5
                                    )
                            )
                    )
            }
            .disabled(viewModel.isLogFreezedButtonDisabled)
            .opacity(viewModel.isLogFreezedButtonDisabled ? 0.5 : 1.0)

            Text("\(viewModel.freezesUsedDisplay) out of \(viewModel.maxFreezes) Freezes used")
                .font(.caption)
                .foregroundColor(.themeSubtleText)
        }
    }
}

struct DayLoggedView: View {
     @ObservedObject var viewModel: ActivityViewModel
     var status: DayStatus { viewModel.getStatus(for: viewModel.selectedDate) } // Use non-optional
     var statusText: String { status == .learned ? "Learned\nToday" : "Day\nFreezed" }
     var circleColor: Color { status == .learned ? .themeOrange : .themeTeal }
     var freezeCountText: String { "\(viewModel.freezesUsedDisplay) out of \(viewModel.maxFreezes) Freezes used" }

     var body: some View {
         VStack(spacing: 15) {
             ZStack { // Status Circle
                  // Solid color circle with glass overlay
                  Circle()
                      .fill(circleColor.opacity(0.1))
                      .overlay(
                          Circle()
                              .stroke(circleColor, lineWidth: 2)
                      )
                      .overlay(
                          Circle()
                              .fill(
                                  RadialGradient(
                                      gradient: Gradient(colors: [
                                          Color.white.opacity(0.15),
                                          Color.clear
                                      ]),
                                      center: .center,
                                      startRadius: 0,
                                      endRadius: 85
                                  )
                              )
                              .padding(3)
                      )
                  
                  // Text
                  Text(statusText)
                      .font(.title2)
                      .fontWeight(.bold)
                      .foregroundColor(circleColor)
                      .multilineTextAlignment(.center)
                      .padding(.horizontal, 10)
             }
             .frame(width: 170, height: 170)
             .padding(.bottom, 5)

             // Display Freeze Count text (styled like disabled button)
             Text(freezeCountText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.themeSubtleText)
                .padding(.vertical, 12)
                .padding(.horizontal, 35)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.themeSubtleText.opacity(0.3), lineWidth: 1)
                        )
                )

             // Hidden text for layout consistency
             Text(freezeCountText)
                .font(.caption)
                .foregroundColor(.clear)
                .padding(.top, -10)
         }
     }
}

struct GoalCompletedContentView: View {
    @ObservedObject var viewModel: ActivityViewModel
    var onSetNewGoal: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 30)
            
            // Celebration Icon with glass effect
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 50))
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
                                        endRadius: 50
                                    )
                                )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.bottom, 5)
            
            Text("Well done!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.themeText)
            
            Text("Goal completed! Start learning again or set new learning goal.")
                .font(.footnote)
                .foregroundColor(.themeSubtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 15)
            
            Button("Set new learning goal") { onSetNewGoal() }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        Color.themeOrange
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .foregroundColor(.themeText)
                .cornerRadius(14)
            
            Button("Set same learning goal and duration") {
                viewModel.repeatGoal()
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.themeOrange)
            .padding(.top, 0)
            
            Spacer(minLength: 40)
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Preview
#Preview {
    ActivityView(viewModel: {
        let vm = ActivityViewModel()
        vm.setGoal(topic: "SwiftUI", duration: .month)
        return vm
    }())
    .preferredColorScheme(.dark)
}
