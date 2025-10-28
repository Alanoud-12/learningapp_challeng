import SwiftUI

// Central definition for Color extension and theme colors.
// Ensure this is the ONLY file defining `init(hex:)`.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgb) else {
            // Return a default color if scanning fails
            self = .clear
            print("Error: Invalid hex string - \(hex)")
            return
        }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    // MARK: - Theme Colors (Adaptive - works in both light and dark mode)
    static let themeOrange = Color(hex: "D9704A")      // Main buttons, highlights, learned days
    static let themeTeal = Color(hex: "4DB0A1")        // Freeze button/days
    
    // Adaptive colors that respond to system appearance
    static var themeBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    static var themeText: Color {
        Color(UIColor.label)
    }
    
    static var themeSubtleText: Color {
        Color(UIColor.secondaryLabel)
    }
    
    static var themeCardBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    static var themeDarkGray: Color {
        Color(UIColor.secondarySystemFill)
    }

    // Glass Materials (Using standard materials for consistency)
    static let themeGlassBackground = Material.ultraThin // Main content panel glass
    static let themeInputGlass = Material.regular      // TextField/Picker glass bg
    static let themeIconGlass = Material.regular       // Icon background glass

    // Calendar Specific Colors
    static let calendarLearned = themeOrange
    static let calendarFreezed = themeTeal
    static let calendarMissed = Color.red.opacity(0.6)    // Past missed days (Optional)
    static let calendarTodayBorder = Color.gray.opacity(0.5) // Border for today if unlogged
    static let calendarSelectedBorder = Color.white.opacity(0.9) // Border for selected date
    static let calendarFutureText = themeSubtleText.opacity(0.6) // Dimmer text for future dates
    static let calendarText = themeText                  // Default day number text
    static let calendarPastUnloggedText = themeSubtleText.opacity(0.8) // Past days not logged
}
