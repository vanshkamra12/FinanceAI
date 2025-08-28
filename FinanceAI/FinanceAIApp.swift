//
//  FinanceAIApp.swift
//  FinanceAI
//
//  Created by Vansh Kamra on 28/08/25.
//

import SwiftUI

@main
struct FinanceAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
