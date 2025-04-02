import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: String
    
    @State private var showNewQuoteView = false // 👈 Vue contrôlée
    @State private var quoteToEdit: QuoteEntity? = nil


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
                    .onAppear {
                        quoteToEdit = nil
                    }
            case "devisFactures":
                QuoteListView(selectedTab: $selectedTab, quoteToEdit: $quoteToEdit) // ✅ ajout manquant
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
