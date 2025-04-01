import SwiftUI
import CoreData

struct QuoteListView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var selectedTab: String
    @Binding var quoteToEdit: QuoteEntity?


    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \QuoteEntity.date, ascending: false)]
    ) var allQuotes: FetchedResults<QuoteEntity>

    @State private var selectedQuoteToEdit: QuoteEntity? = nil

    var body: some View {
        VStack {
            List(allQuotes, id: \.self) { quote in
                Button {
                    quoteToEdit = quote
                    selectedTab = "devis"
                } label: {
                    VStack(alignment: .leading) {
                        Text(quote.projectName ?? "Sans nom")
                            .font(.headline)
                        Text("Devis n° \(quote.devisNumber ?? "-")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let date = quote.date {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("📄 Devis sauvegardés")
        }
        // Navigation conditionnelle
        .background(
            NavigationLink(
                destination: selectedQuoteToEdit.map {
                    NewQuoteView(existingQuote: $0, selectedTab: $selectedTab)
                },
                isActive: .constant(selectedQuoteToEdit != nil),
                label: { EmptyView() }
            )
            .hidden()
        )
    }
}
