import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: String

    @State private var quoteToEdit: QuoteEntity? = nil
    @State private var invoiceToEdit: Invoice? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
        } detail: {
            switch selectedTab {
            case "clients":
                ContactListView(selectedTab: $selectedTab)
            case "articles":
                ArticleListView(selectedTab: $selectedTab)
            case "devis":
                NewQuoteView(existingQuote: quoteToEdit, selectedTab: $selectedTab)
                    .onAppear { quoteToEdit = nil }

            case "facture":
                if let invoice = invoiceToEdit {
                    NewInvoiceView(viewModel: InvoiceViewModel(invoice: invoice), selectedTab: $selectedTab)
                } else {
                    Text("Aucune facture sélectionnée")
                }
            case "devisFactures":
                QuoteListView(
                    selectedTab: $selectedTab,
                    quoteToEdit: $quoteToEdit,
                    invoiceToEdit: $invoiceToEdit
                )

            default:
                Text("Sélectionnez un élément")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
        }
    }
}

#Preview {
    ContentView(selectedTab: .constant("clients"))
}
struct InvoiceTabView: View {
    @Binding var invoiceToEdit: Invoice?
    @Binding var selectedTab: String

    var body: some View {
        if let invoice = invoiceToEdit {
            NewInvoiceView(viewModel: InvoiceViewModel(invoice: invoice), selectedTab: $selectedTab)
                .onAppear {
                    print("Chargement facture dans tabView : \(invoice.invoiceNumber ?? "-")")
                    invoiceToEdit = nil
                }
        } else {
            Text("Aucune facture sélectionnée")
        }
    }
}
