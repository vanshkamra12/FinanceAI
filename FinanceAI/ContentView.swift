import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var notificationManager: SmartNotificationManager
    
    @State private var searchText: String = ""
    @State private var fromDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var toDate: Date = Date()
    @State private var showingAddSheet = false
    @State private var showingBudgetSheet = false
    @State private var showingRecurringSheet = false
    @State private var showingAnalyticsSheet = false
    @State private var showingThemeSheet = false
    @State private var showingGoalsSheet = false
    @State private var showingReportsSheet = false
    @State private var showingAdvancedSearchSheet = false
    @State private var showingAIInsightsSheet = false
    @State private var showingBackupSheet = false
    @State private var showingNotificationSheet = false
    @State private var showingTemplatesSheet = false
    @State private var showingTestNotificationsSheet = false
    @State private var showingSiriShortcutsSheet = false
    @State private var showingWidgetConfigSheet = false
    @State private var showingReceiptScanSheet = false
    @State private var showingApplePaySheet = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedTransactionForEdit: Transaction?
    @State private var sortOption: SortOption = .date
    @State private var showingDebugInfo = false
    @State private var selectedTransactionType: TransactionType = .expense

    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var transactions: FetchedResults<Transaction>
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.createdDate, ascending: false)]
    ) private var goals: FetchedResults<Goal>
    
    enum SortOption: String, CaseIterable {
        case date = "Date"
        case amount = "Amount"
        case category = "Category"
    }
    
    enum TransactionType {
        case income
        case expense
    }
    
    // Initialize with context for SmartNotificationManager
    init() {
        let context = PersistenceController.shared.container.viewContext
        self._notificationManager = StateObject(wrappedValue: SmartNotificationManager(context: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    summarySection
                    quickActionsGrid
                    goalsPreviewSection
                    filtersSection
                    chartSection
                    transactionListSection
                    
                    // Debug section (remove in production)
                    if showingDebugInfo {
                        debugSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .onAppear {
                updatePredicate()
                
                // Debug notification setup
                print("🔔 Setting up notifications...")
                notificationManager.requestPermission()
                
                Task {
                    await notificationManager.performAllChecks()
                    print("🔔 Notification checks completed")
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingBudgetSheet) {
            BudgetManagementView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingRecurringSheet) {
            RecurringTransactionView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingAnalyticsSheet) {
            AnalyticsView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingThemeSheet) {
            ThemeSettingsView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingGoalsSheet) {
            GoalManagementView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingReportsSheet) {
            ReportsView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingAdvancedSearchSheet) {
            AdvancedSearchView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingTestNotificationsSheet) {
            TestNotificationsView(notificationManager: notificationManager)
                .environmentObject(themeManager)
        }
        // Coming Soon Views - Fixed implementations
        .sheet(isPresented: $showingAIInsightsSheet) {
            ComingSoonView(featureName: "AI Insights")
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingBackupSheet) {
            BackupSyncView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingNotificationSheet) {
            NotificationSettingsView(context: viewContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingTemplatesSheet) {
            ComingSoonView(featureName: "Transaction Templates")
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingSiriShortcutsSheet) {
            ComingSoonView(featureName: "Siri Shortcuts")
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingWidgetConfigSheet) {
            ComingSoonView(featureName: "Widget Configuration")
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingReceiptScanSheet) {
            ComingSoonView(featureName: "Receipt Scanner")
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingApplePaySheet) {
            ComingSoonView(featureName: "Apple Pay Integration")
                .environmentObject(themeManager)
        }
        .sheet(item: $selectedTransactionForEdit) { transaction in
            TransactionDetailView(transaction: transaction)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
        .sheet(item: $selectedTransaction) { transaction in
            ReceiptPhotoView(transaction: transaction)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(themeManager)
        }
    }
    
    // MARK: - UI Sections
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back")
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text("FinanceAI")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryColor)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        showingNotificationSheet = true
                    } label: {
                        Image(systemName: "bell.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 40, height: 40)
                            .background(themeManager.cardColor)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Button {
                        showingThemeSheet = true
                    } label: {
                        Image(systemName: "paintbrush.pointed.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 40, height: 40)
                            .background(themeManager.cardColor)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Button {
                        selectedTransactionType = .expense
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [themeManager.primaryColor, themeManager.accentColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                }
            }
            
            if !goals.isEmpty {
                goalProgressBar
            }
        }
    }
    
    private var goalProgressBar: some View {
        let activeGoals = goals.filter { !$0.isCompleted }
        let totalProgress = activeGoals.reduce(0.0) { sum, goal in
            let current = goal.currentAmount?.doubleValue ?? 0
            let target = goal.targetAmount?.doubleValue ?? 1
            return sum + min(current / target, 1.0)
        }
        let averageProgress = activeGoals.isEmpty ? 0.0 : totalProgress / Double(activeGoals.count)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Goals Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textPrimary)
                
                Spacer()
                
                Text("\(Int(averageProgress * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(themeManager.accentColor)
            }
            
            ProgressView(value: averageProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.accentColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(16)
        .background(themeManager.cardColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var summarySection: some View {
        VStack(spacing: 0) {
            // Main balance card with enhanced design
            VStack(spacing: 20) {
                // Balance header
                VStack(spacing: 8) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.textSecondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(netBalance >= 0 ? themeManager.successColor : themeManager.errorColor)
                        
                        Text(formatLargeNumber(netBalance))
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(netBalance >= 0 ? themeManager.successColor : themeManager.errorColor)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: netBalance)
                    }
                    
                    // Balance change indicator
                    HStack(spacing: 4) {
                        Image(systemName: netBalance >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text("+2.5% from last month")
                            .font(.caption)
                    }
                    .foregroundColor(netBalance >= 0 ? themeManager.successColor : themeManager.errorColor)
                    .opacity(0.8)
                }
                
                // Income and Expenses cards - FIXED BUTTONS
                HStack(spacing: 16) {
                    incomeExpenseCard(
                        title: "Income",
                        amount: totalIncome,
                        icon: "arrow.down.circle.fill",
                        color: themeManager.successColor,
                        isIncome: true
                    ) {
                        selectedTransactionType = .income
                        showingAddSheet = true
                    }
                    
                    incomeExpenseCard(
                        title: "Expenses",
                        amount: totalExpenses,
                        icon: "arrow.up.circle.fill",
                        color: themeManager.errorColor,
                        isIncome: false
                    ) {
                        selectedTransactionType = .expense
                        showingAddSheet = true
                    }
                }
                
                // Quick stats row
                HStack {
                    quickStatItem(title: "Avg Daily", value: formatCurrency(totalExpenses / 30), color: themeManager.textSecondary)
                    
                    Spacer()
                    
                    quickStatItem(title: "This Month", value: "\(transactions.count) txns", color: themeManager.textSecondary)
                    
                    Spacer()
                    
                    quickStatItem(title: "Savings Rate", value: String(format: "%.0f%%", savingsRate), color: themeManager.accentColor)
                }
                .font(.caption)
            }
            .padding(24)
            .background(
                ZStack {
                    // Main background with subtle gradient
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: themeManager.cardColor, location: 0),
                            .init(color: themeManager.cardColor.opacity(0.95), location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle pattern overlay
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    themeManager.primaryColor.opacity(0.1),
                                    themeManager.accentColor.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .cornerRadius(24)
            .shadow(
                color: themeManager.primaryColor.opacity(0.1),
                radius: 20,
                x: 0,
                y: 10
            )
            .overlay(
                // Subtle shine effect
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white.opacity(0.1), location: 0),
                                .init(color: Color.white.opacity(0), location: 0.3),
                                .init(color: Color.white.opacity(0), location: 1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
    }
    
    private func incomeExpenseCard(title: String, amount: Decimal, icon: String, color: Color, isIncome: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Image(systemName: isIncome ? "plus" : "minus")
                        .font(.caption)
                        .foregroundColor(color.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text(formatCurrency(amount))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: amount)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Mini progress bar
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.3))
                        .frame(height: 3)
                        .overlay(
                            HStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(color)
                                    .frame(width: isIncome ? 60 : 40, height: 3)
                                Spacer()
                            }
                        )
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func quickStatItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(themeManager.textSecondary.opacity(0.8))
        }
    }
    
    private var quickActionsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            // Row 1 - Apple Technologies
            quickActionCard(
                title: "Siri",
                icon: "mic.circle.fill",
                gradient: [Color.blue, Color.blue.opacity(0.7)]
            ) {
                showingSiriShortcutsSheet = true
            }
            
            quickActionCard(
                title: "Widgets",
                icon: "square.grid.3x3",
                gradient: [Color.purple, Color.purple.opacity(0.7)]
            ) {
                showingWidgetConfigSheet = true
            }
            
            quickActionCard(
                title: "Scan Receipt",
                icon: "viewfinder",
                gradient: [Color.orange, Color.orange.opacity(0.7)]
            ) {
                showingReceiptScanSheet = true
            }
            
            quickActionCard(
                title: "Apple Pay",
                icon: "creditcard.circle",
                gradient: [Color.green, Color.green.opacity(0.7)]
            ) {
                showingApplePaySheet = true
            }
            
            // Row 2 - Core Features
            quickActionCard(
                title: "AI Insights",
                icon: "brain.head.profile",
                gradient: [Color.mint, Color.mint.opacity(0.7)]
            ) {
                showingAIInsightsSheet = true
            }
            
            quickActionCard(
                title: "Templates",
                icon: "doc.badge.plus",
                gradient: [Color.pink, Color.pink.opacity(0.7)]
            ) {
                showingTemplatesSheet = true
            }
            
            quickActionCard(
                title: "Search",
                icon: "magnifyingglass",
                gradient: [Color.indigo, Color.indigo.opacity(0.7)]
            ) {
                showingAdvancedSearchSheet = true
            }
            
            quickActionCard(
                title: "Test Alerts",
                icon: "bell.badge",
                gradient: [Color.red, Color.red.opacity(0.7)]
            ) {
                showingTestNotificationsSheet = true
            }
        }
    }
    
    private func quickActionCard(title: String, icon: String, gradient: [Color], action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: gradient[0].opacity(0.3), radius: 6, x: 0, y: 3)
        }
    }
    
    private var goalsPreviewSection: some View {
        let activeGoals = goals.filter { !$0.isCompleted }.prefix(2)
        
        return Group {
            if !activeGoals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Active Goals")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.textPrimary)
                        
                        Spacer()
                        
                        Button("View All") {
                            showingGoalsSheet = true
                        }
                        .font(.subheadline)
                        .foregroundColor(themeManager.primaryColor)
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(Array(activeGoals), id: \.id) { goal in
                            goalPreviewCard(goal: goal)
                        }
                    }
                }
            }
        }
    }
    
    private func goalPreviewCard(goal: Goal) -> some View {
        let progress = calculateGoalProgress(goal: goal)
        
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name ?? "Untitled Goal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("$\((goal.currentAmount as Decimal? ?? 0).description) of $\((goal.targetAmount as Decimal? ?? 0).description)")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.accentColor)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: themeManager.accentColor))
                    .frame(width: 60)
                    .scaleEffect(x: 1, y: 0.5)
            }
        }
        .padding(12)
        .background(themeManager.cardColor)
        .cornerRadius(12)
    }
    
    private var filtersSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.textSecondary)
                
                TextField("Search transactions...", text: $searchText)
                    .onChange(of: searchText) {
                        updatePredicate()
                    }
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                        updatePredicate()
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.primaryColor)
                }
            }
            .padding()
            .background(themeManager.cardColor)
            .cornerRadius(12)
            
            HStack {
                DatePicker("From", selection: $fromDate, displayedComponents: .date)
                    .onChange(of: fromDate) {
                        updatePredicate()
                    }
                
                DatePicker("To", selection: $toDate, displayedComponents: .date)
                    .onChange(of: toDate) {
                        updatePredicate()
                    }
            }
            .font(.subheadline)
            .padding()
            .background(themeManager.cardColor)
            .cornerRadius(12)
            
            HStack {
                Text("Sort by:")
                    .font(.subheadline)
                    .foregroundColor(themeManager.textSecondary)
                
                Spacer()
                
                Picker("Sort", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: sortOption) { 
                    updateSortDescriptors()
                }
            }
            .padding()
            .background(themeManager.cardColor)
            .cornerRadius(12)
            
            Button("Reset All Filters") {
                resetAllFilters()
            }
            .foregroundColor(themeManager.accentColor)
            .font(.subheadline)
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(expensesByCategory) { data in
                        BarMark(
                            x: .value("Category", data.category),
                            y: .value("Amount", (data.total as NSDecimalNumber).doubleValue)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.primaryColor, themeManager.accentColor]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(6)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(themeManager.textSecondary.opacity(0.3))
                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(themeManager.textSecondary.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(themeManager.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(themeManager.textSecondary.opacity(0.3))
                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(themeManager.textSecondary.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(themeManager.textSecondary)
                    }
                }
            } else {
                // Fallback for iOS 15 and below
                VStack(spacing: 8) {
                    ForEach(expensesByCategory.prefix(5), id: \.category) { data in
                        HStack {
                            Text(data.category)
                                .font(.caption)
                                .frame(width: 80, alignment: .leading)
                            
                            GeometryReader { geometry in
                                HStack {
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [themeManager.primaryColor, themeManager.accentColor]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .frame(width: CGFloat((data.total as NSDecimalNumber).doubleValue / maxExpense) * geometry.size.width)
                                        .cornerRadius(4)
                                    
                                    Spacer()
                                }
                            }
                            .frame(height: 8)
                            
                            Text(formatCurrency(data.total))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var maxExpense: Double {
        (expensesByCategory.first?.total as NSDecimalNumber?)?.doubleValue ?? 1.0
    }
    
    private var transactionListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Spacer()
                
                Text("\(transactions.count) total")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            if transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text("No transactions yet")
                        .font(.headline)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text("Start by adding your first transaction")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Add Transaction") {
                        selectedTransactionType = .expense
                        showingAddSheet = true
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(themeManager.primaryColor)
                    .cornerRadius(20)
                }
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(transactions.prefix(8)), id: \.id) { transaction in
                        enhancedTransactionRow(for: transaction)
                    }
                }
                
                if transactions.count > 8 {
                    Button("View All Transactions") {
                        showingAdvancedSearchSheet = true
                    }
                    .font(.subheadline)
                    .foregroundColor(themeManager.primaryColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(themeManager.cardColor)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.primaryColor, lineWidth: 1)
                    )
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func enhancedTransactionRow(for transaction: Transaction) -> some View {
        HStack(spacing: 16) {
            FinanceCategoryIcon(category: transaction.category ?? "Other", size: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category ?? "Uncategorized")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textPrimary)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .lineLimit(1)
                }
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Text(transaction.isExpense
                 ? "-\(currencyFormatter.string(from: transaction.amount ?? 0) ?? "$0.00")"
                 : "+\(currencyFormatter.string(from: transaction.amount ?? 0) ?? "$0.00")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.isExpense ? themeManager.errorColor : themeManager.successColor)
        }
        .padding(16)
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.textSecondary.opacity(0.1), lineWidth: 1)
        )
        .onTapGesture {
            selectedTransactionForEdit = transaction
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                selectedTransaction = transaction
            } label: {
                Image(systemName: "camera")
            }
            .tint(themeManager.accentColor)
            
            Button {
                duplicateTransaction(transaction)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .tint(themeManager.primaryColor)
            
            Button {
                deleteTransaction(transaction)
            } label: {
                Image(systemName: "trash")
            }
            .tint(themeManager.errorColor)
        }
    }
    
    // Debug section for testing
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debug Info")
                .font(.headline)
                .foregroundColor(themeManager.errorColor)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("🐛 Transaction count: \(transactions.count)")
                Text("🔔 Notifications authorized: \(notificationManager.isAuthorized ? "✅" : "❌")")
                Text("💰 Net balance: \(formatCurrency(netBalance))")
                
                HStack(spacing: 12) {
                    Button("Test Budget Alert") {
                        notificationManager.triggerTestBudgetAlert()
                    }
                    .padding(8)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Test Goal Alert") {
                        notificationManager.triggerTestGoalReminder()
                    }
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.errorColor, lineWidth: 1)
        )
        .onTapGesture(count: 5) {
            showingDebugInfo.toggle()
        }
    }
    
    // MARK: - Helper Functions
    
    private func duplicateTransaction(_ transaction: Transaction) {
        let newTransaction = Transaction(context: viewContext)
        newTransaction.id = UUID()
        newTransaction.amount = transaction.amount
        newTransaction.category = transaction.category
        newTransaction.note = transaction.note
        newTransaction.isExpense = transaction.isExpense
        newTransaction.date = Date()
        
        saveContext()
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        viewContext.delete(transaction)
        saveContext()
    }
    
    private func calculateGoalProgress(goal: Goal) -> Double {
        let current = goal.currentAmount?.doubleValue ?? 0
        let target = goal.targetAmount?.doubleValue ?? 1
        return min(current / target, 1.0)
    }
    
    // Helper functions for enhanced balance UI
    private func formatLargeNumber(_ decimal: Decimal) -> String {
        let number = decimal as NSDecimalNumber
        let value = number.doubleValue
        
        let formatter = NumberFormatter()
        
        if abs(value) >= 1000000 {
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: value / 1000000)) ?? "0" + "M"
        } else if abs(value) >= 1000 {
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: value / 1000)) ?? "0" + "K"
        } else {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: number) ?? "0"
        }
    }
    
    private func formatCurrency(_ decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: decimal as NSDecimalNumber) ?? "$0"
    }
    
    // MARK: - Formatters and Computed Properties
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func updateSortDescriptors() {
        switch sortOption {
        case .date:
            transactions.nsSortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        case .amount:
            transactions.nsSortDescriptors = [NSSortDescriptor(keyPath: \Transaction.amount, ascending: false)]
        case .category:
            transactions.nsSortDescriptors = [NSSortDescriptor(keyPath: \Transaction.category, ascending: true)]
        }
    }
    
    private func resetAllFilters() {
        searchText = ""
        fromDate = Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date()
        toDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        updatePredicate()
    }
    
    private func updatePredicate() {
        var predicates: [NSPredicate] = []
        
        let datePredicate = NSPredicate(format: "date >= %@ AND date <= %@", fromDate as NSDate, toDate as NSDate)
        predicates.append(datePredicate)
        
        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "(category CONTAINS[c] %@) OR (note CONTAINS[c] %@)", searchText, searchText)
            predicates.append(searchPredicate)
        }
        
        transactions.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    // MARK: - Category Breakdown
    
    private var expensesByCategory: [CategoryData] {
        let expenseTxns = transactions.filter { $0.isExpense }
        var dict: [String: Decimal] = [:]
        for txn in expenseTxns {
            let cat = txn.category ?? "Other"
            dict[cat, default: 0] += (txn.amount as Decimal? ?? 0)
        }
        return dict.map { CategoryData(category: $0.key, total: $0.value) }
                   .sorted { $0.total > $1.total }
    }
    
    struct CategoryData: Identifiable {
        let id = UUID()
        let category: String
        let total: Decimal
    }
    
    // MARK: - Summary Computations
    
    private var totalExpenses: Decimal {
        transactions
            .filter { $0.isExpense }
            .reduce(0) { $0 + ($1.amount as Decimal? ?? 0) }
    }
    
    private var totalIncome: Decimal {
        transactions
            .filter { !$0.isExpense }
            .reduce(0) { $0 + ($1.amount as Decimal? ?? 0) }
    }
    
    private var netBalance: Decimal {
        totalIncome - totalExpenses
    }
    
    private var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        let incomeDouble = (totalIncome as NSDecimalNumber).doubleValue
        let expenseDouble = (totalExpenses as NSDecimalNumber).doubleValue
        return ((incomeDouble - expenseDouble) / incomeDouble) * 100
    }
    
    // MARK: - CRUD Helpers
    
    private func saveContext() {
        do {
            try viewContext.save()
            
            // Trigger notification checks after data changes
            Task {
                await notificationManager.performAllChecks()
            }
            
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Supporting Views

struct FinanceCategoryIcon: View {
    let category: String
    let size: CGFloat
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size))
            .foregroundColor(iconColor)
            .frame(width: size + 10, height: size + 10)
            .background(iconColor.opacity(0.1))
            .cornerRadius((size + 10) / 2)
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

struct ComingSoonView: View {
    let featureName: String
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 64))
                    .foregroundColor(themeManager.accentColor)
                
                Text("\(featureName)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Coming Soon")
                    .font(.title2)
                    .foregroundColor(themeManager.textSecondary)
                
                Text("This feature is under development and will be available in a future update.")
                    .font(.body)
                    .foregroundColor(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button("Got it") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(themeManager.primaryColor)
                .cornerRadius(25)
            }
            .background(themeManager.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        ContentView()
            .environment(\.managedObjectContext, context)
            .environmentObject(ThemeManager())
    }
}

