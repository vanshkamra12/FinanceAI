
import SwiftUI
import CoreData

struct AIInsightsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var transactions: FetchedResults<Transaction>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        spendingPatternsSection
                        recommendationsSection
                        trendsSection
                        goalsInsightsSection
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
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            VStack {
                Text("AI Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Personalized financial analysis")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(themeManager.accentColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var spendingPatternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Patterns")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                insightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Peak Spending Days",
                    description: "You tend to spend 40% more on Fridays and weekends. Consider planning purchases for weekdays.",
                    color: themeManager.warningColor,
                    action: "Set Weekend Budget Limit"
                )
                
                insightCard(
                    icon: "clock.fill",
                    title: "Impulse Purchases",
                    description: "67% of your transactions over $50 happen between 6-8 PM. Try the 24-hour rule for big purchases.",
                    color: themeManager.errorColor,
                    action: "Enable Purchase Delays"
                )
                
                insightCard(
                    icon: "calendar.badge.plus",
                    title: "Monthly Trends",
                    description: "Your spending typically increases by 25% in the last week of each month. Plan accordingly.",
                    color: themeManager.primaryColor,
                    action: "Set End-of-Month Alert"
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Smart Recommendations")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                recommendationCard(
                    icon: "leaf.fill",
                    title: "Optimize Subscriptions",
                    description: "You have $47/month in unused subscriptions. Cancel 3 services to save $564 annually.",
                    savingsAmount: "$564",
                    color: themeManager.successColor
                )
                
                recommendationCard(
                    icon: "car.fill",
                    title: "Transportation Savings",
                    description: "Switch to public transport 2 days/week to save on gas and parking.",
                    savingsAmount: "$89",
                    color: themeManager.accentColor
                )
                
                recommendationCard(
                    icon: "house.fill",
                    title: "Emergency Fund Goal",
                    description: "Based on your expenses, aim for $4,500 emergency fund (3 months of expenses).",
                    savingsAmount: "$4,500",
                    color: themeManager.primaryColor
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trend Analysis")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                trendCard(
                    title: "Food & Dining",
                    change: "+15%",
                    isIncrease: true,
                    description: "Increased from last month. Try meal planning to reduce costs.",
                    color: themeManager.warningColor
                )
                
                trendCard(
                    title: "Transportation",
                    change: "-8%",
                    isIncrease: false,
                    description: "Great job reducing transport costs! Keep it up.",
                    color: themeManager.successColor
                )
                
                trendCard(
                    title: "Entertainment",
                    change: "+22%",
                    isIncrease: true,
                    description: "Higher than usual. Consider free activities this month.",
                    color: themeManager.errorColor
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var goalsInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Insights")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                goalInsightCard(
                    goalName: "Vacation Fund",
                    currentAmount: 2400,
                    targetAmount: 5000,
                    daysLeft: 90,
                    recommendedSaving: 29
                )
                
                goalInsightCard(
                    goalName: "Emergency Fund",
                    currentAmount: 1800,
                    targetAmount: 4500,
                    daysLeft: 180,
                    recommendedSaving: 15
                )
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private func insightCard(icon: String, title: String, description: String, color: Color, action: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
            }
            
            Button(action) {
                // Action implementation
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .cornerRadius(16)
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
    
    private func recommendationCard(icon: String, title: String, description: String, savingsAmount: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Save")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                
                Text(savingsAmount)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
    
    private func trendCard(title: String, change: String, isIncrease: Bool, description: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: isIncrease ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(change)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
    
    private func goalInsightCard(goalName: String, currentAmount: Int, targetAmount: Int, daysLeft: Int, recommendedSaving: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goalName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Spacer()
                
                Text("\(daysLeft) days left")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            let progress = Double(currentAmount) / Double(targetAmount)
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.accentColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            HStack {
                Text("$\(currentAmount) of $\(targetAmount)")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                
                Spacer()
                
                Text("Save $\(recommendedSaving)/day")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.accentColor)
            }
        }
        .padding()
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
}

struct AIInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        AIInsightsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
    }
}
