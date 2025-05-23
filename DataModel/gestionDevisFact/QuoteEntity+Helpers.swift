import SwiftUI
enum InvoiceType: String {
    case acompte
    case intermediaire
    case finale
}
extension QuoteEntity {
    var statusEnum: QuoteStatus {
        get { QuoteStatus(rawValue: status ?? "") ?? .brouillon }
        set { status = newValue.rawValue }
    }

    var statusColor: Color {
        switch statusEnum {
        case .brouillon:
            return .gray
        case .finalisé:
            return .blue
        case .accepté:
            return .green
        case .abandonné:
            return .red
        }
    }

    var clientAddress: String {
        [
            clientStreet ?? "",
            "\(clientPostalCode ?? "") \(clientCity ?? "")"
        ]
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }

    var typeIconName: String {
        // Pour l’instant, on gère que les devis
        return "doc.text.fill"
    }

    var totalFormatted: String {
        (sousTotal - remiseAmount).formattedCurrency()
    }
    var total: Double {
        return sousTotal - remiseAmount
    }

    var invoicesArray: [Invoice] {
        guard let rawSet = invoices as? Set<Invoice> else {
            print("⚠️ invoices is not a Set<Invoice>")
            return []
        }
        return rawSet.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
    }

    func invoicesTotal() -> Double {
        invoicesArray.reduce(0) { $0 + $1.totalTTC }
    }
    
}

//extension Double {
//    func formattedCurrency() -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = "EUR"
//        formatter.maximumFractionDigits = 2
//        return formatter.string(from: NSNumber(value: self)) ?? "€0.00"
//    }
//}
func formattedCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "EUR"
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
}
