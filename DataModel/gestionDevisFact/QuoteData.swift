//
//  QuoteData.swift
//  DataModel
//
//  Created by Quentin FABERES on 01/04/2025.
//


import Foundation
import CoreData

struct QuoteData: Identifiable {
    var id: UUID
    var date: Date
    var clientName: String
    var projectName: String
    var quoteArticles: [QuoteArticle]
    var sousTotal: Double
    var remiseAmount: Double
    var remiseIsPercentage: Bool
    var remiseValue: Double
    var devisNumber: String
}

extension QuoteEntity {
    func toQuoteData() -> QuoteData? {
        guard let id = id,
              let clientName = clientName,
              let projectName = projectName,
              let quoteArticlesData = quoteArticlesData,
              let devisNumber = devisNumber else { return nil }

        guard let articles = try? JSONDecoder().decode([QuoteArticle].self, from: quoteArticlesData) else { return nil }

        return QuoteData(
            id: id,
            date: date ?? Date(),
            clientName: clientName,
            projectName: projectName,
            quoteArticles: articles,
            sousTotal: sousTotal,
            remiseAmount: remiseAmount,
            remiseIsPercentage: remiseIsPercentage,
            remiseValue: remiseValue,
            devisNumber: devisNumber
        )
    }
}
//extension QuoteEntity {
//    var statusEnum: QuoteStatus {
//        get {
//            QuoteStatus(rawValue: status ?? "") ?? .draft
//        }
//        set {
//            status = newValue.rawValue
//        }
//    }
//}
