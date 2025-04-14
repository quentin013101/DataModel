import SwiftUI

@main
struct DataModelApp: App {
    init() {
        ValueTransformer.setValueTransformer(UUIDArrayTransformer(), forName: .uuidArrayTransformerName)
    }
    let persistenceController = PersistenceController.shared
    @State private var selectedTab: String = "devisFactures" // 🔥 Variable pour la sélection

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab) // 🔥 Passe selectedTab à ContentView
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
