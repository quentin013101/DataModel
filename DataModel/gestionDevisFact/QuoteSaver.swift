import CoreData
import Foundation

func saveQuoteToCoreData(
    context: NSManagedObjectContext,
    quoteArticles: [QuoteArticle],
    clientCivility: String,
    clientFirstName: String,
    clientLastName: String,
    projectName: String,
    sousTotal: Double,
    remiseAmount: Double,
    remiseIsPercentage: Bool,
    remiseValue: Double,
    devisNumber: String
) {
    let newQuote = QuoteEntity(context: context)
    newQuote.id = UUID()
    newQuote.date = Date()
    newQuote.clientCivility = clientCivility
    newQuote.clientFirstName = clientFirstName
    newQuote.clientLastName = clientLastName
    newQuote.projectName = projectName
    newQuote.quoteArticlesData = try? JSONEncoder().encode(quoteArticles)
    newQuote.sousTotal = sousTotal
    newQuote.remiseAmount = remiseAmount
    newQuote.remiseIsPercentage = remiseIsPercentage
    newQuote.remiseValue = remiseValue
    newQuote.devisNumber = devisNumber

    do {
        try context.save()
        print("✅ Devis sauvegardé dans Core Data")
        // Le dismiss() ne peut pas être utilisé ici : il doit être appelé dans une View
    } catch {
        print("❌ Erreur lors de la sauvegarde : \(error)")
    }
}
