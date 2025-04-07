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
struct QuoteStatusMenu: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var quote: QuoteEntity

    var body: some View {
        Menu {
            ForEach(QuoteStatus.allCases, id: \.self) { status in
                Button {
                    quote.statusEnum = status
                    try? viewContext.save()
                } label: {
                    Label(status.rawValue, systemImage: icon(for: status))
                }
            }
        } label: {
            Label {
                Text(quote.statusEnum.rawValue)
            } icon: {
                Image(systemName: icon(for: quote.statusEnum))
            }
            .font(.caption)
            .padding(6)
            .background(quote.statusColor.opacity(0.2))
            .foregroundColor(quote.statusColor)
            .cornerRadius(6)
        }
    }

    func icon(for status: QuoteStatus) -> String {
        switch status {
        case .brouillon: return "pencil"
        case .finalisé:  return "checkmark.circle"
        case .accepté:   return "checkmark.seal"
        case .abandonné: return "xmark.circle"
        }
    }
}
