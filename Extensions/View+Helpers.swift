import SwiftUI

// Helper for applying custom rounded corners selectively
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }

    // Lightweight glass effect helper consistent with Apple's materials
    func appGlassBackground(cornerRadius: CGFloat = 12) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// Custom Shape for applying rounded corners to specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Custom View extension for placeholder text styling in TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            // Show the placeholder only when shouldShow is true
            placeholder().opacity(shouldShow ? 1 : 0)
            // The TextField itself
            self
        }
    }
}

// Helpers for Date manipulation and formatting
extension Date {
    /// SUN, MON, etc. - Starting from Sunday
    static var veryShortWeekdaySymbols: [String] {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.veryShortWeekdaySymbols
        
        // Reorder so Sunday comes first
        var reordered = weekdaySymbols.map { $0.uppercased() }
        let firstWeekday = calendar.firstWeekday // Usually 1 for Sunday
        
        // If first weekday is not Sunday (1), reorder
        if firstWeekday != 1 {
            let beforeFirstWeekday = reordered[0..<(firstWeekday - 1)]
            let fromFirstWeekday = reordered[(firstWeekday - 1)..<reordered.count]
            reordered = Array(fromFirstWeekday) + Array(beforeFirstWeekday)
        }
        
        return reordered
    }
    /// Returns start of the day (midnight)
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    /// Formats date as "MMMM yyyy" (e.g., October 2025)
    func formattedMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
    /// Formats date as "d" (e.g., 21)
    func formattedDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    /// Returns start of the week (assuming Sunday)
    var startOfWeek: Date {
        let calendar = Calendar.current
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else {
            return self.startOfDay // Fallback
        }
        return sunday
    }
}

// Helper for pluralization ("1 Day" vs "X Days")
extension Int {
    var dayPlural: String {
        self == 1 ? "Day" : "Days"
    }
}
