import SwiftUI

struct WidgetConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        introSection
                        widgetTypesSection
                        setupInstructionsSection
                    }
                    .padding(20)
                }
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            VStack {
                Text("Home Screen Widgets")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Live financial data on your home screen")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "rectangle.3.group")
                .font(.title2)
                .foregroundColor(themeManager.accentColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var introSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "iphone.homebutton")
                .font(.system(size: 60))
                .foregroundColor(themeManager.accentColor)
            
            Text("Live Balance Widgets")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.textPrimary)
            
            Text("Add FinanceAI widgets to your home screen to see your balance, recent transactions, and spending insights at a glance")
                .font(.subheadline)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(24)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var widgetTypesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Widgets")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                widgetTypeCard(
                    size: "Small",
                    description: "Current balance with income/expense summary",
                    icon: "square.fill",
                    color: themeManager.successColor,
                    features: ["Live balance", "Income & expenses", "Auto-updates"]
                )
                
                widgetTypeCard(
                    size: "Medium",
                    description: "Balance plus recent transactions",
                    icon: "rectangle.fill",
                    color: themeManager.primaryColor,
                    features: ["Balance overview", "3 recent transactions", "Category icons"]
                )
                
                widgetTypeCard(
                    size: "Large",
                    description: "Complete financial dashboard",
                    icon: "rectangle.portrait.fill",
                    color: themeManager.accentColor,
                    features: ["Full dashboard", "Recent transactions", "Spending insights", "Income/expense breakdown"]
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func widgetTypeCard(size: String, description: String, icon: String, color: Color, features: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(size) Widget")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(color)
                        
                        Text(feature)
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
    
    private var setupInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Add Widgets")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 16) {
                instructionStep(
                    number: "1",
                    title: "Long press on home screen",
                    description: "Enter 'jiggle mode' where apps wiggle",
                    icon: "hand.tap.fill"
                )
                
                instructionStep(
                    number: "2",
                    title: "Tap the '+' button",
                    description: "Usually appears in the top-left corner",
                    icon: "plus.circle.fill"
                )
                
                instructionStep(
                    number: "3",
                    title: "Search for 'FinanceAI'",
                    description: "Find our app in the widget gallery",
                    icon: "magnifyingglass"
                )
                
                instructionStep(
                    number: "4",
                    title: "Choose widget size",
                    description: "Select Small, Medium, or Large widget",
                    icon: "rectangle.3.group"
                )
                
                instructionStep(
                    number: "5",
                    title: "Add to home screen",
                    description: "Tap 'Add Widget' and position it",
                    icon: "checkmark.circle.fill"
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func instructionStep(number: String, title: String, description: String, icon: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeManager.primaryColor)
                    .frame(width: 30, height: 30)
                
                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(themeManager.accentColor)
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
}

struct WidgetConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetConfigurationView()
            .environmentObject(ThemeManager())
    }
}

