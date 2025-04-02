import SwiftUI

enum QuoteStatus: String, CaseIterable, Codable {
    case brouillon
    case finalisé
    case accepté
    case abandonné

    var label: String {
        switch self {
        case .brouillon: return "Brouillon"
        case .finalisé: return "Finalisé"
        case .accepté:  return "Accepté"
        case .abandonné: return "Abandonné"
        }
    }

    var icon: String {
        switch self {
        case .brouillon: return "pencil"
        case .finalisé: return "checkmark.seal"
        case .accepté:  return "hand.thumbsup"
        case .abandonné: return "xmark.seal"
        }
    }

    var color: Color {
        switch self {
        case .brouillon: return .gray
        case .finalisé: return .blue
        case .accepté:  return .green
        case .abandonné: return .red
        }
    }
}
