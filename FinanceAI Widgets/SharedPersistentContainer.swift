import CoreData

class SharedPersistentContainer {
    static let shared = SharedPersistentContainer()
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "FinanceAI")
        let storeURL = FileManager
            .default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.vanshkamra.financeai.FinanceAI")!
            .appendingPathComponent("FinanceAI.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}

