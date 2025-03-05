import SwiftUI
import CoreData

struct ArticleSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var onArticleSelected: (Article, Int16) -> Void  // ✅ Ajoute la quantité

    @State private var searchText = ""
    @State private var showingAddArticle = false
    @State private var selectedArticle: Article?
    @State private var selectedQuantity: Int16 = 1   // ✅ Stocke la quantité sélectionnée
    @State private var showQuantityAlert = false     // ✅ Gère l'affichage de l'alerte

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
                        selectedArticle = article  // ✅ Stocke l'article sélectionné
                        showQuantityAlert = true   // ✅ Affiche l'alerte pour choisir la quantité
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
        
        // ✅ Ouvre AddArticleView
        .sheet(isPresented: $showingAddArticle, onDismiss: {
            refreshArticles() // ✅ Rafraîchit la liste après ajout
        }) {
            AddArticleView().environment(\.managedObjectContext, viewContext)
        }
        
        .onTapGesture {
            dismiss() // ✅ Ferme la fenêtre si on clique en dehors
        }
        
        .alert("Choisir la quantité", isPresented: $showQuantityAlert, actions: {
            TextField("Quantité", value: $selectedQuantity, format: .number)
            Button("Ajouter") {
                if let article = selectedArticle {
                    onArticleSelected(article, selectedQuantity)  // ✅ Passe l'article et la quantité
                }
                selectedArticle = nil
                selectedQuantity = 1  // ✅ Reset la quantité après sélection
            }
            Button("Annuler", role: .cancel) {}
        })
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
    
    // ✅ Rafraîchir les articles après ajout
    private func refreshArticles() {
        do {
            try viewContext.refreshAllObjects()
        } catch {
            print("❌ Erreur lors de la mise à jour des articles : \(error.localizedDescription)")
        }
    }
}
