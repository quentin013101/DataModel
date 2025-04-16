import SwiftUI
import CoreData

struct ContentView: View {
    @Binding var selectedTab: String

    @State private var quoteToEdit: QuoteEntity? = nil
    @State private var invoiceToEdit: Invoice? = nil
    @State private var selectedQuoteForInvoice: QuoteEntity? = nil

    var body: some View {
        NavigationView {
            SidebarView(selectedTab: $selectedTab)
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            
            // 👇 Contenu principal en fonction de l'onglet
            detailView
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle()) // important pour macOS
    }

    @ViewBuilder
    var detailView: some View {
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
                NewInvoiceView(invoice: invoice, sourceQuote: selectedQuoteForInvoice, selectedTab: $selectedTab)
            } else {
                Text("Aucune facture sélectionnée")
            }
        case "devisFactures":
            QuoteListView(
                selectedTab: $selectedTab,
                quoteToEdit: $quoteToEdit,
                selectedQuoteForInvoice: $selectedQuoteForInvoice,
                invoiceToEdit: $invoiceToEdit
            )
        case "dashboard":
            DashboardView(
                selectedTab: $selectedTab,
                quoteToEdit: $quoteToEdit,
                invoiceToEdit: $invoiceToEdit,
                selectedQuoteForInvoice: $selectedQuoteForInvoice
            )
        default:
            Text("Sélectionnez un élément")
                .foregroundColor(.blue)
                .font(.title2)
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
            NewInvoiceView(invoice: invoice, sourceQuote: nil, selectedTab: $selectedTab)
                .onAppear {
                    print("Chargement facture dans tabView : \(invoice.invoiceNumber ?? "-")")
                    invoiceToEdit = nil
                }
        } else {
            Text("Aucune facture sélectionnée")
        }
    }
}
