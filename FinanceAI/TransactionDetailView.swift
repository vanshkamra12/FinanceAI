import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var note: String = ""
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()

    private let categories = ["Food", "Transport", "Shopping", "Entertainment", "Utilities", "Healthcare", "Other"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: 20) {
                        amountSection
                        categorySection
                        typeSection
                        dateSection
                        noteSection
                        deleteSection
                    }
                    .padding(20)
                }
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .onAppear {
                loadTransactionData()
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(themeManager.textSecondary)

            Spacer()

            Text("Edit Transaction")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)

            Spacer()

            Button("Save") {
                saveTransaction()
            }
            .disabled(!canSave)
            .foregroundColor(canSave ? themeManager.primaryColor : themeManager.textSecondary)
            .fontWeight(.bold)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(themeManager.cardColor)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            TextField("$0.00", text: $amount)
                .keyboardType(.decimalPad)
                .font(.largeTitle)
                .fontWeight(.bold)
                .textFieldStyle(CustomTextFieldStyle(themeManager: themeManager))
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(categories, id: \.self) { cat in
                    categoryButton(cat)
                }
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private func categoryButton(_ cat: String) -> some View {
        Button {
            category = cat
        } label: {
            HStack {
                CategoryIcon(category: cat, size: 16)
                Text(cat)
                    .font(.subheadline)
                Spacer()
            }
            .padding(12)
            .background(category == cat ? themeManager.primaryColor : themeManager.backgroundColor)
            .foregroundColor(category == cat ? .white : themeManager.textPrimary)
            .cornerRadius(10)
        }
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Picker("Type", selection: $isExpense) {
                Text("Income").tag(false)
                Text("Expense").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(themeManager.accentColor)
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            DatePicker("Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Note")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            TextEditor(text: $note)
                .frame(minHeight: 80, maxHeight: 120)
                .padding(8)
                .background(themeManager.backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.textSecondary.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private var deleteSection: some View {
        Button {
            deleteTransaction()
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Transaction")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(themeManager.errorColor)
            .cornerRadius(12)
        }
        .padding()
    }

    private var canSave: Bool {
        Decimal(string: amount) != nil && !category.isEmpty
    }

    private func loadTransactionData() {
        amount = transaction.amount?.stringValue ?? ""
        category = transaction.category ?? ""
        note = transaction.note ?? ""
        isExpense = transaction.isExpense
        date = transaction.date ?? Date()
    }

    private func saveTransaction() {
        guard let decimalAmount = Decimal(string: amount) else { return }
        transaction.amount = NSDecimalNumber(decimal: decimalAmount)
        transaction.category = category
        transaction.note = note.isEmpty ? nil : note
        transaction.isExpense = isExpense
        transaction.date = date

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save transaction: \(error.localizedDescription)")
        }
    }

    private func deleteTransaction() {
        viewContext.delete(transaction)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to delete transaction: \(error.localizedDescription)")
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    let themeManager: ThemeManager
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(themeManager.backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.textSecondary.opacity(0.3), lineWidth: 1)
            )
    }
}

struct TransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sample = Transaction(context: context)
        sample.id = UUID()
        sample.amount = 25
        sample.category = "Food"
        sample.date = Date()
        sample.isExpense = true

        return TransactionDetailView(transaction: sample)
            .environment(\.managedObjectContext, context)
            .environmentObject(ThemeManager())
    }
}

