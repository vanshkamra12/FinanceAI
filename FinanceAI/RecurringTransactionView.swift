import SwiftUI
import CoreData

struct RecurringTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) private var categories: FetchedResults<Category>
    
    @FetchRequest(
        entity: RecurringTransaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RecurringTransaction.nextDate, ascending: true)]
    ) private var recurringTransactions: FetchedResults<RecurringTransaction>
    
    @State private var amountText: String = ""
    @State private var selectedCategory: String = ""
    @State private var note: String = ""
    @State private var isExpense: Bool = true
    @State private var frequency: String = "Monthly"
    @State private var nextDate: Date = Date()
    
    private let frequencies = ["Weekly", "Bi-weekly", "Monthly", "Quarterly", "Yearly"]
    
    var body: some View {
        NavigationView {
            VStack {
                addRecurringSection
                recurringListSection
            }
            .navigationTitle("Recurring Transactions")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        processOverdueTransactions()
                        dismiss()
                    }
                }
            }
            .onAppear {
                processOverdueTransactions()
            }
        }
    }
    
    private var addRecurringSection: some View {
        Form {
            Section("New Recurring Transaction") {
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                
                Picker("Category", selection: $selectedCategory) {
                    Text("Select Category").tag("")
                    ForEach(categories, id: \.id) { category in
                        Text(category.name ?? "Unknown").tag(category.name ?? "")
                    }
                }
                
                TextField("Note (optional)", text: $note)
                
                Toggle("Expense", isOn: $isExpense)
                
                Picker("Frequency", selection: $frequency) {
                    ForEach(frequencies, id: \.self) { freq in
                        Text(freq).tag(freq)
                    }
                }
                
                DatePicker("Next Date", selection: $nextDate, displayedComponents: .date)
                
                Button("Add Recurring Transaction") {
                    addRecurringTransaction()
                }
                .disabled(amountText.isEmpty || selectedCategory.isEmpty)
            }
        }
        .frame(maxHeight: 400)
    }
    
    private var recurringListSection: some View {
        VStack {
            Text("Active Recurring Transactions")
                .font(.headline)
                .padding()
            
            List {
                ForEach(recurringTransactions.filter { $0.isActive }, id: \.id) { recurring in
                    recurringRow(for: recurring)
                }
                .onDelete(perform: deleteRecurring)
            }
        }
    }
    
    private func recurringRow(for recurring: RecurringTransaction) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(recurring.category ?? "Unknown")
                    .font(.headline)
                Spacer()
                Text(recurring.isExpense ? "-$\(recurring.amount?.stringValue ?? "0")" : "+$\(recurring.amount?.stringValue ?? "0")")
                    .foregroundColor(recurring.isExpense ? .red : .green)
                    .bold()
            }
            
            HStack {
                Text(recurring.frequency ?? "Monthly")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Next: \(formatDate(recurring.nextDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let note = recurring.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func addRecurringTransaction() {
        let recurring = RecurringTransaction(context: viewContext)
        recurring.id = UUID()
        recurring.amount = NSDecimalNumber(string: amountText)
        recurring.category = selectedCategory
        recurring.note = note.isEmpty ? nil : note
        recurring.isExpense = isExpense
        recurring.frequency = frequency
        recurring.nextDate = nextDate
        recurring.isActive = true
        
        // Reset form
        amountText = ""
        selectedCategory = ""
        note = ""
        isExpense = true
        frequency = "Monthly"
        nextDate = Date()
        
        saveContext()
    }
    
    private func deleteRecurring(offsets: IndexSet) {
        let activeRecurring = recurringTransactions.filter { $0.isActive }
        offsets.map { activeRecurring[$0] }.forEach { recurring in
            recurring.isActive = false
        }
        saveContext()
    }
    
    private func processOverdueTransactions() {
        let today = Date()
        
        for recurring in recurringTransactions {
            if recurring.isActive && recurring.nextDate ?? Date() <= today {
                createTransactionFromRecurring(recurring)
                updateNextDate(for: recurring)
            }
        }
    }
    
    private func createTransactionFromRecurring(_ recurring: RecurringTransaction) {
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = recurring.amount
        transaction.category = recurring.category
        transaction.note = recurring.note
        transaction.isExpense = recurring.isExpense
        transaction.date = recurring.nextDate
        
        saveContext()
    }
    
    private func updateNextDate(for recurring: RecurringTransaction) {
        let calendar = Calendar.current
        let currentNext = recurring.nextDate ?? Date()
        
        switch recurring.frequency {
        case "Weekly":
            recurring.nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentNext)
        case "Bi-weekly":
            recurring.nextDate = calendar.date(byAdding: .weekOfYear, value: 2, to: currentNext)
        case "Monthly":
            recurring.nextDate = calendar.date(byAdding: .month, value: 1, to: currentNext)
        case "Quarterly":
            recurring.nextDate = calendar.date(byAdding: .month, value: 3, to: currentNext)
        case "Yearly":
            recurring.nextDate = calendar.date(byAdding: .year, value: 1, to: currentNext)
        default:
            recurring.nextDate = calendar.date(byAdding: .month, value: 1, to: currentNext)
        }
        
        saveContext()
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

