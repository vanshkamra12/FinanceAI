import SwiftUI
import CoreData

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var notificationManager: SmartNotificationManager
    
    init(context: NSManagedObjectContext) {
        self._notificationManager = StateObject(wrappedValue: SmartNotificationManager(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        permissionSection
                        notificationTypesSection
                        timingSection
                        testSection
                    }
                    .padding(20)
                }
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .onAppear {
                notificationManager.requestPermission()
            }
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
                Text("Notifications")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Stay informed about your finances")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "bell.fill")
                .font(.title2)
                .foregroundColor(themeManager.accentColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var permissionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notification Permission")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            HStack {
                Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(notificationManager.isAuthorized ? themeManager.successColor : themeManager.errorColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notificationManager.isAuthorized ? "Notifications Enabled" : "Notifications Disabled")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(notificationManager.isAuthorized ? "You'll receive financial alerts and reminders" : "Enable notifications to receive important financial alerts")
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
                    .background(themeManager.accentColor)
                    .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var notificationTypesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notification Types")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 16) {
                notificationToggle(
                    title: "Budget Alerts",
                    description: "Get notified when you reach 80% of your budget",
                    icon: "target",
                    isOn: $notificationManager.budgetAlerts,
                    color: themeManager.warningColor
                )
                
                notificationToggle(
                    title: "Goal Reminders",
                    description: "Reminders about upcoming goal deadlines",
                    icon: "flag.fill",
                    isOn: $notificationManager.goalReminders,
                    color: themeManager.accentColor
                )
                
                notificationToggle(
                    title: "Spending Alerts",
                    description: "Alerts for unusual or high spending patterns",
                    icon: "exclamationmark.triangle.fill",
                    isOn: $notificationManager.spendingAlerts,
                    color: themeManager.errorColor
                )
                
                notificationToggle(
                    title: "Weekly Reports",
                    description: "Weekly summary of your financial activity",
                    icon: "chart.bar.fill",
                    isOn: $notificationManager.weeklyReports,
                    color: themeManager.primaryColor
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func notificationToggle(title: String, description: String, icon: String, isOn: Binding<Bool>, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .tint(color)
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
    
    private var timingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timing Preferences")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 16) {
                timingOption(
                    title: "Quiet Hours",
                    description: "9:00 PM - 8:00 AM",
                    icon: "moon.fill"
                )
                
                timingOption(
                    title: "Weekly Report Day",
                    description: "Every Monday at 9:00 AM",
                    icon: "calendar"
                )
                
                timingOption(
                    title: "Budget Check",
                    description: "Daily at 6:00 PM",
                    icon: "clock.fill"
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func timingOption(title: String, description: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
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
    
    private var testSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Test Notifications")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                Button("Send Test Budget Alert") {
                    sendTestNotification(title: "Budget Alert", body: "This is a test budget notification")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(themeManager.warningColor)
                .cornerRadius(12)
                
                Button("Send Test Goal Reminder") {
                    sendTestNotification(title: "Goal Reminder", body: "This is a test goal reminder")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(themeManager.accentColor)
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func sendTestNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "test-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView(context: PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

