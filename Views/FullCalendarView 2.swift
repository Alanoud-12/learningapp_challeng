//
//  FullCalendarView 2.swift
//  learningapp_ch2
//
//  Created by العنود عبدالله ناصر الرشيد on 05/05/1447 AH.
//


import SwiftUI

struct FullCalendarView: View {
    @ObservedObject var viewModel: ActivityViewModel
    
    @State private var currentDate = Date()
    
    private var daysInMonth: [Date] {
        return generateDaysInMonth(for: currentDate)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 1. Dark background for the Liquid Glass aesthetic
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Month Navigation Header
                HStack {
                    Button(action: { changeMonth(offset: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Text(currentDate, format: .dateTime.month(.wide).year())
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(minWidth: 150)
                    
                    Button(action: { changeMonth(offset: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .foregroundColor(.white)
                .padding(.top, 10)
                
                // Day of Week Header
                HStack {
                    ForEach(Date.weekdaySymbols, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
                    if viewModel.isConfigured {
                        ForEach(daysInMonth, id: \.self) { date in
                            CalendarDayView(date: date, viewModel: viewModel)
                        }
                    } else {
                        Text("Start a learning goal to see your calendar.")
                            .foregroundColor(.white)
                            .padding(.vertical, 50)
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(
                .ultraThinMaterial.opacity(0.8)
            )
            .cornerRadius(20)
            .padding()
            .navigationTitle("Full Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Methods
    
    func changeMonth(offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func generateDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        let weekdayOfFirstDay = calendar.component(.weekday, from: startOfMonth)
        let offset = weekdayOfFirstDay - calendar.firstWeekday
        
        var days: [Date] = []
        
        // Add padding days
        for _ in 0..<offset {
            days.append(Date.distantPast)
        }
        
        // Add actual days in the month
        for day in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
}

// MARK: - Calendar Day Component

struct CalendarDayView: View {
    let date: Date
    @ObservedObject var viewModel: ActivityViewModel
    
    private var isRealDay: Bool {
        return date != Date.distantPast
    }
    
    private var dayStatus: DayStatus {
        return viewModel.streakHistory[Calendar.current.startOfDay(for: date)] ?? .none
    }
    
    private var indicatorColor: Color {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let todayStartOfDay = Calendar.current.startOfDay(for: Date())
        
        switch dayStatus {
        case .learned: return .green.opacity(0.9)
        case .freezed: return .blue.opacity(0.9)
        case .none:
            if startOfDay < todayStartOfDay {
                return .red.opacity(0.7) // Missed Day
            } else if startOfDay == todayStartOfDay {
                return .gray.opacity(0.5) // Today
            } else {
                return .clear // Future Day
            }
        }
    }
    
    var body: some View {
        VStack {
            if isRealDay {
                Text(date, format: .dateTime.day())
                    .font(.caption)
                    .foregroundColor(date <= Date() ? .white : .gray)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(indicatorColor))
            } else {
                Spacer().frame(height: 30)
            }
        }
    }
}

// MARK: - Extensions for Calendar Helpers

extension Date {
    static var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
}