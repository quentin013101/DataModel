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
    @State private var devisNumber: String = ""
    @State private var sousTotal: Double = 0.0
    @State private var remiseAmount: Double = 0.0
    @State private var remiseIsPercentage: Bool = false
    @State private var remiseValue: Double = 0.0
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
                                showingArticleSelection: $showingArticleSelection,
                                devisNumber: $devisNumber,
                                sousTotal: $sousTotal,
                                remiseAmount: $remiseAmount,
                                remiseIsPercentage: $remiseIsPercentage,
                                remiseValue: $remiseValue
                            )
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            documentHeight = proxy.size.height
                                        }
                                        .onChange(of: proxy.size.height) { newHeight in
                                            documentHeight = newHeight
                                        }
                                }
                            )
                            .frame(width: 595, height: documentHeight)
                        }
                        .frame(width: 595, height: max(documentHeight, 842), alignment: .top)
                    }
                    .frame(width: 595, height: 842)
                    .scaleEffect(scaleFactor, anchor: .center)
                    .frame(width: scaledWidth, height: geo.size.height, alignment: .center)
                    .background(Color.gray.opacity(0.1))
                    .clipped()
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .popover(isPresented: $showingClientSelection) {
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
            .popover(isPresented: $showingArticleSelection) {
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
                let pdfView = A4SheetView(
                    selectedClient: $selectedClient,
                    quoteArticles: $quoteArticles,
                    clientProjectAddress: $clientProjectAddress,
                    projectName: $projectName,
                    companyInfo: $companyInfo,
                    showingClientSelection: .constant(false),
                    showingArticleSelection: .constant(false),
                    devisNumber: $devisNumber,
                    sousTotal: $sousTotal,
                    remiseAmount: $remiseAmount,
                    remiseIsPercentage: $remiseIsPercentage,
                    remiseValue: $remiseValue
                )
                .environment(\.isPrinting, true)
                .frame(width: 595)
                .fixedSize(horizontal: false, vertical: true)

                let hostingView = NSHostingView(rootView: pdfView)
                let contentSize = hostingView.fittingSize
                hostingView.frame = CGRect(origin: .zero, size: contentSize)

                // ✅ View container fixe largeur 595
                let container = NSView(frame: CGRect(x: 0, y: 0, width: 595, height: contentSize.height))
                hostingView.setFrameOrigin(NSPoint(x: 0, y: 0)) // 👈 Important !
                container.addSubview(hostingView)

                let printInfo = NSPrintInfo()
                printInfo.jobDisposition = .save
                printInfo.paperSize = NSSize(width: 595, height: 842)
                printInfo.topMargin = 0
                printInfo.bottomMargin = 0
                printInfo.leftMargin = 0
                printInfo.rightMargin = 0
                printInfo.verticalPagination = .automatic
                printInfo.horizontalPagination = .automatic
                printInfo.isHorizontallyCentered = false
                printInfo.isVerticallyCentered = false
                printInfo.dictionary()[NSPrintInfo.AttributeKey(rawValue: "NSJobSavingURL")] = url as NSURL

                let printOp = NSPrintOperation(view: container, printInfo: printInfo)
                printOp.showsPrintPanel = false
                printOp.showsProgressPanel = false
                printOp.run()
            }
        }
    }

    func previewPDF() {
        let pdfView = A4SheetView(
            selectedClient: $selectedClient,
            quoteArticles: $quoteArticles,
            clientProjectAddress: $clientProjectAddress,
            projectName: $projectName,
            companyInfo: $companyInfo,
            showingClientSelection: .constant(false),
            showingArticleSelection: .constant(false),
            devisNumber: $devisNumber,
            sousTotal: $sousTotal,
            remiseAmount: $remiseAmount,
            remiseIsPercentage: $remiseIsPercentage,
            remiseValue: $remiseValue
        )
        .environment(\.isPrinting, true)
        .frame(width: 595)
        .fixedSize(horizontal: false, vertical: true)

        let hostingView = NSHostingView(rootView: pdfView)
        let contentSize = hostingView.fittingSize
        hostingView.frame = CGRect(origin: .zero, size: contentSize)

        let container = NSView(frame: CGRect(x: 0, y: 0, width: 595, height: contentSize.height))
        hostingView.setFrameOrigin(NSPoint(x: 0, y: 0))
        container.addSubview(hostingView)

        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("PreviewQuote.pdf")

        let printInfo = NSPrintInfo()
        printInfo.jobDisposition = .save
        printInfo.paperSize = NSSize(width: 595, height: 842)
        printInfo.topMargin = 0
        printInfo.bottomMargin = 0
        printInfo.leftMargin = 0
        printInfo.rightMargin = 0
        printInfo.verticalPagination = .automatic
        printInfo.horizontalPagination = .automatic
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        printInfo.dictionary()[NSPrintInfo.AttributeKey(rawValue: "NSJobSavingURL")] = tmpURL as NSURL

        let printOp = NSPrintOperation(view: container, printInfo: printInfo)
        printOp.showsPrintPanel = false
        printOp.showsProgressPanel = false

        if printOp.run() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSWorkspace.shared.open(tmpURL)
            }
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
