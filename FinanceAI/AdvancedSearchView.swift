import SwiftUI
import CoreData

struct AdvancedSearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var allTransactions: FetchedResults<Transaction>

    @State private var searchText: String = ""
    @State private var selectedCategories: Set<String> = []
    @State private var minAmount: String = ""
    @State private var maxAmount: String = ""
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    @State private var transactionType: TransactionType = .all
    @State private var sortBy: SortOption = .date
    @State private var savedSearches: [SavedSearch] = []
    @State private var showingSaveSearch: Bool = false
    @State private var searchName: String = ""

    enum TransactionType: String, CaseIterable, Identifiable {
        case all = "All"
        case income = "Income"
        case expense = "Expenses"
        var id: String { rawValue }
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case amount = "Amount"
        case category = "Category"
        var id: String { rawValue }
    }

    var filteredTransactions: [Transaction] {
        var filtered = Array(allTransactions)

        if !searchText.isEmpty {
            filtered = filtered.filter {
                ($0.category?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.note?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        if !selectedCategories.isEmpty {
            filtered = filtered.filter { selectedCategories.contains($0.category ?? "") }
        }

        if let min = Double(minAmount) {
            filtered = filtered.filter { ($0.amount?.doubleValue ?? 0) >= min }
        }

        if let max = Double(maxAmount) {
            filtered = filtered.filter { ($0.amount?.doubleValue ?? 0) <= max }
        }

        filtered = filtered.filter {
            guard let date = $0.date else { return false }
            return date >= startDate && date <= endDate
        }

        switch transactionType {
        case .all: break
        case .income: filtered = filtered.filter { !$0.isExpense }
        case .expense: filtered = filtered.filter { $0.isExpense }
        }

        switch sortBy {
        case .date: filtered.sort { ($0.date ?? Date()) > ($1.date ?? Date()) }
        case .amount: filtered.sort { ($0.amount?.doubleValue ?? 0) > ($1.amount?.doubleValue ?? 0) }
        case .category: filtered.sort { ($0.category ?? "") < ($1.category ?? "") }
        }

        return filtered
    }

    var availableCategories: [String] {
        Set(allTransactions.compactMap { $0.category }).sorted()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 20) {
                        savedSearchesSection
                        filtersSection
                        resultsSection
                    }
                    .padding()
                }
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSaveSearch) {
                saveSearchSheet
            }
        }
    }

    private var header: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundColor(themeManager.textSecondary)

            Spacer()

            VStack {
                Text("Advanced Search")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Text("\(filteredTransactions.count) results")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }

            Spacer()

            Button("Save") { showingSaveSearch = true }
                .foregroundColor(themeManager.primaryColor)
                .disabled(searchName.isEmpty)
        }
        .padding()
        .background(themeManager.cardColor)
        .shadow(color: Color.black.opacity(0.05), radius: 1, y: 1)
    }

    private var savedSearchesSection: some View {
        VStack(alignment: .leading) {
            Text("Saved Searches")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(savedSearches, id: \.name) { search in
                        savedSearchChip(search)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }

    private func savedSearchChip(_ search: SavedSearch) -> some View {
        Text(search.name)
            .font(.caption)
            .foregroundColor(.white)
            .padding(8)
            .background(themeManager.accentColor)
            .cornerRadius(16)
            .onTapGesture { applySavedSearch(search) }
    }

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.textSecondary)
                TextField("Search in categories and notes...", text: $searchText)
                    .textFieldStyle(CustomTextFieldStyle(themeManager: themeManager))
            }
            .padding()
            .background(themeManager.cardColor)
            .cornerRadius(12)

            VStack(alignment: .leading) {
                Text("Amount Range").font(.subheadline).foregroundColor(themeManager.textPrimary)
                HStack {
                    TextField("Min", text: $minAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(CustomTextFieldStyle(themeManager: themeManager))
                    Text("to").foregroundColor(themeManager.textSecondary)
                    TextField("Max", text: $maxAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(CustomTextFieldStyle(themeManager: themeManager))
                }
            }
            .padding()
            .background(themeManager.cardColor)
            .cornerRadius(12)

            VStack(alignment: .leading) {
                Text("Date Range").font(.subheadline).foregroundColor(themeManager.textPrimary)
                HStack {
                    DatePicker("From", selection: $startDate, displayedComponents: .date)
                    DatePicker("To", selection: $endDate, displayedComponents: .date)
                }
                .font(.subheadline)
            }
            .padding()
            .background(themeManager.cardColor)
            .cornerRadius(12)

            VStack(alignment: .leading) {
                Text("Categories").font(.subheadline).foregroundColor(themeManager.textPrimary)
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                    ForEach(availableCategories, id: \.self) { category in
                        categoryFilterChip(category)
                    }
                }
            }
            .padding()
            .background(themeManager.cardColor)
            .cornerRadius(12)

            HStack {
                VStack(alignment: .leading) {
                    Text("Type").font(.subheadline).foregroundColor(themeManager.textPrimary)
                    Picker("Type", selection: $transactionType) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .tint(themeManager.accentColor)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Sort By").font(.subheadline).foregroundColor(themeManager.textPrimary)
                    Picker("Sort", selection: $sortBy) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .tint(themeManager.accentColor)
                }
            }
            .padding()
        }
    }

    private func categoryFilterChip(_ category: String) -> some View {
        Text(category)
            .font(.caption)
            .foregroundColor(selectedCategories.contains(category) ? .white : themeManager.textPrimary)
            .padding(8)
            .background(selectedCategories.contains(category) ? themeManager.accentColor : themeManager.backgroundColor)
            .cornerRadius(16)
            .onTapGesture {
                if selectedCategories.contains(category) {
                    selectedCategories.remove(category)
                } else {
                    selectedCategories.insert(category)
                }
            }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading) {
            Text("Results (\(filteredTransactions.count))")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            LazyVStack(spacing: 12) {
                ForEach(filteredTransactions, id: \.id) { transaction in
                    resultRow(transaction)
                }
            }
            .padding()
        }
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }

    private func resultRow(_ transaction: Transaction) -> some View {
        HStack {
            CategoryIcon(category: transaction.category ?? "Other", size: 16)

            VStack(alignment: .leading) {
                Text(transaction.category ?? "Uncategorized")
                    .font(.subheadline)
                    .foregroundColor(themeManager.textPrimary)

                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }

                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }

            Spacer()

            Text(transaction.isExpense ?
                 "-$\(transaction.amount?.stringValue ?? "0")" :
                 "+$\(transaction.amount?.stringValue ?? "0")")
            .font(.subheadline)
            .foregroundColor(transaction.isExpense ? themeManager.errorColor : themeManager.successColor)
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }

    private var saveSearchSheet: some View {
        NavigationView {
            VStack {
                TextField("Search Name", text: $searchName)
                    .textFieldStyle(CustomTextFieldStyle(themeManager: themeManager))
                    .padding()

                Button("Save Search") {
                    saveCurrentSearch()
                }
                .disabled(searchName.isEmpty)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()

                Spacer()
            }
            .navigationTitle("Save Search")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingSaveSearch = false }
                }
            }
        }
    }

    private func saveCurrentSearch() {
        let newSearch = SavedSearch(
            name: searchName,
            searchText: searchText,
            selectedCategories: Array(selectedCategories),
            minAmount: minAmount,
            maxAmount: maxAmount,
            startDate: startDate,
            endDate: endDate,
            transactionType: transactionType,
            sortBy: sortBy
        )
        savedSearches.append(newSearch)
        showingSaveSearch = false
        searchName = ""
    }

    private func applySavedSearch(_ search: SavedSearch) {
        searchText = search.searchText
        selectedCategories = Set(search.selectedCategories)
        minAmount = search.minAmount
        maxAmount = search.maxAmount
        startDate = search.startDate
        endDate = search.endDate
        transactionType = search.transactionType
        sortBy = search.sortBy
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct SavedSearch: Identifiable {
    let id = UUID()
    var name: String
    var searchText: String
    var selectedCategories: [String]
    var minAmount: String
    var maxAmount: String
    var startDate: Date
    var endDate: Date
    var transactionType: AdvancedSearchView.TransactionType
    var sortBy: AdvancedSearchView.SortOption
}

struct SearchTextFieldStyle: TextFieldStyle {
    let themeManager: ThemeManager

    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(themeManager.backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.textSecondary.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(themeManager.textPrimary)
    }
}

struct AdvancedSearchView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSearchView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

