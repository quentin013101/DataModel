import SwiftUI

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
}
