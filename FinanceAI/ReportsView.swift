import SwiftUI
import CoreData
import PDFKit

struct ReportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var transactions: FetchedResults<Transaction>
    
    @State private var selectedPeriod: ReportPeriod = .thisMonth
    @State private var showingPDFView = false
    @State private var generatedPDF: Data?
    
    enum ReportPeriod: String, CaseIterable {
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
        case thisYear = "This Year"
        case lastYear = "Last Year"
        case custom = "Custom Range"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        periodSelector
                        summaryCards
                        categoryBreakdown
                        trendAnalysis
                        actionButtons
                    }
                    .padding(20)
                }
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPDFView) {
                if let pdfData = generatedPDF {
                    PDFViewWrapper(pdfData: pdfData)
                }
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
                Text("Reports")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Financial insights & analysis")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Button {
                generatePDFReport()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(themeManager.primaryColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Report Period")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                        periodChip(period: period)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func periodChip(period: ReportPeriod) -> some View {
        Text(period.rawValue)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(selectedPeriod == period ? .white : themeManager.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                selectedPeriod == period
                ? themeManager.primaryColor
                : themeManager.backgroundColor
            )
            .cornerRadius(20)
            .onTapGesture {
                selectedPeriod = period
            }
    }
    
    private var summaryCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                summaryCard(
                    title: "Total Income",
                    amount: periodIncome,
                    change: "+12.5%",
                    isPositive: true
                )
                
                summaryCard(
                    title: "Total Expenses",
                    amount: periodExpenses,
                    change: "-5.2%",
                    isPositive: false
                )
            }
            
            HStack(spacing: 16) {
                summaryCard(
                    title: "Net Savings",
                    amount: periodIncome - periodExpenses,
                    change: "+18.7%",
                    isPositive: true
                )
                
                summaryCard(
                    title: "Avg Daily Spend",
                    amount: periodExpenses / Decimal(30),
                    change: "-2.1%",
                    isPositive: false
                )
            }
        }
    }
    
    private func summaryCard(title: String, amount: Decimal, change: String, isPositive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            
            Text("$\(amount.description)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(themeManager.textPrimary)
            
            HStack {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                Text(change)
                    .font(.caption)
            }
            .foregroundColor(isPositive ? themeManager.successColor : themeManager.errorColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }
    
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(topCategories, id: \.category) { data in
                    categoryRow(data: data)
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func categoryRow(data: (category: String, amount: Decimal, percentage: Double)) -> some View {
        HStack {
            CategoryIcon(category: data.category, size: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(data.category)
                    .font(.subheadline)
                    .foregroundColor(themeManager.textPrimary)
                
                ProgressView(value: data.percentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: themeManager.accentColor))
                    .scaleEffect(x: 1, y: 0.5)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(data.amount.description)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("\(Int(data.percentage * 100))%")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
    }
    
    private var trendAnalysis: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trend Analysis")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                trendItem(
                    title: "Spending Pattern",
                    description: "Your spending has decreased by 5% compared to last period",
                    trend: .down,
                    isGood: true
                )
                
                trendItem(
                    title: "Budget Performance",
                    description: "You're 15% under budget across all categories",
                    trend: .down,
                    isGood: true
                )
                
                trendItem(
                    title: "Savings Rate",
                    description: "Your savings rate improved by 8% this period",
                    trend: .up,
                    isGood: true
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func trendItem(title: String, description: String, trend: TrendDirection, isGood: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: trend == .up ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.title2)
                .foregroundColor(isGood ? themeManager.successColor : themeManager.errorColor)
            
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
        }
    }
    
    enum TrendDirection {
        case up, down
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                generatePDFReport()
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("Generate PDF Report")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(themeManager.primaryColor)
                .cornerRadius(12)
            }
            
            Button {
                shareCSVData()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Data (CSV)")
                }
                .font(.headline)
                .foregroundColor(themeManager.primaryColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(themeManager.cardColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.primaryColor, lineWidth: 2)
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return transactions.filter {
                guard let date = $0.date else { return false }
                return date >= startOfMonth
            }
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            let startOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? now
            let endOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.end ?? now
            return transactions.filter {
                guard let date = $0.date else { return false }
                return date >= startOfLastMonth && date < endOfLastMonth
            }
        case .thisYear:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return transactions.filter {
                guard let date = $0.date else { return false }
                return date >= startOfYear
            }
        case .lastYear:
            let lastYear = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            let startOfLastYear = calendar.dateInterval(of: .year, for: lastYear)?.start ?? now
            let endOfLastYear = calendar.dateInterval(of: .year, for: lastYear)?.end ?? now
            return transactions.filter {
                guard let date = $0.date else { return false }
                return date >= startOfLastYear && date < endOfLastYear
            }
        case .custom:
            return Array(transactions) // For now, return all
        }
    }
    
    private var periodIncome: Decimal {
        filteredTransactions
            .filter { !$0.isExpense }
            .reduce(0) { $0 + ($1.amount as Decimal? ?? 0) }
    }
    
    private var periodExpenses: Decimal {
        filteredTransactions
            .filter { $0.isExpense }
            .reduce(0) { $0 + ($1.amount as Decimal? ?? 0) }
    }
    
    private var topCategories: [(category: String, amount: Decimal, percentage: Double)] {
        let expenses = filteredTransactions.filter { $0.isExpense }
        let grouped = Dictionary(grouping: expenses) { $0.category ?? "Other" }
        let total = periodExpenses
        
        return grouped.map { (category, transactions) in
            let amount = transactions.reduce(Decimal(0)) { $0 + ($1.amount as Decimal? ?? 0) }
            let percentage = total > 0 ? Double(truncating: amount as NSNumber) / Double(truncating: total as NSNumber) : 0
            return (category, amount, percentage)
        }
        .sorted { $0.amount > $1.amount }
        .prefix(5)
        .map { $0 }
    }
    
    // MARK: - Functions
    
    private func generatePDFReport() {
        // Simplified PDF generation - in a real app, you'd use a proper PDF generation library
        let reportHTML = generateHTMLReport()
        
        if let data = reportHTML.data(using: .utf8) {
            generatedPDF = data
            showingPDFView = true
        }
    }
    
    private func generateHTMLReport() -> String {
        return """
        <html>
        <body>
        <h1>Financial Report - \(selectedPeriod.rawValue)</h1>
        <h2>Summary</h2>
        <p>Total Income: $\(periodIncome)</p>
        <p>Total Expenses: $\(periodExpenses)</p>
        <p>Net Savings: $\(periodIncome - periodExpenses)</p>
        <h2>Top Categories</h2>
        \(topCategories.map { "<p>\($0.category): $\($0.amount)</p>" }.joined())
        </body>
        </html>
        """
    }
    
    private func shareCSVData() {
        // Implement CSV sharing
    }
}

struct PDFViewWrapper: UIViewRepresentable {
    let pdfData: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: pdfData)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

