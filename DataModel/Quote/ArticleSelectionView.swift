import SwiftUI
import CoreData

struct ArticleSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // On ne force plus la fermeture au moindre clic
    // @Environment(\.dismiss) private var dismiss

    var onArticleSelected: (Article, Int16) -> Void  // Ajoute la quantité

    @State private var searchText = ""
    @State private var showingAddArticle = false
//    @State private var selectedArticle: Article?
//    @State private var selectedQuantity: Int16 = 1
//    @State private var showQuantityAlert = false

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
                        // On ajoute l'article avec une quantité par défaut (ex: 1)
                        onArticleSelected(article, 1)
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
            .padding()
            .foregroundColor(.blue)
        }
        .frame(minWidth: 400, minHeight: 500)

        // Ouvre AddArticleView pour en créer un nouveau
        .sheet(isPresented: $showingAddArticle, onDismiss: {
            refreshArticles()
        }) {
            AddArticleView().environment(\.managedObjectContext, viewContext)
        }

        // Alerte pour choisir la quantité

//        .alert("Choisir la quantité", isPresented: $showQuantityAlert) {
//            TextField("Quantité", value: $selectedQuantity, format: .number)
//            Button("Ajouter") {
//                if let article = selectedArticle {
//                    onArticleSelected(article, selectedQuantity)
//                }
//                selectedArticle = nil
//                selectedQuantity = 1
//            }
//            Button("Annuler", role: .cancel) {}
//        }
   
    }

    private var filteredArticles: [Article] {
        if searchText.isEmpty {
            return Array(articles)
        } else {
            return articles.filter { article in
                let name = article.name ?? ""
                return name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    private func refreshArticles() {
        do {
            try viewContext.refreshAllObjects()
        } catch {
            print("❌ Erreur lors de la mise à jour des articles : \(error.localizedDescription)")
        }
    }
}
