import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                themeSelector
                previewSection
                Spacer()
            }
            .padding()
            .background(themeManager.backgroundColor)
            .navigationTitle("Appearance")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.primaryColor)
                }
            }
        }
    }
    
    private var themeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Theme")
                .font(.headline)
                .foregroundColor(themeManager.primaryColor)
            
            VStack(spacing: 12) {
                ForEach(ThemeManager.AppTheme.allCases, id: \.self) { theme in
                    themeOption(theme)
                }
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }
    
    private func themeOption(_ theme: ThemeManager.AppTheme) -> some View {
        HStack {
            Circle()
                .fill(themeColorPreview(for: theme))
                .frame(width: 20, height: 20)
            
            Text(theme.rawValue)
                .font(.body)
            
            Spacer()
            
            if themeManager.currentTheme == theme {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(themeManager.accentColor)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(themeManager.currentTheme == theme ? themeManager.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                themeManager.currentTheme = theme
            }
        }
    }
    
    private func themeColorPreview(for theme: ThemeManager.AppTheme) -> Color {
        switch theme {
        case .light:
            return Color(red: 0.0, green: 0.48, blue: 0.8)
        case .dark:
            return Color(red: 0.4, green: 0.78, blue: 1.0)
        case .system:
            return Color.primary
        case .professional:
            return Color(red: 0.05, green: 0.3, blue: 0.55)
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(themeManager.primaryColor)
            
            VStack(spacing: 12) {
                // Sample transaction row
                HStack {
                    CategoryIcon(category: "Food", size: 20)
                    
                    VStack(alignment: .leading) {
                        Text("Lunch")
                            .font(.headline)
                            .foregroundColor(themeManager.textPrimary)
                        Text("Restaurant meal")
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("-$25.50")
                        .foregroundColor(themeManager.errorColor)
                        .bold()
                }
                .padding()
                .background(themeManager.backgroundColor)
                .cornerRadius(8)
                
                // Sample summary card
                HStack {
                    VStack(alignment: .leading) {
                        Text("Balance")
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                        Text("$1,234.56")
                            .bold()
                            .foregroundColor(themeManager.accentColor)
                    }
                    Spacer()
                }
                .padding()
                .background(themeManager.backgroundColor)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }
}

struct ThemeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSettingsView()
            .environmentObject(ThemeManager())
    }
}

