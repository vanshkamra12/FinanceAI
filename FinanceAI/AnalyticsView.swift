import SwiftUI
import CoreData
import Charts

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var transactions: FetchedResults<Transaction>

    @State private var selectedPeriod: AnalyticsPeriod = .month

    enum AnalyticsPeriod: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    periodSelector
                    spendingTrendChart
                    categoryBreakdownChart
                    insightsSection
                }
                .padding()
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Analytics")
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

    private var periodSelector: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(AnalyticsPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
        .tint(themeManager.accentColor)
    }

    private var spendingTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Trend")
                .font(.headline)
                .foregroundColor(themeManager.primaryColor)

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(trendData, id: \.period) { data in
                        LineMark(x: .value("Period", data.period),
                                 y: .value("Amount", data.amount))
                        .foregroundStyle(themeManager.accentColor)
                        .symbol(Circle())
                    }
                }
                .frame(height: 200)
                .chartXAxis { AxisMarks(position: .bottom) }
                .chartYAxis { AxisMarks(position: .leading) }
            } else {
                Text("Requires iOS 16+")
                    .foregroundColor(themeManager.textSecondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }

    private var categoryBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .foregroundColor(themeManager.primaryColor)

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(categoryData, id: \.category) { data in
                        SectorMark(angle: .value("Amount", data.amount),
                                   innerRadius: .ratio(0.6),
                                   angularInset: 2)
                            .foregroundStyle(data.color)
                            .opacity(0.8)
                    }
                }
                .frame(height: 200)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(categoryData, id: \.category) { data in
                        HStack {
                            Circle()
                                .fill(data.color)
                                .frame(width: 12, height: 12)
                            Text(data.category)
                                .font(.caption)
                                .foregroundColor(themeManager.textPrimary)
                            Spacer()
                            Text("$\(Int(data.amount))")
                                .font(.caption)
                                .bold()
                                .foregroundColor(themeManager.textPrimary)
                        }
                    }
                }
            } else {
                Text("Requires iOS 16+")
                    .foregroundColor(themeManager.textSecondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.headline)
                .foregroundColor(themeManager.primaryColor)

            VStack(spacing: 12) {
                insightCard(title: "Top Spending Category",
                            value: topCategory,
                            icon: "chart.bar.fill",
                            color: .orange)

                insightCard(title: "Average Daily Spend",
                            value: String(format: "$%.2f", averageDailySpend),
                            icon: "calendar",
                            color: .blue)

                insightCard(title: "This Period vs Last",
                            value: periodComparison,
                            icon: "arrow.up.right",
                            color: periodComparisonColor)
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }

    private func insightCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(themeManager.textPrimary)
            }

            Spacer()
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(8)
    }

    // MARK: Helpers & Computed Properties

    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .quarter:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }

        return transactions.filter {
            guard let date = $0.date else { return false }
            return date >= startDate && date <= now
        }
    }

    private var trendData: [(period: String, amount: Double)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        switch selectedPeriod {
        case .week:
            formatter.dateFormat = "EEE"
            return groupTransactionsByDay(formatter: formatter)
        case .month:
            formatter.dateFormat = "MMM d"
            return groupTransactionsByWeek(formatter: formatter)
        case .quarter, .year:
            formatter.dateFormat = "MMM"
            return groupTransactionsByMonth(formatter: formatter)
        }
    }

    private func groupTransactionsByDay(formatter: DateFormatter) -> [(String, Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions.filter { $0.isExpense }) {
            calendar.startOfDay(for: $0.date ?? Date())
        }
        return grouped.map { (date, txns) in
            (formatter.string(from: date), txns.reduce(0) { $0 + ($1.amount?.doubleValue ?? 0) })
        }.sorted { $0.0 < $1.0 }
    }

    private func groupTransactionsByWeek(formatter: DateFormatter) -> [(String, Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions.filter { $0.isExpense }) {
            calendar.dateInterval(of: .weekOfYear, for: $0.date ?? Date())?.start ?? Date()
        }
        return grouped.map { (date, txns) in
            (formatter.string(from: date), txns.reduce(0) { $0 + ($1.amount?.doubleValue ?? 0) })
        }.sorted { $0.0 < $1.0 }
    }

    private func groupTransactionsByMonth(formatter: DateFormatter) -> [(String, Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions.filter { $0.isExpense }) {
            calendar.dateInterval(of: .month, for: $0.date ?? Date())?.start ?? Date()
        }
        return grouped.map { (date, txns) in
            (formatter.string(from: date), txns.reduce(0) { $0 + ($1.amount?.doubleValue ?? 0) })
        }.sorted { $0.0 < $1.0 }
    }

    private var categoryData: [(category: String, amount: Double, color: Color)] {
        let expenses = filteredTransactions.filter { $0.isExpense }
        let grouped = Dictionary(grouping: expenses) { $0.category ?? "Other" }
        return grouped.map { (category, txns) in
            (category, txns.reduce(0) { $0 + ($1.amount?.doubleValue ?? 0) }, categoryColor(for: category))
        }.sorted { $0.1 > $1.1 }
    }

    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "food": return .orange
        case "transport": return .blue
        case "shopping": return .purple
        case "salary": return .green
        case "entertainment": return .pink
        case "health": return .red
        case "education": return .indigo
        case "utilities": return .yellow
        case "rent": return .brown
        case "investment": return .mint
        default: return .gray
        }
    }

    private var topCategory: String {
        categoryData.first?.category ?? "None"
    }

    private var averageDailySpend: Double {
        let expenses = filteredTransactions.filter { $0.isExpense }
        let totalSpent = expenses.reduce(0) { $0 + ($1.amount?.doubleValue ?? 0) }
        let days: Double
        switch selectedPeriod {
        case .week: days = 7
        case .month: days = 30
        case .quarter: days = 90
        case .year: days = 365
        }
        return totalSpent / days
    }

    private var periodComparison: String {
        // Placeholder: real comparison logic to be implemented
        let randomValue = Double.random(in: -20 ... 20)
        return String(format: "%.1f%%", randomValue)
    }

    private var periodComparisonColor: Color {
        periodComparison.hasPrefix("-") ? .red : .green
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

