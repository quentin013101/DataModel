import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel") // Assure-toi que ce nom correspond bien au fichier .xcdatamodeld
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Erreur Core Data: \(error), \(error.userInfo)")
            }
        }
    }

    // ✅ Ajout de `preview` pour éviter l'erreur
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // ✅ Ajouter ici des exemples de contacts pour le mode Preview (facultatif)
        let exampleContact = Contact(context: viewContext)
        exampleContact.firstName = "Jean"
        exampleContact.lastName = "Dupont"
        exampleContact.email = "jean.dupont@example.com"
        exampleContact.phoneNumber = "06 12 34 56 78"

        do {
            try viewContext.save()
        } catch {
            print("❌ Erreur lors de la sauvegarde de l’aperçu : \(error.localizedDescription)")
        }

        return controller
    }()
}
