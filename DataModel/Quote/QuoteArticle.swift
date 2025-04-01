import Foundation
import SwiftUI

enum QuoteArticleType: String, Codable {
    case article
    case category
    case pageBreak
}

/// Représente une ligne dans le devis (article, catégorie ou saut de page)
final class QuoteArticle: ObservableObject, Identifiable, Codable, Equatable {
    
    // MARK: - Propriétés principales modifiables
    var designation: String
    var quantity: Int
    var unit: String
    var unitPrice: Double
    var lineType: QuoteArticleType
    var comment: String?
    
    // MARK: - Identifiant unique
    let id: UUID

    // MARK: - Init
    init(
        id: UUID = UUID(),
        designation: String = "",
        quantity: Int = 1,
        unit: String = "u",
        unitPrice: Double = 0.0,
        lineType: QuoteArticleType = .article,
        comment: String? = nil
    ) {
        self.id = id
        self.designation = designation
        self.quantity = quantity
        self.unit = unit
        self.unitPrice = unitPrice
        self.lineType = lineType
        self.comment = comment
    }

    // MARK: - Equatable
    static func == (lhs: QuoteArticle, rhs: QuoteArticle) -> Bool {
        return lhs.id == rhs.id &&
               lhs.designation == rhs.designation &&
               lhs.quantity == rhs.quantity &&
               lhs.unit == rhs.unit &&
               lhs.unitPrice == rhs.unitPrice &&
               lhs.lineType == rhs.lineType &&
               lhs.comment == rhs.comment
    }
}
