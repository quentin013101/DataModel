import SwiftUI

@main
struct DataModelApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContactListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
