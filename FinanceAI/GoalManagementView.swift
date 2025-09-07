import SwiftUI
import CoreData

struct GoalManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.createdDate, ascending: false)]
    ) private var goals: FetchedResults<Goal>
    
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                if goals.isEmpty {
                    emptyStateView
                } else {
                    goalsListView
                }
                
                Spacer()
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(themeManager)
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Financial Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.primaryColor)
                
                Text("Track your saving progress")
                    .font(.subheadline)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(themeManager.textSecondary)
            
            VStack(spacing: 8) {
                Text("No Goals Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Set your first financial goal to start tracking your progress")
                    .font(.body)
                    .foregroundColor(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingAddGoal = true
            } label: {
                Text("Create Your First Goal")
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
    
    private var goalsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(goals, id: \.id) { goal in
                    goalCard(for: goal)
                }
                
                addGoalButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func goalCard(for goal: Goal) -> some View {
        let progress = calculateProgress(for: goal)
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name ?? "Untitled Goal")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    if let category = goal.category {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    }
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.successColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("$\((goal.currentAmount as Decimal? ?? 0).description)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryColor)
                    
                    Text("of $\((goal.targetAmount as Decimal? ?? 0).description)")
                        .font(.body)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.accentColor)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: themeManager.accentColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            if let targetDate = goal.targetDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(themeManager.textSecondary)
                    Text("Target: \(formatDate(targetDate))")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Spacer()
                    
                    Text(daysRemaining(to: targetDate))
                        .font(.caption)
                        .foregroundColor(themeManager.warningColor)
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var addGoalButton: some View {
        Button {
            showingAddGoal = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add New Goal")
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
    
    // MARK: - Helper Functions
    
    private func calculateProgress(for goal: Goal) -> Double {
        let current = goal.currentAmount?.doubleValue ?? 0
        let target = goal.targetAmount?.doubleValue ?? 1
        return min(current / target, 1.0)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func daysRemaining(to date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        let days = components.day ?? 0
        
        if days < 0 {
            return "Overdue"
        } else if days == 0 {
            return "Due today"
        } else {
            return "\(days) days left"
        }
    }
}

struct GoalManagementView_Previews: PreviewProvider {
    static var previews: some View {
        GoalManagementView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}

