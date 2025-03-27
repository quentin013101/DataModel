import SwiftUI
import PDFKit
import AppKit
import UniformTypeIdentifiers

struct NewQuoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

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
        VStack {
            HStack {
                Button(action: exportPDF) {
                    Image(systemName: "doc.richtext")
                        .imageScale(.large)
                }
                .help("Export PDF")

                Button(action: previewPDF) {
                    Image(systemName: "eye")
                        .imageScale(.large)
                }
                .help("Prévisualisation PDF")
            }
            .padding()

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

    func exportPDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "Devis.pdf"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                let pdfSize = CGSize(width: 595, height: documentHeight)
                let pdfView = A4SheetView(
                    selectedClient: $selectedClient,
                    quoteArticles: $quoteArticles,
                    clientProjectAddress: $clientProjectAddress,
                    projectName: $projectName,
                    companyInfo: $companyInfo,
                    showingClientSelection: .constant(false),
                    showingArticleSelection: .constant(false)
                )
                // ✅ Appel avec URL pour enregistrer
                printToPDF(pdfView, size: pdfSize, saveURL: url)
            }
        }
    }

    func previewPDF() {
        let pdfSize = CGSize(width: 595, height: documentHeight)

        let pdfView = A4SheetView(
            selectedClient: $selectedClient,
            quoteArticles: $quoteArticles,
            clientProjectAddress: $clientProjectAddress,
            projectName: $projectName,
            companyInfo: $companyInfo,
            showingClientSelection: .constant(false),
            showingArticleSelection: .constant(false)
        )

        // ✅ Appel sans URL → mode "preview"
        previewPDF(pdfView, size: pdfSize)
    }
}
extension View {
    func renderAsPDF(size: CGSize) -> Data? {
        let hostingView = NSHostingView(rootView: self.frame(width: size.width, height: size.height))
        hostingView.frame = CGRect(origin: .zero, size: size)

        // Ajouter manuellement le layer si absent
        if hostingView.layer == nil {
            hostingView.wantsLayer = true
            hostingView.layer = CALayer()
        }

        // Forcer le layout
        hostingView.layoutSubtreeIfNeeded()

        let pdfData = NSMutableData()
        let consumer = CGDataConsumer(data: pdfData as CFMutableData)!
        var mediaBox = CGRect(origin: .zero, size: size)
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return nil }

        // Démarrer la page PDF
        context.beginPDFPage(nil)

        // Créer un bitmap et dessiner dans le contexte
        hostingView.layer?.render(in: context)

        context.endPDFPage()
        context.closePDF()

        return pdfData as Data
    }
  

//    func previewPDFData(_ data: Data) {
//        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("AperçuDevis.pdf")
//        try? data.write(to: tmpURL)
//        NSWorkspace.shared.open(tmpURL)
//    }

//    func savePDFData(_ data: Data) {
//        let panel = NSSavePanel()
//        panel.allowedContentTypes = [UTType.pdf]
//        panel.nameFieldStringValue = "Devis.pdf"
//        panel.begin { response in
//            if response == .OK, let url = panel.url {
//                try? data.write(to: url)
//            }
//        }
//    }
    func printToPDF<V: View>(_ view: V, size: CGSize, saveURL: URL) {
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = CGRect(origin: .zero, size: size)

        let data = hostingView.dataWithPDF(inside: hostingView.bounds)
        try? data.write(to: saveURL)
    }
    func previewPDF<V: View>(_ view: V, size: CGSize) {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("PreviewQuote.pdf")
        printToPDF(view, size: size, saveURL: tmpURL)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSWorkspace.shared.open(tmpURL)
        }
    }
}
extension Contact {
    var fullName: String {
        let civ = civility ?? ""
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(civ) \(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}
