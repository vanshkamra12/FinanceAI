import SwiftUI

struct CategoryIcon: View {
    let category: String
    let size: CGFloat
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size, weight: .medium))
            .foregroundColor(iconColor)
            .frame(width: size + 8, height: size + 8)
            .background(iconColor.opacity(0.2))
            .clipShape(Circle())
    }
    
    private var iconName: String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "salary": return "dollarsign.circle.fill"
        case "entertainment": return "tv.fill"
        case "health": return "cross.fill"
        case "education": return "book.fill"
        case "utilities": return "bolt.fill"
        case "rent": return "house.fill"
        case "investment": return "chart.line.uptrend.xyaxis"
        default: return "questionmark.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch category.lowercased() {
        case "food": return .orange
        case "transport": return .blue
        case "shopping": return .purple
        case "salary": return .green
        case "entertainment": return .pink
        case "health": return .red
        case "education": return .indigo
        case "utilities": return .yellow
        case "rent": return .brown
        case "investment": return .mint
        default: return .gray
        }
    }
}

