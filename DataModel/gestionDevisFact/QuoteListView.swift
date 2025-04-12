import SwiftUI
import CoreData

struct QuoteListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \QuoteEntity.date, ascending: false)],
        animation: .default)
    private var quotes: FetchedResults<QuoteEntity>

    @Binding var selectedTab: String
    @Binding var quoteToEdit: QuoteEntity?
    @Binding var selectedQuoteForInvoice: QuoteEntity?
    @Binding var invoiceToEdit: Invoice?

    var groupedQuotes: [(String, [QuoteEntity])] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "LLLL yyyy"

        let grouped = Dictionary(grouping: quotes) { quote in
            dateFormatter.string(from: quote.date ?? Date())
        }

        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(groupedQuotes, id: \.0) { (month, monthQuotes) in
                    QuoteMonthSection(
                        month: month,
                        quotes: monthQuotes,
                        selectedTab: $selectedTab,
                        quoteToEdit: $quoteToEdit,
                        invoiceToEdit: $invoiceToEdit,
                        selectedQuoteForInvoice: $selectedQuoteForInvoice // ✅ Ajouté
                    )
                }
            }
            .padding(.vertical)
        }
    }
}
//    func groupQuotesByMonth(quotes: FetchedResults<QuoteEntity>) -> [(String, [QuoteEntity])] {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "fr_FR")
//        dateFormatter.dateFormat = "LLLL yyyy"
//
//        let grouped = Dictionary(grouping: quotes) { quote in
//            dateFormatter.string(from: quote.date ?? Date())
//        }
//
//        return grouped.sorted { $0.key > $1.key }
//    }

struct QuoteMonthSection: View {
    let month: String
    let quotes: [QuoteEntity]
    @Binding var selectedTab: String
    @Binding var quoteToEdit: QuoteEntity?
    @Binding var invoiceToEdit: Invoice?
    @Binding var selectedQuoteForInvoice: QuoteEntity?

    var body: some View {
        Section(header: Text(month)
            .font(.title3)
            .bold()
            .italic()
            .padding(.horizontal)) {
                ForEach(quotes) { quote in
                    QuoteGroupView(
                        selectedTab: $selectedTab,
                        quoteToEdit: $quoteToEdit,
                        invoiceToEdit: $invoiceToEdit,
                        selectedQuoteForInvoice: $selectedQuoteForInvoice,
                        quote: quote
                    )
                }
        }
    }
}

struct StatusTag: View {
    let status: String
    var body: some View {
        Text(status)
            .font(.caption)
            .padding(4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(4)
    }
}
