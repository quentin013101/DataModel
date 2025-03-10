import SwiftUI
import CoreData

struct ArticleListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTab: String

    @FetchRequest(
        entity: Article.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Article.name, ascending: true)]
    ) private var articles: FetchedResults<Article>
    
    @State private var searchText = ""
    @State private var showingAddArticle = false
    @State private var selectedArticle: Article? = nil
    @State private var sheetID = UUID()

    @State private var selectedArticles = Set<NSManagedObjectID>() // ✅ Sélection multiple
    @State private var sortBy: SortOption = .name // ✅ Tri par défaut
    @State private var isAscending = true // ✅ Direction du tri

    enum SortOption {
        case type, name, unit, cost, marginPercentage, price
    }

    var body: some View {
        VStack {
            // ✅ Barre de recherche + Gestion de la sélection multiple
            HStack {
                TextField("Rechercher un article", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)
                    .padding(.leading, 10)

                Spacer()

                // ✅ Boutons visibles uniquement si sélection active
                if !selectedArticles.isEmpty {
                    Button(action: deselectAllArticles) {
                        Text("Tout désélectionner")
                            .bold()
                            .foregroundColor(.blue)
                    }

                    Button(action: deleteSelectedArticles) {
                        Text("SUPPRIMER (\(selectedArticles.count))")
                            .bold()
                            .foregroundColor(.red)
                    }
                }

                Button(action: { showingAddArticle = true }) {
                    Text("NOUVEL ARTICLE")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            Divider()
            let columns: [GridItem] = [
                GridItem(.fixed(100), alignment: .leading),  // Type
                GridItem(.fixed(520), alignment: .leading),  // Nom
                GridItem(.fixed(80), alignment: .leading),   // Unité
                GridItem(.fixed(100), alignment: .trailing), // Coût
                GridItem(.fixed(100), alignment: .trailing), // Marge
                GridItem(.fixed(100), alignment: .trailing)  // Prix
            ]
            // ✅ En-tête des colonnes triables
            LazyVGrid(columns: columns, spacing: 10) {
                Text("Type").bold()
                Text("Nom").bold()
                Text("Unité").bold()
                Text("Coût").bold()
                Text("Marge (%)").bold()
                Text("Prix").bold()
            }
            .padding(.vertical, 5)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            Divider()

            if filteredArticles.isEmpty {
                Text("Aucun article trouvé")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(filteredArticles, id: \.self) { article in
                            HStack {
                                // ✅ Case à cocher pour la sélection multiple
                                Button(action: { toggleSelection(article) }) {
                                    Image(systemName: selectedArticles.contains(article.objectID) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedArticles.contains(article.objectID) ? .blue : .gray)
                                        .frame(width: 30)
                                }
                                .buttonStyle(PlainButtonStyle())

                                // ✅ Infos article
                                Button(action: { openArticleDetail(article) }) {
                                    HStack {
                                        Text(article.type ?? "-")
                                            .frame(width: 100, alignment: .leading)

                                        Text(article.name ?? "Sans nom")
                                            .frame(width: 520, alignment: .leading)

                                        Text(article.unit ?? "-")
                                            .frame(width: 80, alignment: .leading)

                                        Text(String(format: "%.2f €", article.cost))
                                            .frame(width: 100, alignment: .trailing) // 🔥 Aligné à droite

                                        Text(String(format: "%.2f %%", article.marginPercentage))
                                            .frame(width: 100, alignment: .trailing) // 🔥 Aligné à droite

                                        Text(String(format: "%.2f €", article.price))
                                            .frame(width: 100, alignment: .trailing) // 🔥 Aligné à droite
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
        .onAppear { selectedTab = "articles" }
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(article: article)
                .id(sheetID)
        }
        .sheet(isPresented: $showingAddArticle) {
            AddArticleView().environment(\.managedObjectContext, viewContext)
        }
    }

    /// ✅ Sélectionner/désélectionner un article
    private func toggleSelection(_ article: Article) {
        let articleID = article.objectID
        if selectedArticles.contains(articleID) {
            selectedArticles.remove(articleID)
        } else {
            selectedArticles.insert(articleID)
        }
    }

    /// ✅ Supprime tous les articles sélectionnés avec confirmation
    private func deleteSelectedArticles() {
        guard !selectedArticles.isEmpty else { return }

        let alert = NSAlert()
        alert.messageText = "Confirmer la suppression"
        alert.informativeText = "Êtes-vous sûr de vouloir supprimer \(selectedArticles.count) article(s) ? Cette action est irréversible."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Supprimer")
        alert.addButton(withTitle: "Annuler")

        if alert.runModal() == .alertFirstButtonReturn {
            for articleID in selectedArticles {
                if let article = viewContext.object(with: articleID) as? Article {
                    viewContext.delete(article)
                }
            }
            try? viewContext.save()
            selectedArticles.removeAll()
        }
    }

    /// ✅ Désélectionner tous les articles
    private func deselectAllArticles() {
        selectedArticles.removeAll()
    }
    
    /// ✅ Ouvre la fiche détaillée de l'article
    private func openArticleDetail(_ article: Article) {
        selectedArticle = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedArticle = article
            sheetID = UUID()
        }
    }

    /// ✅ Applique le tri et la recherche
    var filteredArticles: [Article] {
        let filtered = articles.filter { article in
            searchText.isEmpty ||
            (article.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (article.type?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (article.unit?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        
        return filtered.sorted {
            switch sortBy {
            case .type:
                return isAscending ? ($0.type ?? "") < ($1.type ?? "") : ($0.type ?? "") > ($1.type ?? "")
            case .name:
                return isAscending ? ($0.name ?? "") < ($1.name ?? "") : ($0.name ?? "") > ($1.name ?? "")
            case .unit:
                return isAscending ? ($0.unit ?? "") < ($1.unit ?? "") : ($0.unit ?? "") > ($1.unit ?? "")
            case .cost:
                return isAscending ? $0.cost < $1.cost : $0.cost > $1.cost
            case .marginPercentage:
                return isAscending ? $0.marginPercentage < $1.marginPercentage : $0.marginPercentage > $1.marginPercentage
            case .price:
                return isAscending ? $0.price < $1.price : $0.price > $1.price
            }
        }
    }
}

// ✅ Correction du composant pour les en-têtes triables
struct ArticleSortableColumn: View {
    let title: String
    @Binding var sortBy: ArticleListView.SortOption
    @Binding var isAscending: Bool
    let column: ArticleListView.SortOption

    var body: some View {
        Button(action: {
            if sortBy == column {
                isAscending.toggle() // 🔁 Inverse la direction du tri
            } else {
                sortBy = column
                isAscending = true
            }
        }) {
            HStack {
                Text(title)
                    .font(.headline)
                    .bold()
                if sortBy == column {
                    Image(systemName: isAscending ? "arrow.up" : "arrow.down") // 🔼🔽 Indicateur de tri
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
