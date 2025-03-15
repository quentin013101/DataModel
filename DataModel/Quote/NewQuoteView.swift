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
        ZStack {
            // Fond gris
            Color.gray.opacity(0.2)
                .ignoresSafeArea()

            // Scroll vertical sur l'ensemble du document
            ScrollView(.vertical) {
                // Centre horizontalement l'A4
                HStack {
                    Spacer(minLength: 0)

                    A4SheetView(
                        companyInfo: companyInfo,
                        selectedClient: $selectedClient,
                        quoteArticles: $quoteArticles,
                        clientProjectAddress: $clientProjectAddress,
                        projectName: $projectName,
                        showingClientSelection: $showingClientSelection,
                        showingArticleSelection: $showingArticleSelection
                    )

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 20)
            }
        }         // Popovers et autres logiques
            .popover(
                isPresented: $showingClientSelection,
                attachmentAnchor: .point(.center),
                arrowEdge: .top
            ) {
                NavigationView {
                    ClientSelectionView(selectedClient: $selectedClient,
                                        clientProjectAddress: $clientProjectAddress)
                        .environment(\.managedObjectContext, viewContext)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Fermer") {
                                    showingClientSelection = false
                                }
                            }
                        }
                }
                .frame(width: 400, height: 500)
                .onDisappear {
                    // Mettre à jour l'adresse du projet si besoin
                    if let client = selectedClient {
                        clientProjectAddress = "\(client.street ?? ""), \(client.postalCode ?? "") \(client.city ?? "")"
                    }
                }
            }
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
                        // On ne ferme pas le popover
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
                .frame(width: 400, height: 600)
            }
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
