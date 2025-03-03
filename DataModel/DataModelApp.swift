import SwiftUI

@main
struct DataModelApp: App {
    let persistenceController = PersistenceController.shared
    @State private var selectedTab: String = "clients" // 🔥 Variable pour la sélection

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab) // 🔥 Passe selectedTab à ContentView
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
