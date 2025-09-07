import SwiftUI
import CoreData

struct TransactionTemplateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        entity: TransactionTemplate.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionTemplate.name, ascending: true)]
    ) private var templates: FetchedResults<TransactionTemplate>
    
    @State private var showingAddTemplate = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                if templates.isEmpty {
                    emptyStateView
                } else {
                    templatesListView
                }
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTemplate) {
                AddTransactionTemplateView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(themeManager)
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
            
            VStack {
                Text("Transaction Templates")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("\(templates.count) templates")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Button("Add") {
                showingAddTemplate = true
            }
            .foregroundColor(themeManager.primaryColor)
            .fontWeight(.semibold)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(themeManager.textSecondary)
            
            VStack(spacing: 8) {
                Text("No Templates Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Create templates for frequently used transactions like rent, salary, or coffee purchases")
                    .font(.body)
                    .foregroundColor(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingAddTemplate = true
            } label: {
                Text("Create Your First Template")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var templatesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(templates, id: \.id) { template in
                    templateCard(for: template)
                }
                
                addTemplateButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func templateCard(for template: TransactionTemplate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryIcon(category: template.category ?? "Other", size: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name ?? "Untitled Template")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(template.category ?? "Uncategorized")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let amount = template.amount {
                        Text(template.isExpense ? "-$\(amount.stringValue)" : "+$\(amount.stringValue)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(template.isExpense ? themeManager.errorColor : themeManager.successColor)
                    } else {
                        Text("Variable Amount")
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    }
                    
                    Text(template.isExpense ? "Expense" : "Income")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
            
            if let note = template.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(themeManager.textSecondary)
                    .padding(.top, 4)
            }
            
            HStack(spacing: 12) {
                Button("Use Template") {
                    useTemplate(template)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(themeManager.accentColor)
                .cornerRadius(20)
                
                Button("Edit") {
                    editTemplate(template)
                }
                .foregroundColor(themeManager.primaryColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(themeManager.primaryColor.opacity(0.1))
                .cornerRadius(20)
                
                Spacer()
                
                Button("Delete") {
                    deleteTemplate(template)
                }
                .foregroundColor(themeManager.errorColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(themeManager.errorColor.opacity(0.1))
                .cornerRadius(20)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var addTemplateButton: some View {
        Button {
            showingAddTemplate = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add New Template")
                    .font(.headline)
                Spacer()
            }
            .foregroundColor(themeManager.primaryColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(themeManager.cardColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.primaryColor, style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
    }
    
    private func useTemplate(_ template: TransactionTemplate) {
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = template.amount
        transaction.category = template.category
        transaction.note = template.note
        transaction.isExpense = template.isExpense
        transaction.date = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func editTemplate(_ template: TransactionTemplate) {
        // Implementation for editing template
    }
    
    private func deleteTemplate(_ template: TransactionTemplate) {
        template.isActive = false
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddTransactionTemplateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var templateName: String = ""
    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var note: String = ""
    @State private var isExpense: Bool = true
    @State private var hasFixedAmount: Bool = true
    
    private let categories = ["Food", "Transport", "Shopping", "Salary", "Rent", "Utilities", "Entertainment", "Other"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        templateBasicInfo
                        templateAmountSection
                        templateCategorySection
                        templateNotesSection
                    }
                    .padding(20)
                }
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(themeManager.textSecondary)
            
            Spacer()
            
            Text("New Template")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
            
            Button("Save") {
                saveTemplate()
            }
            .foregroundColor(themeManager.primaryColor)
            .fontWeight(.semibold)
            .disabled(!canSave)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var templateBasicInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Template Details")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Template Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textSecondary)
                
                TextField("e.g., Coffee Shop Visit", text: $templateName)
                    .textFieldStyle(CustomTextFieldStyle(themeManager: themeManager))
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var templateAmountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount Settings")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 16) {
                Toggle("Fixed Amount", isOn: $hasFixedAmount)
                    .tint(themeManager.accentColor)
                
                if hasFixedAmount {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.textSecondary)
                        
                        TextField("$0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(CustomTextFieldStyle(themeManager: themeManager))
                    }
                } else {
                    Text("Amount will be entered when using this template")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Toggle("Expense", isOn: $isExpense)
                    .tint(themeManager.errorColor)
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var templateCategorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        categoryChip(category: cat)
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
    
    private func categoryChip(category: String) -> some View {
        Text(category)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(self.category == category ? .white : themeManager.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                self.category == category
                ? themeManager.primaryColor
                : themeManager.backgroundColor
            )
            .cornerRadius(20)
            .onTapGesture {
                self.category = category
            }
    }
    
    private var templateNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes (Optional)")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            TextField("Add any notes or description", text: $note, axis: .vertical)
                .lineLimit(3...5)
                .textFieldStyle(CustomTextFieldStyle(themeManager: themeManager))
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var canSave: Bool {
        !templateName.isEmpty && !category.isEmpty && (!hasFixedAmount || !amount.isEmpty)
    }
    
    private func saveTemplate() {
        let template = TransactionTemplate(context: viewContext)
        template.id = UUID()
        template.name = templateName
        template.amount = hasFixedAmount ? NSDecimalNumber(string: amount) : nil
        template.category = category
        template.note = note.isEmpty ? nil : note
        template.isExpense = isExpense
        template.isActive = true
        template.createdDate = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct TransactionTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionTemplateView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

