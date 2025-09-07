import SwiftUI
import CoreData

struct CategoryManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) private var categories: FetchedResults<Category>
    
    @State private var newCategoryName: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Add new category
                HStack {
                    TextField("New category name", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add") {
                        addCategory()
                    }
                    .disabled(newCategoryName.isEmpty)
                }
                .padding()
                
                // List existing categories
                List {
                    ForEach(categories, id: \.id) { category in
                        Text(category.name ?? "Unnamed")
                    }
                    .onDelete(perform: deleteCategories)
                }
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            createDefaultCategoriesIfNeeded()
        }
    }
    
    private func addCategory() {
        let category = Category(context: viewContext)
        category.id = UUID()
        category.name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        newCategoryName = ""
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        offsets.map { categories[$0] }.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func createDefaultCategoriesIfNeeded() {
        if categories.isEmpty {
            let defaultCategories = ["Food", "Transport", "Shopping", "Salary", "Other"]
            for categoryName in defaultCategories {
                let category = Category(context: viewContext)
                category.id = UUID()
                category.name = categoryName
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct CategoryManagementView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryManagementView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
