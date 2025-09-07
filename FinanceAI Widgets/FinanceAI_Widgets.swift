import WidgetKit
import SwiftUI

struct FinanceAIWidget: Widget {
    let kind: String = "FinanceAIWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FinanceProvider()) { entry in
            FinanceWidgetView(entry: entry)
        }
        .configurationDisplayName("Finance Balance")
        .description("View your current balance and recent transactions")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Provider
struct FinanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> FinanceEntry {
        FinanceEntry(
            date: Date(),
            balance: 2450.00,
            totalIncome: 5000.00,
            totalExpenses: 2550.00,
            recentTransactions: [
                TransactionData(category: "Food", amount: -25.50, date: Date()),
                TransactionData(category: "Transport", amount: -12.00, date: Date()),
                TransactionData(category: "Salary", amount: 3000.00, date: Date())
            ]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FinanceEntry) -> ()) {
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FinanceEntry>) -> ()) {
        let entry = placeholder(in: context)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget Entry
struct FinanceEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let totalIncome: Double
    let totalExpenses: Double
    let recentTransactions: [TransactionData]
}

struct TransactionData {
    let category: String
    let amount: Double
    let date: Date
}

// MARK: - Widget Views
struct FinanceWidgetView: View {
    var entry: FinanceProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (Balance Only)
struct SmallWidgetView: View {
    let entry: FinanceEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Balance")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatCurrency(entry.balance))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(entry.balance >= 0 ? .green : .red)
            
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                Text(formatCurrency(entry.totalIncome))
                    .font(.caption2)
            }
            
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                Text(formatCurrency(entry.totalExpenses))
                    .font(.caption2)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Medium Widget (Balance + Recent Transactions)
struct MediumWidgetView: View {
    let entry: FinanceEntry
    
    var body: some View {
        HStack {
            // Balance Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(entry.balance))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(entry.balance >= 0 ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption2)
                        Text(formatCurrency(entry.totalIncome))
                            .font(.caption2)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption2)
                        Text(formatCurrency(entry.totalExpenses))
                            .font(.caption2)
                    }
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Recent Transactions
            VStack(alignment: .trailing, spacing: 6) {
                Text("Recent")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(entry.recentTransactions.prefix(3), id: \.category) { transaction in
                    HStack(spacing: 4) {
                        Text(transaction.category)
                            .font(.caption2)
                            .lineLimit(1)
                        
                        Text(formatCurrency(abs(transaction.amount)))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Large Widget (Full Dashboard)
struct LargeWidgetView: View {
    let entry: FinanceEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with Balance
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatCurrency(entry.balance))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(entry.balance >= 0 ? .green : .red)
                }
                
                Spacer()
                
                Text("FinanceAI")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Income/Expense Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Income")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(formatCurrency(entry.totalIncome))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Expenses")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(formatCurrency(entry.totalExpenses))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Recent Transactions
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Transactions")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ForEach(entry.recentTransactions.prefix(4), id: \.category) { transaction in
                    HStack {
                        CategoryIconWidget(category: transaction.category)
                        
                        Text(transaction.category)
                            .font(.caption)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(formatCurrency(transaction.amount))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                    }
                }
                
                if entry.recentTransactions.isEmpty {
                    Text("No recent transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Category Icon for Widget
struct CategoryIconWidget: View {
    let category: String
    
    var body: some View {
        Image(systemName: iconName)
            .font(.caption)
            .foregroundColor(iconColor)
            .frame(width: 16, height: 16)
    }
    
    private var iconName: String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "entertainment": return "gamecontroller.fill"
        case "utilities": return "bolt.fill"
        case "healthcare": return "cross.fill"
        case "salary", "income": return "dollarsign.circle.fill"
        default: return "circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch category.lowercased() {
        case "food": return .orange
        case "transport": return .blue
        case "shopping": return .purple
        case "entertainment": return .pink
        case "utilities": return .yellow
        case "healthcare": return .red
        case "salary", "income": return .green
        default: return .gray
        }
    }
}

// MARK: - Helper Functions
private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: amount)) ?? "$0"
}

