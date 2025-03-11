import SwiftUI

/// Types de lignes possibles
enum QuoteLineType: String, Codable {
    case article
    case category
    case pageBreak
}

/// Représente une ligne dans le devis
struct QuoteArticle: Identifiable, Equatable {
    let id: UUID

    /// Pour un article classique (optionnel, car une catégorie ou un saut de page n'ont pas d'article)
    var article: Article?

    /// Quantité (pertinent seulement si c'est un article)
    var quantity: Int16

    /// Prix unitaire (on peut choisir de le stocker ici, ou se baser sur article?.price)
    var unitPrice: Double

    /// Type de ligne
    var lineType: QuoteLineType

    /// Commentaire (pertinent pour une catégorie, ou autre usage)
    var comment: String?

    init(
        id: UUID = UUID(),
        article: Article? = nil,
        quantity: Int16 = 1,
        unitPrice: Double = 0.0,
        lineType: QuoteLineType = .article,
        comment: String? = nil
    ) {
        self.id = id
        self.article = article
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.lineType = lineType
        self.comment = comment
    }

    // Pour comparer deux QuoteArticle (nécessaire si on veut qu'ils soient Equatable)
    static func == (lhs: QuoteArticle, rhs: QuoteArticle) -> Bool {
        lhs.id == rhs.id
        && lhs.quantity == rhs.quantity
        && lhs.unitPrice == rhs.unitPrice
        && lhs.lineType == rhs.lineType
        && lhs.comment == rhs.comment
        // Comparez aussi l'article si nécessaire (ex: en comparant l'objectID si c'est CoreData)
    }
}
