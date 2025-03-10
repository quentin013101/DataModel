import SwiftUI

struct NewQuoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    private let companyInfo: CompanyInfo

    @State private var selectedClient: Contact?
    @State private var quoteArticles: [QuoteArticle] = []
    @State private var clientProjectAddress = ""
    @State private var projectName: String = ""

    // Popovers
    @State private var showingClientSelection = false
    @State private var showingArticleSelection = false

    @State private var showingProjectNameAlert = false

    init() {
        self.companyInfo = CompanyInfo.loadFromUserDefaults()
    }

    var body: some View {
        GeometryReader { geometry in
            let scaleFactor = min(
                geometry.size.width * 0.8 / 595,
                geometry.size.height * 0.95 / 842
            )

            ZStack {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()

                ScrollView {
                    VStack {
                        A4SheetView(
                            companyInfo: companyInfo,
                            selectedClient: $selectedClient,
                            quoteArticles: $quoteArticles,
                            clientProjectAddress: $clientProjectAddress,
                            projectName: $projectName,
                            showingClientSelection: $showingClientSelection,
                            showingArticleSelection: $showingArticleSelection
                        )
                        .scaleEffect(scaleFactor)
                        .frame(width: 595 * scaleFactor,
                               height: 842 * scaleFactor)
                    }
                    .frame(maxWidth: .infinity,
                           minHeight: geometry.size.height)
                }
            }
            // ─────────────────────────────────────────────────────
            // Popover pour sélectionner un client
            // ─────────────────────────────────────────────────────
            .popover(
                isPresented: $showingClientSelection,
                attachmentAnchor: .point(.center),
                arrowEdge: .top
            ) {
                // On peut mettre un NavigationView si on veut un style "sheet"
                NavigationView {
                    ClientSelectionView(selectedClient: $selectedClient)
                        .environment(\.managedObjectContext, viewContext)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Fermer") {
                                    showingClientSelection = false
                                }
                            }
                        }
                }
                .frame(width: 450, height: 500)
                .onDisappear {
                    if let client = selectedClient {
                        clientProjectAddress = "\(client.street ?? ""), \(client.postalCode ?? "") \(client.city ?? "")"
                    }
                }
            }
            // ─────────────────────────────────────────────────────
            // Popover pour sélectionner un article
            // ─────────────────────────────────────────────────────
            .popover(
                isPresented: $showingArticleSelection,
                attachmentAnchor: .point(.center),
                arrowEdge: .top
            ) {
                NavigationView {
                    ArticleSelectionView { article, quantity in
                        let newQA = QuoteArticle(
                            id: UUID(),
                            article: article,
                            quantity: quantity,
                            unitPrice: article.price
                        )
                        quoteArticles.append(newQA)
                        // On NE ferme pas le popover,
                        // permettant de sélectionner plusieurs articles.
                    }
                    .environment(\.managedObjectContext, viewContext)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Fermer") {
                                showingArticleSelection = false
                            }
                        }
                    }
                }
                .frame(width: 500, height: 600)
            }
            // ─────────────────────────────────────────────────────
            // Alerte pour demander le nom du projet
            // ─────────────────────────────────────────────────────
            .alert("Nom du projet", isPresented: $showingProjectNameAlert) {
                TextField("Nom du projet", text: $projectName)
                Button("OK") {}
            } message: {
                Text("Veuillez saisir le nom du projet.")
            }
            .onAppear {
                if projectName.isEmpty {
                    showingProjectNameAlert = true
                }
            }
        }
    }
}
