import SwiftUI
import CoreData

struct AddGoalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    @State private var goalName: String = ""
    @State private var targetAmount: String = ""
    @State private var currentAmount: String = "0"
    @State private var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var selectedCategory: String = "Emergency Fund"

    private let goalCategories = [
        "Emergency Fund", "Vacation", "Car", "House Down Payment",
        "Education", "Retirement", "Wedding", "Investment", "Other"
    ]

    private var canSave: Bool {
        !goalName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Decimal(string: targetAmount) != nil
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: 24) {
                        goalBasicInfo
                        goalAmountSection
                        goalCategorySection
                        goalDateSection
                    }
                    .padding(20)
                }
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundColor(themeManager.textSecondary)

            Spacer()

            Text("New Goal")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)

            Spacer()

            Button("Save") {
                saveGoal()
            }
            .foregroundColor(canSave ? themeManager.accentColor : themeManager.textSecondary)
            .fontWeight(.semibold)
            .disabled(!canSave)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(themeManager.cardColor)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    private var goalBasicInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal Details")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Goal Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textSecondary)

                TextField("e.g., Emergency Fund", text: $goalName)
                    .textFieldStyle(AddCustomTextFieldStyle(themeManager: themeManager))
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private var goalAmountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Amount")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.textSecondary)

                    TextField("$0.00", text: $targetAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(AddCustomTextFieldStyle(themeManager: themeManager))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Amount")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.textSecondary)

                    TextField("$0.00", text: $currentAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(AddCustomTextFieldStyle(themeManager: themeManager))
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private var goalCategorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(goalCategories, id: \.self) { cat in
                        categoryChip(category: cat)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private func categoryChip(category: String) -> some View {
        Text(category)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(selectedCategory == category ? .white : themeManager.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Group {
                    if selectedCategory == category {
                        themeManager.accentColor
                    } else {
                        themeManager.backgroundColor
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(themeManager.textSecondary.opacity(0.3), lineWidth: 1)
            )
            .onTapGesture {
                selectedCategory = category
            }
    }

    private var goalDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target Date (Optional)")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            DatePicker(
                "Select Date",
                selection: $targetDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }

    private func saveGoal() {
        let goal = Goal(context: viewContext)
        goal.id = UUID()
        goal.name = goalName.trimmingCharacters(in: .whitespaces)
        goal.targetAmount = NSDecimalNumber(string: targetAmount)
        goal.currentAmount = NSDecimalNumber(string: currentAmount)
        goal.category = selectedCategory
        goal.targetDate = targetDate
        goal.isCompleted = false
        goal.createdDate = Date()

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            print("Save error: \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddCustomTextFieldStyle: TextFieldStyle {
    let themeManager: ThemeManager

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(themeManager.backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.textSecondary.opacity(0.3), lineWidth: 1)
            )
    }
}

struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

