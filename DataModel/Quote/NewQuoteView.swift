import SwiftUI

struct NewQuoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var selectedClient: Contact?
    @State private var selectedArticles: [Article] = []
    @State private var quoteTitle = ""
    @State private var quoteNumber = UUID().uuidString
    @State private var total: Double = 0.0

    var body: some View {
        VStack(spacing: 20) {
            Text("Nouveau Devis")
                .font(.title)
                .bold()

            Form {
                Section(header: Text("Informations du devis").bold()) {
                    TextField("Titre du devis", text: $quoteTitle)
                    Text("Numéro : \(quoteNumber)")
                }

                Section(header: Text("Client").bold()) {
                    NavigationLink(destination: ClientSelectionView(selectedContact: $selectedClient)){
                        Text(selectedClient?.firstName ?? "Sélectionner un client")
                            .foregroundColor(.blue)
                    }
                }

                Section(header: Text("Articles").bold()) {
                    NavigationLink(destination: ArticleSelectionView(selectedArticles: $selectedArticles)) {
                        Text("Ajouter des articles (\(selectedArticles.count))")
                            .foregroundColor(.blue)
                    }
                }

                Section(header: Text("Total").bold()) {
                    Text("\(calculateTotal(), specifier: "%.2f") € HT")
                        .bold()
                }
            }

            HStack {
                Button("Annuler") {
                    dismiss()
                }
                .foregroundColor(.blue)

                Spacer()

                Button("Enregistrer") {
                    saveQuote()
                }
                .foregroundColor(.green)
            }
            .padding()
        }
        .padding()
    }

    private func calculateTotal() -> Double {
        return selectedArticles.reduce(0) { $0 + ($1.price) }
    }

    private func saveQuote() {
        let newQuote = Quote(context: viewContext)
        newQuote.title = quoteTitle
        newQuote.number = quoteNumber
        newQuote.total = calculateTotal()
        newQuote.client = selectedClient
        
        // 🔹 Ajout des articles via une relation Core Data correcte
        for article in selectedArticles {
            let quoteArticle = QuoteArticle(context: viewContext)
            quoteArticle.article = article
            quoteArticle.quote = newQuote // ✅ Associe l'article au devis
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Erreur lors de l'enregistrement : \(error)")
        }
    }
}
