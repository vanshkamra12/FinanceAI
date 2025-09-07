import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .system
    
    enum AppTheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
        case professional = "Professional"
    }
    
    var colorScheme: ColorScheme? {
        switch currentTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        case .professional: return .light
        }
    }
    
    // Professional Banking Colors
    var primaryColor: Color {
        switch currentTheme {
        case .light, .system:
            return Color(red: 0.0, green: 0.48, blue: 0.8) // Professional Blue
        case .dark:
            return Color(red: 0.4, green: 0.78, blue: 1.0) // Light Blue for dark mode
        case .professional:
            return Color(red: 0.05, green: 0.3, blue: 0.55) // Navy Blue
        }
    }
    
    var accentColor: Color {
        switch currentTheme {
        case .light, .system:
            return Color(red: 0.0, green: 0.7, blue: 0.4) // Professional Green
        case .dark:
            return Color(red: 0.3, green: 0.85, blue: 0.5) // Light Green for dark
        case .professional:
            return Color(red: 0.85, green: 0.6, blue: 0.0) // Gold accent
        }
    }
    
    var backgroundColor: Color {
        switch currentTheme {
        case .light, .system:
            return Color(red: 0.98, green: 0.98, blue: 0.99) // Off-white
        case .dark:
            return Color(red: 0.05, green: 0.05, blue: 0.05) // True black
        case .professional:
            return Color(red: 0.96, green: 0.97, blue: 0.98) // Light gray
        }
    }
    
    var cardColor: Color {
        switch currentTheme {
        case .light, .system:
            return Color.white
        case .dark:
            return Color(red: 0.11, green: 0.11, blue: 0.12) // Dark gray
        case .professional:
            return Color.white
        }
    }
    
    var textPrimary: Color {
        switch currentTheme {
        case .light, .system, .professional:
            return Color(red: 0.1, green: 0.1, blue: 0.1) // Near black
        case .dark:
            return Color(red: 0.95, green: 0.95, blue: 0.95) // Off white
        }
    }
    
    var textSecondary: Color {
        switch currentTheme {
        case .light, .system, .professional:
            return Color(red: 0.4, green: 0.4, blue: 0.4) // Medium gray
        case .dark:
            return Color(red: 0.6, green: 0.6, blue: 0.6) // Light gray
        }
    }
    
    var successColor: Color { Color(red: 0.0, green: 0.7, blue: 0.3) }
    var errorColor: Color { Color(red: 0.9, green: 0.2, blue: 0.2) }
    var warningColor: Color { Color(red: 0.95, green: 0.6, blue: 0.0) }
}

