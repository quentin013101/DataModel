import SwiftUI
import CoreData

struct QuoteListView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var selectedTab: String
    @Binding var quoteToEdit: QuoteEntity?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \QuoteEntity.date, ascending: false)]
    ) var allQuotes: FetchedResults<QuoteEntity>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                ForEach(allQuotes, id: \.self) { quote in
                    Button {
                        quoteToEdit = quote
                        selectedTab = "devis"
                    } label: {
                        rowView(for: quote)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func updateStatus(for quote: QuoteEntity, to status: QuoteStatus) {
        quote.statusEnum = status
        try? context.save()
    }

    private func confirmDelete(quote: QuoteEntity) {
        let alert = NSAlert()
        alert.messageText = "Supprimer ce devis ?"
        alert.informativeText = "Cette action est irréversible."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Supprimer")
        alert.addButton(withTitle: "Annuler")

        if alert.runModal() == .alertFirstButtonReturn {
            context.delete(quote)
            try? context.save()
        }
    }
    @ViewBuilder
    private func rowView(for quote: QuoteEntity) -> some View {
        HStack(alignment: .center, spacing: 16) {
            // 📄 Icône devis ou facture (adaptable plus tard)
            Image(systemName: "doc.text.fill")
                .foregroundColor(.blue)

            // 🏗️ Nom du projet (en gras)
            Text(quote.projectName ?? "Sans nom")
                .font(.headline)
                .frame(minWidth: 150, alignment: .leading)

            // 👤 Nom du client
            Text(quote.clientName ?? "Client inconnu")
                .font(.subheadline)
                .frame(minWidth: 130, alignment: .leading)

            // 📍 Adresse (une ligne)
            Text(quote.clientAddress ?? "Adresse inconnue")
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(minWidth: 180, alignment: .leading)

            Spacer()

            // 💶 Montant + 📅 Date + ✅ Statut
            HStack(spacing: 16) {
                // 💶 Montant
                Text("\(quote.sousTotal, specifier: "%.2f") €")
                    .bold()
                    .frame(width: 80, alignment: .trailing)

                // 📅 Date
                Text(quote.date?.formatFr() ?? "-")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 90, alignment: .trailing)

                // ✅ Statut (menu déroulant)
                Menu {
                    ForEach(QuoteStatus.allCases, id: \.self) { status in
                        Button {
                            updateStatus(for: quote, to: status)
                        } label: {
                            Label(status.label, systemImage: status.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: quote.statusEnum.icon)
                        Text(quote.statusEnum.label)
                    }

                    .font(.caption)
                    //.foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    // .background(quote.statusEnum.color)
                    .background(Capsule().fill(Color.red)) // 🧪 test avec Capsule + fill

                    .cornerRadius(6)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuStyle(.borderlessButton)
                //.menuIndicator(.hidden)

                // 🗑️ Corbeille
                Button {
                    confirmDelete(quote: quote)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .frame(minWidth: 300)
        }
        .padding(.vertical, 8)
    }
}

extension Date {
    func formatFr() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: self)
    }
}
