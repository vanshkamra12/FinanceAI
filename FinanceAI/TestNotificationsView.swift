import SwiftUI

struct TestNotificationsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var notificationManager: SmartNotificationManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: 20) {
                        notificationStatusSection
                        testButtonsSection
                        settingsSection
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
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            VStack {
                Text("Test Notifications")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Test smart notification system")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "bell.badge.fill")
                .font(.title2)
                .foregroundColor(themeManager.accentColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var notificationStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notification Status")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            HStack {
                Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(notificationManager.isAuthorized ? themeManager.successColor : themeManager.errorColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notificationManager.isAuthorized ? "Notifications Enabled" : "Notifications Disabled")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(notificationManager.isAuthorized ?
                            "Smart alerts are active and monitoring your finances" :
                            "Enable notifications to receive financial alerts")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                if !notificationManager.isAuthorized {
                    Button("Enable") {
                        notificationManager.requestPermission()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(themeManager.primaryColor)
                    .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var testButtonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Test Notifications")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                testButton(
                    title: "Test Budget Alert",
                    description: "Simulate 85% budget reached",
                    icon: "target",
                    color: themeManager.warningColor
                ) {
                    notificationManager.triggerTestBudgetAlert()
                }
                
                testButton(
                    title: "Test Goal Reminder",
                    description: "Simulate goal deadline approaching",
                    icon: "flag.fill",
                    color: themeManager.accentColor
                ) {
                    notificationManager.triggerTestGoalReminder()
                }
                
                testButton(
                    title: "Check All Notifications",
                    description: "Run full notification check now",
                    icon: "bell.circle.fill",
                    color: themeManager.primaryColor
                ) {
                    Task {
                        await notificationManager.performAllChecks()
                    }
                }
                
                testButton(
                    title: "Schedule Weekly Report",
                    description: "Set up weekly financial summary",
                    icon: "calendar.circle.fill",
                    color: themeManager.successColor
                ) {
                    notificationManager.scheduleWeeklyReport()
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func testButton(title: String, description: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            .padding()
            .background(themeManager.backgroundColor)
            .cornerRadius(12)
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notification Settings")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                settingToggle(
                    title: "Budget Alerts",
                    isOn: $notificationManager.budgetAlerts,
                    color: themeManager.warningColor
                )
                
                settingToggle(
                    title: "Goal Reminders",
                    isOn: $notificationManager.goalReminders,
                    color: themeManager.accentColor
                )
                
                settingToggle(
                    title: "Spending Alerts",
                    isOn: $notificationManager.spendingAlerts,
                    color: themeManager.errorColor
                )
                
                settingToggle(
                    title: "Weekly Reports",
                    isOn: $notificationManager.weeklyReports,
                    color: themeManager.primaryColor
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func settingToggle(title: String, isOn: Binding<Bool>, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .tint(color)
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
}

struct TestNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        TestNotificationsView(notificationManager: SmartNotificationManager(context: PersistenceController.preview.container.viewContext))
            .environmentObject(ThemeManager())
    }
}

