import SwiftUI
import UserNotifications
import CoreData

class SmartNotificationManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var budgetAlerts = true
    @Published var goalReminders = true
    @Published var weeklyReports = true
    @Published var spendingAlerts = true

    private let context: NSManagedObjectContext
    private var checkTimer: Timer?

    init(context: NSManagedObjectContext) {
        self.context = context
        checkAuthorizationStatus()
        setupNotificationCategories()
        startPeriodicChecks()
    }

    deinit {
        checkTimer?.invalidate()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.scheduleWeeklyReport()
                }
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

    private func setupNotificationCategories() {
        let budgetCategory = UNNotificationCategory(
            identifier: "BUDGET_ALERT",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let goalCategory = UNNotificationCategory(
            identifier: "GOAL_REMINDER",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        let spendingCategory = UNNotificationCategory(
            identifier: "SPENDING_ALERT",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        let weeklyReportCategory = UNNotificationCategory(
            identifier: "WEEKLY_REPORT",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([budgetCategory, goalCategory, spendingCategory, weeklyReportCategory])
    }

    private func startPeriodicChecks() {
        // Check every hour for budget/goal updates
        checkTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.performAllChecks()
            }
        }

        // Initial check
        Task {
            await performAllChecks()
        }
    }

    @MainActor
    func performAllChecks() async {
        guard isAuthorized else { return }

        if budgetAlerts {
            checkBudgetAlerts()
        }

        if goalReminders {
            checkGoalDeadlines()
        }

        if spendingAlerts {
            checkDailySpendingLimit()
        }
    }

    // MARK: - Budget Alerts

    private func checkBudgetAlerts() {
        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        let currentMonth = getCurrentMonth()
        request.predicate = NSPredicate(format: "month == %@", currentMonth)

        do {
            let budgets = try context.fetch(request)
            for budget in budgets {
                checkBudgetThreshold(budget: budget)
            }
        } catch {
            print("Error fetching budgets for notifications: \(error)")
        }
    }

    private func checkBudgetThreshold(budget: Budget) {
        guard let categoryName = budget.categoryName,
              let monthlyLimit = budget.monthlyLimit else { return }

        let spent = getSpentAmount(for: categoryName, in: getCurrentMonth())
        let limit = monthlyLimit.doubleValue
        let percentage = spent / limit

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["budget-\(categoryName)"])

        if percentage >= 0.9 {
            scheduleBudgetAlert(category: categoryName, percentage: 90, spent: spent, limit: limit)
        } else if percentage >= 0.8 {
            scheduleBudgetAlert(category: categoryName, percentage: 80, spent: spent, limit: limit)
        }
    }

    private func scheduleBudgetAlert(category: String, percentage: Int, spent: Double, limit: Double) {
        let content = UNMutableNotificationContent()
        content.title = "💰 Budget Alert"
        content.body = "You've spent \(percentage)% (\(formatCurrency(spent))) of your \(category) budget (\(formatCurrency(limit)))"
        content.sound = .default
        content.categoryIdentifier = "BUDGET_ALERT"

        content.userInfo = [
            "type": "budget_alert",
            "category": category,
            "spent": spent,
            "limit": limit,
            "percentage": percentage
        ]

        let request = UNNotificationRequest(
            identifier: "budget-\(category)",
            content: content,
            trigger: nil // Immediate notification
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling budget notification: \(error)")
            } else {
                print("✅ Budget alert scheduled for \(category) (\(percentage)%)")
            }
        }
    }

    // MARK: - Goal Reminders

    private func checkGoalDeadlines() {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == false AND targetDate != nil")

        do {
            let goals = try context.fetch(request)
            for goal in goals {
                checkGoalDeadline(goal: goal)
            }
        } catch {
            print("Error fetching goals for notifications: \(error)")
        }
    }

    private func checkGoalDeadline(goal: Goal) {
        guard let goalName = goal.name,
              let targetDate = goal.targetDate,
              let goalId = goal.id else { return }

        let calendar = Calendar.current
        let now = Date()
        let daysUntilTarget = calendar.dateComponents([.day], from: now, to: targetDate).day ?? 0

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["goal-\(goalId.uuidString)"])

        if daysUntilTarget == 7 {
            scheduleGoalReminder(goal: goal, daysLeft: 7)
        } else if daysUntilTarget == 1 {
            scheduleGoalReminder(goal: goal, daysLeft: 1)
        } else if daysUntilTarget == 0 {
            scheduleGoalDeadlineAlert(goal: goal)
        }
    }

    private func scheduleGoalReminder(goal: Goal, daysLeft: Int) {
        guard let goalName = goal.name,
              let goalId = goal.id else { return }

        let current = goal.currentAmount?.doubleValue ?? 0
        let target = goal.targetAmount?.doubleValue ?? 0
        let remaining = target - current

        let content = UNMutableNotificationContent()
        content.title = "🎯 Goal Reminder"

        if daysLeft == 7 {
            content.body = "Your goal '\(goalName)' is due in 1 week! \(formatCurrency(remaining)) left to reach \(formatCurrency(target))"
        } else if daysLeft == 1 {
            content.body = "⏰ Your goal '\(goalName)' is due tomorrow! \(formatCurrency(remaining)) remaining"
        }

        content.sound = .default
        content.categoryIdentifier = "GOAL_REMINDER"
        content.userInfo = [
            "type": "goal_reminder",
            "goal_id": goalId.uuidString,
            "goal_name": goalName,
            "days_left": daysLeft
        ]

        let request = UNNotificationRequest(
            identifier: "goal-\(goalId.uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling goal notification: \(error)")
            } else {
                print("✅ Goal reminder scheduled for \(goalName) (\(daysLeft) days)")
            }
        }
    }

    private func scheduleGoalDeadlineAlert(goal: Goal) {
        guard let goalName = goal.name,
              let goalId = goal.id else { return }

        let current = goal.currentAmount?.doubleValue ?? 0
        let target = goal.targetAmount?.doubleValue ?? 0

        let content = UNMutableNotificationContent()
        content.title = "🚨 Goal Deadline"

        if current >= target {
            content.body = "🎉 Congratulations! You've reached your '\(goalName)' goal!"
        } else {
            let remaining = target - current
            content.body = "Your goal '\(goalName)' deadline is today. You're \(formatCurrency(remaining)) away from your target."
        }

        content.sound = .default
        content.categoryIdentifier = "GOAL_REMINDER"

        let request = UNNotificationRequest(
            identifier: "goal-deadline-\(goalId.uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Spending Alerts

    private func checkDailySpendingLimit() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@ AND isExpense == true", today as NSDate, tomorrow as NSDate)

        do {
            let todaysTransactions = try context.fetch(request)
            let totalSpent = todaysTransactions.reduce(0.0) { sum, transaction in
                sum + (transaction.amount?.doubleValue ?? 0)
            }

            if totalSpent > 200 {
                scheduleSpendingAlert(amount: totalSpent, level: "high")
            } else if totalSpent > 100 {
                scheduleSpendingAlert(amount: totalSpent, level: "medium")
            }
        } catch {
            print("Error checking daily spending: \(error)")
        }
    }

    private func scheduleSpendingAlert(amount: Double, level: String) {
        let identifier = "daily-spending-\(getCurrentDateString())"

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let exists = requests.contains { $0.identifier == identifier }
            if exists { return }

            let content = UNMutableNotificationContent()
            content.title = "💸 Spending Alert"

            switch level {
            case "high":
                content.body = "High spending day! You've spent \(self.formatCurrency(amount)) today. Consider reviewing your purchases."
            case "medium":
                content.body = "You've spent \(self.formatCurrency(amount)) today. Keep track of your expenses!"
            default:
                content.body = "Daily spending: \(self.formatCurrency(amount))"
            }

            content.sound = .default
            content.categoryIdentifier = "SPENDING_ALERT"
            content.userInfo = ["type": "spending_alert", "amount": amount, "level": level]

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: nil
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling spending notification: \(error)")
                } else {
                    print("✅ Spending alert scheduled: \(self.formatCurrency(amount))")
                }
            }
        }
    }

    // MARK: - Weekly Reports

    func scheduleWeeklyReport() {
        guard isAuthorized && weeklyReports else { return }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly-report"])

        let content = UNMutableNotificationContent()
        content.title = "📊 Weekly Financial Report"
        content.body = "Your weekly spending summary is ready. Tap to view insights and trends."
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_REPORT"

        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 9 // 9 AM

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "weekly-report",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekly report: \(error)")
            } else {
                print("✅ Weekly report scheduled for Mondays at 9 AM")
            }
        }
    }

    // MARK: - Helper Methods

    private func getCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func getSpentAmount(for category: String, in month: String) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        guard let monthDate = formatter.date(from: month) else { return 0 }

        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: monthDate)?.start ?? monthDate
        let endOfMonth = calendar.dateInterval(of: .month, for: monthDate)?.end ?? monthDate

        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@ AND isExpense == true AND date >= %@ AND date <= %@",
                                        category, startOfMonth as NSDate, endOfMonth as NSDate)

        do {
            let transactions = try context.fetch(request)
            return transactions.reduce(0.0) { sum, transaction in
                sum + (transaction.amount?.doubleValue ?? 0)
            }
        } catch {
            print("Error calculating spent amount: \(error)")
            return 0
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }

    // MARK: - Manual Trigger Functions for Testing

    func triggerTestBudgetAlert() {
        scheduleBudgetAlert(category: "Food", percentage: 85, spent: 425, limit: 500)
    }

    func triggerTestGoalReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🎯 Goal Reminder (Test)"
        content.body = "This is a test goal reminder notification"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "test-goal-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

