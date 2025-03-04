import SwiftUI
import CoreData

struct ArticleSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedArticles: [QuoteArticle] // ✅ Utilisation de `QuoteArticle` pour gérer les quantités
    @State private var searchText = ""
    @State private var showingAddArticle = false
    @State private var selectedArticle: Article?
    @State private var selectedQuantity: Int = 1

    @FetchRequest(
        entity: Article.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Article.name, ascending: true)]
    ) private var articles: FetchedResults<Article>

    var body: some View {
        VStack {
            Text("Sélectionner un article")
                .font(.title2)
                .bold()
                .padding()

            TextField("Rechercher un article...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if filteredArticles.isEmpty {
                Text("Aucun article trouvé")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(filteredArticles, id: \.self) { article in
                    Button(action: {
                        selectedArticle = article
                    }) {
                        HStack {
                            Text(article.name ?? "-")
                            Spacer()
                            Text(String(format: "%.2f €", article.price))
                        }
                        .padding()
                    }
                }
            }

            Button("Ajouter un nouvel article") {
                showingAddArticle = true
            }
            .foregroundColor(.blue)
            .padding()
        }
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $showingAddArticle) {
            AddArticleView().environment(\.managedObjectContext, viewContext)
        }
        .onTapGesture {
            dismiss() // ✅ Ferme la fenêtre si on clique en dehors
        }
        .alert("Choisir la quantité", isPresented: Binding<Bool>(
            get: { selectedArticle != nil },
            set: { if !$0 { selectedArticle = nil } }
        )) {
            TextField("Quantité", value: $selectedQuantity, format: .number)
            
            Button("Ajouter") {
                if let article = selectedArticle {
                    let newQuoteArticle = QuoteArticle(context: viewContext)
                    newQuoteArticle.article = article
                    newQuoteArticle.quantity = Int16(selectedQuantity)
                    selectedArticles.append(newQuoteArticle)
                }
                selectedArticle = nil
            }
        }
    }

    var filteredArticles: [Article] {
        if searchText.isEmpty {
            return Array(articles)
        } else {
            return articles.filter { article in
                let name = article.name ?? ""
                return name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
