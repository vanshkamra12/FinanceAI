import SwiftUI

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) private var categories: FetchedResults<Category>

    @State private var amountText: String = ""
    @State private var date: Date = Date()
    @State private var selectedCategoryName: String = ""
    @State private var note: String = ""
    @State private var isExpense: Bool = true
    @State private var showingCategoryManagement = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount").foregroundColor(themeManager.textPrimary)) {
                    HStack {
                        Text("$")
                            .font(.title2)
                            .foregroundColor(themeManager.textSecondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(themeManager.textPrimary)
                    }
                }

                Section(header: Text("Date").foregroundColor(themeManager.textPrimary)) {
                    DatePicker("Select Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }

                Section(header: Text("Category").foregroundColor(themeManager.textPrimary)) {
                    Picker("Category", selection: $selectedCategoryName) {
                        ForEach(categories, id: \.id) { cat in
                            Text(cat.name ?? "Unnamed").tag(cat.name ?? "")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Note").foregroundColor(themeManager.textPrimary)) {
                    TextField("Optional note", text: $note)
                        .foregroundColor(themeManager.textPrimary)
                }

                Section {
                    Toggle(isOn: $isExpense) {
                        Text("Expense")
                            .foregroundColor(themeManager.textPrimary)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                }

            }
            .navigationTitle("New Transaction")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!canSave)
                    .foregroundColor(canSave ? themeManager.accentColor : themeManager.textSecondary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Categories") {
                        showingCategoryManagement = true
                    }
                    .foregroundColor(themeManager.primaryColor)
                }
            }
            .sheet(isPresented: $showingCategoryManagement) {
                CategoryManagementView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(themeManager)
            }
            .accentColor(themeManager.accentColor)
            .background(themeManager.backgroundColor.ignoresSafeArea())
        }
    }

    private var canSave: Bool {
        guard let amount = Decimal(string: amountText), amount > 0 else { return false }
        return !selectedCategoryName.isEmpty
    }

    private func saveTransaction() {
        let txn = Transaction(context: viewContext)
        txn.id = UUID()
        txn.amount = NSDecimalNumber(string: amountText)
        txn.date = date
        txn.category = selectedCategoryName
        txn.note = note.isEmpty ? nil : note
        txn.isExpense = isExpense

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            print("Save error: \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

