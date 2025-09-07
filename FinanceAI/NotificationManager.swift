import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleBudgetAlert(for category: String, spent: Double, limit: Double) {
        guard isAuthorized else { return }
        
        let percentage = spent / limit
        if percentage >= 0.8 {
            let content = UNMutableNotificationContent()
            content.title = "Budget Alert"
            content.body = "You've spent \(Int(percentage * 100))% of your \(category) budget"
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: "budget-\(category)",
                content: content,
                trigger: nil
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func scheduleGoalReminder(goalName: String, targetDate: Date) {
        guard isAuthorized else { return }
        
        let calendar = Calendar.current
        let reminderDate = calendar.date(byAdding: .day, value: -7, to: targetDate)
        
        guard let reminderDate = reminderDate, reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Goal Reminder"
        content.body = "Your goal '\(goalName)' is due in 7 days!"
        content.sound = .default
        
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "goal-\(goalName)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

