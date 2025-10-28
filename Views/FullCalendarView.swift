import SwiftUI

struct FullCalendarView: View {
    @ObservedObject var viewModel: ActivityViewModel

    // Use selectedDate from ViewModel to control the displayed month
    private var displayedMonthDate: Date { viewModel.selectedDate }

    // Generate days for the grid (includes padding days outside the month)
    private var daysInGrid: [Date] { generateDaysInGrid(for: displayedMonthDate) }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.themeBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                // Month Navigation Header
                HStack {
                    Button { viewModel.changeMonth(by: -1) } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.themeText)
                    }
                    Spacer()
                    Text(displayedMonthDate.formattedMonthYear())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.themeText)
                    Spacer()
                    Button { viewModel.changeMonth(by: 1) } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.themeText)
                    }
                }
                .padding(.horizontal)

                // Day of Week Header
                HStack {
                    ForEach(Date.veryShortWeekdaySymbols, id: \.self) { daySymbol in
                        Text(daySymbol).font(.caption).fontWeight(.semibold)
                            .frame(maxWidth: .infinity).foregroundColor(.themeSubtleText)
                    }
                }.padding(.horizontal, 5)

                // Calendar Grid
                ScrollView(.vertical, showsIndicators: false) {
                     LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                         if viewModel.isConfigured {
                             ForEach(daysInGrid, id: \.self) { date in
                                 // Pass baseDate to check if day belongs to current month
                                 CalendarDaySquareView(date: date, viewModel: viewModel, baseDate: displayedMonthDate)
                             }
                         } else {
                             Text("Set a learning goal...").font(.subheadline).foregroundColor(.themeSubtleText)
                                 .padding(.vertical, 50).frame(maxWidth: .infinity)
                                 .gridCellUnsizedAxes([.horizontal, .vertical]).gridCellColumns(7)
                         }
                    }
                     .padding(.horizontal, 5).padding(.top, 5)
                }
                Spacer() // Pushes grid up
            }
            .padding(.vertical, 10).padding(.horizontal, 10)
        }
         .navigationTitle("All activities") // Matches design title
         .navigationBarTitleDisplayMode(.inline)
         .navigationBarBackButtonHidden(false) // Show standard back button
         // Style nav bar for dark mode
         .toolbarColorScheme(.dark, for: .navigationBar)
         .toolbarBackground(Color.themeBackground, for: .navigationBar)
         .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Calendar Generation Logic
    func generateDaysInGrid(for baseDate: Date) -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: baseDate) else {
            return Array(repeating: Date.distantPast, count: 42)
        }
        let firstDayOfMonth = monthInterval.start
        guard let firstDayOfGrid = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstDayOfMonth)) else {
            return Array(repeating: Date.distantPast, count: 42)
        }
        var days: [Date] = []
        let numberOfCells = 42 // 6 weeks * 7 days
        for dayOffset in 0..<numberOfCells {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfGrid) {
                // Return actual date regardless of month; view decides styling
                days.append(date.startOfDay)
            } else {
                days.append(Date.distantPast) // Fallback placeholder
            }
        }
        return days
    }
}

// MARK: - Calendar Day Square Component
struct CalendarDaySquareView: View {
    let date: Date
    @ObservedObject var viewModel: ActivityViewModel
    let baseDate: Date // Month being displayed

    // Check if date is placeholder or belongs to the current month view
    private var isDateInDisplayedMonth: Bool {
         date != Date.distantPast && Calendar.current.isDate(date, equalTo: baseDate, toGranularity: .month)
    }
    private var dayStatus: DayStatus { viewModel.getStatus(for: date) } // Use non-optional
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isInFuture: Bool { date.startOfDay > Date().startOfDay }

    private var backgroundColor: Color {
        guard isDateInDisplayedMonth else { return .clear }
        switch dayStatus {
        case .learned: return .calendarLearned
        case .freezed: return .calendarFreezed
        case .none: return .clear // Explicit none
        }
    }
    private var textColor: Color {
        guard isDateInDisplayedMonth else { return .clear }
        if isInFuture { return .calendarFutureText }
        else if isToday { return .themeText } // Today always white unless logged
        else if dayStatus != .none { return .themeText } // Logged days white
        else { return .calendarPastUnloggedText } // Past unlogged gray
    }
    private var borderColor: Color {
        guard isDateInDisplayedMonth else { return .clear }
        if isToday && dayStatus == .none { return .calendarTodayBorder } // Border only if today and unlogged
        return .clear
    }

    var body: some View {
        Text(isDateInDisplayedMonth ? date.formattedDay() : "") // Day num or empty
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 35)
            .background(
                ZStack {
                    backgroundColor
                    if backgroundColor != .clear {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(5)
                    }
                }
            )
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(
                color: backgroundColor != .clear ? backgroundColor.opacity(0.3) : .clear,
                radius: 5, x: 0, y: 2
            )
            .opacity(isDateInDisplayedMonth ? 1.0 : 0.0)
            .allowsHitTesting(isDateInDisplayedMonth)
    }
}

// MARK: - Preview
#Preview {
    NavigationView { // Embed for nav bar styling
        FullCalendarView(viewModel: {
            let vm = ActivityViewModel()
            vm.setGoal(topic: "Preview", duration: .month)
            return vm
        }())
    }
    .preferredColorScheme(.dark)
}
