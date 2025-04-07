//
//  InvoiceViewModel.swift
//  DataModel
//
//  Created by Quentin FABERES on 05/04/2025.
//


import Foundation
import SwiftUI

class InvoiceViewModel: ObservableObject {
    @Published var invoice: Invoice
    @Published var articles: [QuoteArticle]
    @Published var note: String
    @Published var date: Date
    @Published var totalPreviouslyInvoiced: Double = 0.0
    

    init(invoice: Invoice) {
        self.invoice = invoice
        self.articles = invoice.decodedQuoteArticles
        self.note = invoice.invoiceNote ?? ""
        self.date = invoice.date ?? Date()
    }

    var totalHT: Double {
        articles.map { $0.totalHT }.reduce(0, +)
    }
    var tva: Double {
        totalHT * 0.2
    }
    var totalTTC: Double {
        totalHT + tva
    }

    func saveArticlesToInvoice() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(articles) {
            invoice.invoiceArticlesData = data
        }
        invoice.invoiceNote = note
        invoice.date = date
        invoice.totalHT = totalHT
        invoice.tva = tva
        invoice.totalTTC = totalTTC
    }
}
import Foundation

extension Invoice {
    var decodedQuoteArticles: [QuoteArticle] {
        guard let data = invoiceArticlesData else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([QuoteArticle].self, from: data)) ?? []
    }
}
