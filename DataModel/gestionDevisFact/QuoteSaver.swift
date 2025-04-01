import CoreData
import Foundation

func saveQuoteToCoreData(
    context: NSManagedObjectContext,
    quoteArticles: [QuoteArticle],
    clientName: String,
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
    newQuote.clientName = clientName
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
        dismiss() // 👈 ferme la vue après enregistrement
    } catch {
        print("❌ Erreur lors de la sauvegarde : \(error)")
    }
}
