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
    @State private var selectedArticle: Article? = nil // 🔥 On gère la `sheet` directement avec `selectedArticle`
    @State private var sheetID = UUID() // 🔥 Force la réouverture de la `sheet`

    var body: some View {
        VStack {
            HStack {
                TextField("Rechercher un article", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 10)

                Button(action: { showingAddArticle = true }) {
                    Text("NOUVEL ARTICLE")
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal)

            Divider()

            if articles.isEmpty {
                Text("Aucun article trouvé")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(articles) { article in
                        Button(action: {
                            openArticleDetail(article)
                        }) {
                            HStack {
                                Text(article.name ?? "Sans nom")
                                    .font(.headline)
                                Spacer()
                                Text(article.unit ?? "")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteArticles)
                }
            }
        }
        .padding()
        .onAppear {
            selectedTab = "articles"
        }
        .sheet(item: $selectedArticle) { article in // ✅ Utilisation de `.sheet(item:)` pour éviter le bug
            ArticleDetailView(article: article)
                .id(sheetID) // 🔥 Force la réouverture
        }
        .sheet(isPresented: $showingAddArticle) {
            AddArticleView().environment(\.managedObjectContext, viewContext)
        }
    }

    private func openArticleDetail(_ article: Article) {
        print("📌 Avant fermeture : selectedArticle = \(selectedArticle?.name ?? "Aucun")")

        selectedArticle = nil // 🔥 Réinitialise avant d'ouvrir un nouvel article

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 🔥 Petit délai pour s'assurer que SwiftUI détecte le changement
            selectedArticle = article
            sheetID = UUID() // 🔥 Change l'ID de la `sheet` pour forcer SwiftUI à la recharger
            print("✅ Article sélectionné : \(selectedArticle?.name ?? "Aucun")")
        }
    }

    private func deleteArticles(at offsets: IndexSet) {
        for index in offsets {
            let article = articles[index]
            viewContext.delete(article)
        }
        try? viewContext.save()
    }
}
