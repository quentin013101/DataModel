import SwiftUI

struct NewQuoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

   // private let companyInfo: CompanyInfo
    @State private var companyInfo: CompanyInfo = CompanyInfo.loadFromUserDefaults()
    @State private var selectedClient: Contact?
    @State private var quoteArticles: [QuoteArticle] = []
    @State private var clientProjectAddress = ""
    @State private var projectName: String = ""

    @State private var showingClientSelection = false
    @State private var showingArticleSelection = false
    @State private var showingProjectNameAlert = false

    @State private var documentHeight: CGFloat = 842

    

    init() {
        self.companyInfo = CompanyInfo.loadFromUserDefaults()
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()

            GeometryReader { geo in
                let scaleFactor = geo.size.height / 842
                let scaledWidth = 595 * scaleFactor

                ScrollView(.vertical) {
                    VStack {
                        A4SheetView(
                            selectedClient: $selectedClient,
                            quoteArticles: $quoteArticles,
                            clientProjectAddress: $clientProjectAddress,
                            projectName: $projectName,
                            companyInfo: $companyInfo,
                            showingClientSelection: $showingClientSelection,
                            showingArticleSelection: $showingArticleSelection
                        )
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        documentHeight = proxy.size.height
                                        print("Hauteur réelle du document : \(proxy.size.height)")
                                    }
                                    .onChange(of: proxy.size.height) { newHeight in
                                        documentHeight = newHeight
                                        print("Nouvelle hauteur réelle du document : \(newHeight)")
                                    }
                            }
                        )
                        .frame(width: 595, height: documentHeight)
                    }
                    .frame(width: 595, height: max(documentHeight, 842), alignment: .top)
                }
                .frame(width: 595, height: 842) // toujours taille A4 réelle
                .scaleEffect(scaleFactor, anchor: .center) // zoom uniquement extérieur
                .frame(width: scaledWidth, height: geo.size.height, alignment: .center)
                .background(Color.gray.opacity(0.1))
                .clipped()
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
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
                if let client = selectedClient {
                    clientProjectAddress = "\(client.street ?? "")\n\(client.postalCode ?? "") \(client.city ?? "")"
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
