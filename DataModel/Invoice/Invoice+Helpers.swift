//
//  Invoice+Helpers.swift
//  DataModel
//
//  Created by Quentin FABERES on 04/04/2025.
//

import SwiftUI
import Foundation

enum InvoiceStatus: String, CaseIterable {
    case brouillon = "Brouillon"
    case envoyee = "Envoyée"
    case payee = "Payée"
    
    var icon: String {
        switch self {
        case .brouillon: return "pencil"
        case .envoyee: return "envelope"
        case .payee: return "checkmark.seal"
        }
    }
    
    var color: Color {
        switch self {
        case .brouillon: return .gray
        case .envoyee: return .blue
        case .payee: return .green
        }
    }
}
extension Invoice {
    var statusEnum: QuoteStatus {
        QuoteStatus(rawValue: status ?? "") ?? .brouillon
    }

    var statusColor: Color? {
        switch statusEnum {
        case .brouillon: return .gray
        case .finalisé: return .blue
        case .accepté: return .green
        case .abandonné: return .red
        }
    }
    var invoiceTypeEnum: InvoiceType {
        get { InvoiceType(rawValue: invoiceType ?? "") ?? .finale } // finale par défaut si nil
        set { invoiceType = newValue.rawValue }
    }

    var isFinalInvoice: Bool {
        invoiceTypeEnum == .finale
    }
    var montantRéelTTC: Double {
        if invoiceTypeEnum == .finale {
            return totalTTC
        } else {
            return partialAmount + tva
        }
    }
    var companyIsAutoEntrepreneur: Bool {
        let legalForm = CompanyInfo.loadFromUserDefaults().legalForm
        return legalForm.lowercased().contains("auto")
    }
//    var decodedQuoteArticles: [QuoteArticle] {
//        guard let data = invoiceArticlesData else { return [] }
//        let decoder = JSONDecoder()
//        return (try? decoder.decode([QuoteArticle].self, from: data)) ?? []
//    }
}
extension Double {
    func formattedCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self) €"
    }
}
func defaultInfoText(for invoice: Invoice) -> String {
    let quoteNumber = invoice.referenceQuoteNumber ?? "—"

    let quoteDate: String
    if let date = invoice.referenceQuoteDate {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        quoteDate = formatter.string(from: date)
    } else {
        quoteDate = "—"
    }

    let total = invoice.referenceQuoteTotal.formattedCurrency()
    let percent = Int(invoice.partialPercentage)

    if invoice.invoiceNote?.contains("intermédiaire") == true {
        return "Facture intermédiaire pour le devis \(quoteNumber) du \(quoteDate), correspondant à \(percent) % du montant total de \(total) net"
    } else {
        return "Acompte pour le devis \(quoteNumber) du \(quoteDate), correspondant à \(percent) % du montant total de \(total) net"
    }
}

func generateNewInvoiceNumber() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
    let prefix = formatter.string(from: Date())

    let fetchRequest: NSFetchRequest<Invoice> = Invoice.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "invoiceNumber BEGINSWITH %@", "FAC-\(prefix)")

    do {
        let results = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        let nextIndex = (results.count + 1)
        return String(format: "FAC-%@-%03d", prefix, nextIndex)
    } catch {
        print("❌ Erreur lors de la génération du numéro : \(error)")
        return "FAC-\(prefix)-001"
    }
}

