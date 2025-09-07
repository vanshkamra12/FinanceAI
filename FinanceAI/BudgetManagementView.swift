import SwiftUI
import CoreData

struct BudgetManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) private var categories: FetchedResults<Category>

    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Budget.categoryName, ascending: true)]
    ) private var budgets: FetchedResults<Budget>

    @State private var selectedCategory: String = ""
    @State private var budgetAmount: String = ""

    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    private var currentMonthBudgets: [Budget] {
        budgets.filter { $0.month == currentMonth }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                addBudgetSection
                budgetListSection
            }
            .padding()
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationTitle("Budget Management")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    private var addBudgetSection: some View {
        VStack(spacing: 12) {
            HStack {
                Picker("Category", selection: $selectedCategory) {
                    Text("Select Category").tag("")
                    ForEach(categories, id: \.id) { cat in
                        Text(cat.name ?? "Unnamed").tag(cat.name ?? "")
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(themeManager.textPrimary)

                TextField("Amount", text: $budgetAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                    .foregroundColor(themeManager.textPrimary)

                Button(action: addBudget) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(canAdd ? themeManager.successColor : themeManager.textSecondary)
                }
                .disabled(!canAdd)
            }

            Text("Budgets for \(formatMonthDisplay(currentMonth))")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }

    private var budgetListSection: some View {
        List {
            ForEach(currentMonthBudgets, id: \.id) { budget in
                budgetRow(for: budget)
            }
            .onDelete(perform: deleteBudgets)
        }
        .listStyle(PlainListStyle())
        .background(themeManager.backgroundColor)
    }

    private func budgetRow(for budget: Budget) -> some View {
        let spent = getSpentAmount(for: budget.categoryName ?? "")
        let limit = budget.monthlyLimit ?? .zero
        let progress = limit.doubleValue == 0 ? 0 : min(spent.doubleValue / limit.doubleValue, 1.0)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(budget.categoryName ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Spacer()
                Text(formatCurrency(limit))
                    .foregroundColor(themeManager.accentColor)
            }

            ProgressView(value: progress)
                .tint(progress > 0.8 ? themeManager.errorColor : themeManager.successColor)

            Text("Spent \(formatCurrency(spent)) of \(formatCurrency(limit))")
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
        }
        .padding(.vertical, 4)
    }

    private var canAdd: Bool {
        guard Decimal(string: budgetAmount) != nil, !selectedCategory.isEmpty else {
            return false
        }
        return true
    }

    private func addBudget() {
        guard let amountDecimal = Decimal(string: budgetAmount) else { return }
        if let existing = budgets.first(where: { $0.categoryName == selectedCategory && $0.month == currentMonth }) {
            existing.monthlyLimit = NSDecimalNumber(decimal: amountDecimal)
        } else {
            let budget = Budget(context: viewContext)
            budget.id = UUID()
            budget.categoryName = selectedCategory
            budget.monthlyLimit = NSDecimalNumber(decimal: amountDecimal)
            budget.month = currentMonth
        }
        saveContext()
        selectedCategory = ""
        budgetAmount = ""
    }

    private func deleteBudgets(offsets: IndexSet) {
        let toDelete = offsets.compactMap { idx in currentMonthBudgets[safe: idx] }
        toDelete.forEach(viewContext.delete)
        saveContext()
    }

    private func getSpentAmount(for category: String) -> NSDecimalNumber {
        let calendar = Calendar.current
        guard let start = calendar.dateInterval(of: .month, for: Date())?.start,
              let end = calendar.dateInterval(of: .month, for: Date())?.end else {
            return .zero
        }
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(
            format: "category == %@ AND isExpense == true AND date >= %@ AND date <= %@",
            category, start as NSDate, end as NSDate
        )
        do {
            let txns = try viewContext.fetch(request)
            let total = txns.reduce(NSDecimalNumber.zero) {
                $0.adding($1.amount ?? .zero)
            }
            return total
        } catch {
            return .zero
        }
    }

    private func formatMonthDisplay(_ month: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "yyyy-MM"
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "MMMM yyyy"
        if let date = inFormatter.date(from: month) {
            return outFormatter.string(from: date)
        }
        return month
    }

    private func formatCurrency(_ number: NSDecimalNumber) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: number) ?? "$0"
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Save error: \(nsError), \(nsError.userInfo)")
        }
    }
}

// Safe index access extension
fileprivate extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct BudgetManagementView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetManagementView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

