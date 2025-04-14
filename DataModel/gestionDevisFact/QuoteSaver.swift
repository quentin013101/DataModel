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
    let fetchRequest: NSFetchRequest<QuoteEntity> = QuoteEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "devisNumber == %@", devisNumber)

    do {
        let results = try context.fetch(fetchRequest)
        let quote: QuoteEntity
        let isNewQuote: Bool

        if let existing = results.first {
            quote = existing
            isNewQuote = false
        } else {
            quote = QuoteEntity(context: context)
            quote.id = UUID()
            quote.date = Date() // ✅ seulement à la création
            isNewQuote = true
        }

        quote.clientCivility = clientCivility
        quote.clientFirstName = clientFirstName
        quote.clientLastName = clientLastName
        quote.projectName = projectName
        quote.quoteArticlesData = try? JSONEncoder().encode(quoteArticles)
        quote.sousTotal = sousTotal
        quote.remiseAmount = remiseAmount
        quote.remiseIsPercentage = remiseIsPercentage
        quote.remiseValue = remiseValue
        quote.devisNumber = devisNumber

        try context.save()
        print("✅ Devis \(isNewQuote ? "créé" : "modifié")")
    } catch {
        print("❌ Erreur lors de la sauvegarde : \(error)")
    }
}
