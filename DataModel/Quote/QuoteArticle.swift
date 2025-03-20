import SwiftUI

/// Types de lignes possibles
enum QuoteLineType: String, Codable {
    case article
    case category
    case pageBreak
    case remise  // Ajout du cas remise

}

/// Représente une ligne dans le devis
struct QuoteArticle: Identifiable, Equatable {
    let id: UUID

    /// Pour un article classique (optionnel, car une catégorie ou un saut de page n'ont pas d'article)
    var article: Article?

    /// Quantité (pertinent seulement si c'est un article)
    var quantity: Int16
    var unit: String?

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
        comment: String? = nil,
        unit: String? = nil
    ) {
        self.id = id
        self.article = article
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.lineType = lineType
        self.comment = comment
        if let art = article {
            self.unit = art.unit   // ex: "m²"
        } else {
            self.unit = nil
        }
    }

    // Pour comparer deux QuoteArticle (nécessaire si on veut qu'ils soient Equatable)
    static func == (lhs: QuoteArticle, rhs: QuoteArticle) -> Bool {
        lhs.id == rhs.id
        && lhs.quantity == rhs.quantity
        && lhs.unitPrice == rhs.unitPrice
        && lhs.lineType == rhs.lineType
        && lhs.comment == rhs.comment
        && lhs.unit == rhs.unit
        // Comparez aussi l'article si nécessaire (ex: en comparant l'objectID si c'est CoreData)
    }
}

extension QuoteArticle {
    /// Propriété calculée pour obtenir le total d'une ligne.
    /// Pour un article : quantité * prix unitaire.
    /// Pour une remise : on retourne le prix unitaire (qui doit être négatif).
    var total: Double {
        switch lineType {
        case .article:
            return Double(quantity) * unitPrice
        case .remise:
            return unitPrice  // On suppose que unitPrice est déjà négatif
        default:
            return 0.0
        }
    }
    
    /// Initialiseur spécialisé pour une ligne de remise.
    /// Le montant fourni (discountAmount) est converti en valeur négative.
    init(discountAmount: Double) {
        // On appelle l'initialiseur de base avec le type .remise et un commentaire
        self.init(lineType: .remise, comment: "Remise")
        // Force la valeur à être négative, quelle que soit la valeur entrée
        self.unitPrice = -abs(discountAmount)
        self.quantity = 1
    }
}
