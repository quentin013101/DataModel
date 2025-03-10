import SwiftUI

struct QuoteArticle: Identifiable, Equatable {
    let id: UUID
    var article: Article
    var quantity: Int16
    var unitPrice: Double

    static func == (lhs: QuoteArticle, rhs: QuoteArticle) -> Bool {
        lhs.id == rhs.id &&
        lhs.quantity == rhs.quantity &&
        lhs.unitPrice == rhs.unitPrice
    }
}
