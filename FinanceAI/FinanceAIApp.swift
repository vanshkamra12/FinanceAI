import SwiftUI

@main
struct FinanceAIApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(themeManager)
        }
    }
}

