import SwiftUI
import PDFKit
import AppKit

struct NewInvoiceView: View {
    let invoice: Invoice
    let sourceQuote: QuoteEntity?
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTab: String

    @State private var companyInfo: CompanyInfo = CompanyInfo.loadFromUserDefaults()
    @State private var selectedClient: Contact? = nil
    @State private var quoteArticles: [QuoteArticle] = []
    @State private var clientStreet: String = ""
    @State private var clientPostalCode: String = ""
    @State private var clientCity: String = ""
    @State private var clientProjectAddress: String = ""
    @State private var projectName: String = ""
    @State private var documentNumber: String = ""
    @State private var devisNumber: String = ""
    @State private var sousTotal: Double = 0.0
    @State private var remiseAmount: Double = 0.0
    @State private var remiseIsPercentage: Bool = false
    @State private var remiseValue: Double = 0.0
    @State private var acompteText: String = ""
    @State private var acomptePercentage: Double = 30
    @State private var soldeText: String = ""
    @State private var soldePercentage: Double = 70
    @State private var showAcompteLine: Bool = false
    @State private var showSoldeLine: Bool = false
    @State private var acompteLabel: String = "Acompte à la signature de"
    @State private var soldeLabel: String = "Solde à la réception du chantier de"
    @State private var signatureBlockHeight: CGFloat = 0
    @State private var showingClientSelection = false
    @State private var showingArticleSelection = false
    @State private var documentHeight: CGFloat = 842
    @State private var deductedInvoices: Set<Invoice> = []
    @State private var quoteDate: Date = Date()

    init(invoice: Invoice, sourceQuote: QuoteEntity? = nil, selectedTab: Binding<String>) {
        self.invoice = invoice
        self.sourceQuote = sourceQuote
        _selectedTab = selectedTab
    }

    var body: some View {
        VStack(spacing: 0) {
            // 🔵 Bandeau de boutons
            HStack {
                Button(action: exportPDF) {
                    Label("Export PDF", systemImage: "square.and.arrow.up")
                        .padding(6)
                        .cornerRadius(8)
                }
                .buttonStyle(DefaultButtonStyle()) // ou PlainButtonStyle si besoin
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(6)
                .help("Export PDF")

                Button(action: previewPDF) {
                    Label("Prévisualiser", systemImage: "eye.circle")
                        .padding(6)
                        .cornerRadius(8)
                }
                .buttonStyle(DefaultButtonStyle()) // ou PlainButtonStyle si besoin
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(6)
                .help("Prévisualisation PDF")

                Button {
                    saveInvoice()
                    selectedTab = "devisFactures"
                } label: {
                    Label("Enregistrer", systemImage: "externaldrive.fill.badge.checkmark")
                        .padding(6)
                        .cornerRadius(8)
                }
                .buttonStyle(DefaultButtonStyle()) // ou PlainButtonStyle si besoin
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(6)
                Button {
                    selectedTab = "devisFactures"
                } label: {
                    Label("Annuler", systemImage: "xmark.circle")
                        .padding(6)
                        .cornerRadius(8)
                }
                .buttonStyle(DefaultButtonStyle()) // ou PlainButtonStyle si besoin
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(6)
            }
            .padding()
           // .background(Color(NSColor.controlBackgroundColor)) // ✅ même fond que dans NewQuoteView

            // 🧾 Feuille A4 centrée
            ZStack {
                Color.gray.opacity(0.2).ignoresSafeArea()

                GeometryReader { geo in
                    let scaleFactor = geo.size.height / 842
                    let scaledWidth = 595 * scaleFactor

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            A4SheetView(
                                showHeader: true,
                                showFooter: true,
                                showSignature: true,
                                globalQuoteArticles: quoteArticles,
                                isInvoice: true,
                                invoiceType: invoice.invoiceTypeEnum,
                                invoice: invoice,
                                sourceQuote: sourceQuote,
                                deductedInvoices: $deductedInvoices,
                                selectedClient: $selectedClient,
                                quoteArticles: $quoteArticles,
                                clientProjectAddress: $clientProjectAddress,
                                projectName: $projectName,
                                companyInfo: $companyInfo,
                                clientStreet: $clientStreet,
                                clientPostalCode: $clientPostalCode,
                                clientCity: $clientCity,
                                showingClientSelection: $showingClientSelection,
                                showingArticleSelection: $showingArticleSelection,
                                devisNumber: $devisNumber,
                                documentNumber: $documentNumber,
                                signatureBlockHeight: $signatureBlockHeight,
                                sousTotal: $sousTotal,
                                remiseAmount: $remiseAmount,
                                remiseIsPercentage: $remiseIsPercentage,
                                remiseValue: $remiseValue,
                                acompteText: $acompteText,
                                soldeText: $soldeText,
                                acomptePercentage: $acomptePercentage,
                                soldePercentage: $soldePercentage,
                                showSoldeLine: $showSoldeLine,
                                showAcompteLine: $showAcompteLine,
                                acompteLabel: $acompteLabel,
                                soldeLabel: $soldeLabel,
                                quoteDate: $quoteDate
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
                            .frame(width: 595, height: max(documentHeight, 842))
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
        }
        .onAppear {
            if let quote = sourceQuote {
                loadQuoteData(from: quote)
            }

            if let data = invoice.invoiceArticlesData,
               let articles = try? JSONDecoder().decode([QuoteArticle].self, from: data) {
                self.quoteArticles = articles
            }
            if invoice.invoiceTypeEnum == .finale {
                if let sourceQuote = sourceQuote {
                    let allInvoices = sourceQuote.invoicesArray
                    let idsToRestore = invoice.deductedInvoiceIDs as? [UUID] ?? []
                    self.deductedInvoices = Set(allInvoices.filter { inv in
                        guard let id = inv.id else { return false }
                        return idsToRestore.contains(id)
                    })
                }
            }

            self.documentNumber = invoice.invoiceNumber ?? "FAC-???"
            // 🗓️ Ne modifie pas la date existante automatiquement
            if let existingDate = invoice.date {
                self.quoteDate = existingDate
            } else {
                self.quoteDate = Date()
                invoice.date = self.quoteDate
                try? viewContext.save()
            }
            
        }
        .popover(isPresented: $showingArticleSelection) {
            NavigationView {
                ArticleSelectionView { article, quantity in
                    let newQA = QuoteArticle(
                        id: UUID(),
                        designation: article.name ?? "",
                        quantity: 1, // ou Int(article.quantity) si stocké dans CoreData
                        unit: article.unit ?? "",
                        unitPrice: (article.price as? NSNumber)?.doubleValue ?? 0.0
                    )
                    quoteArticles.append(newQA)
                }
                .environment(\.managedObjectContext, viewContext)
                .toolbar(content: articleToolbar)
            }
            .frame(width: 400, height: 600)
        }
    }
    @ToolbarContentBuilder
    private func articleToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Fermer") {
                showingArticleSelection = false
            }
        }
    }
    func saveInvoice() {
        // 🧾 Infos générales
        invoice.projectName = projectName
        invoice.invoiceNumber = documentNumber
        invoice.clientStreet = clientStreet
        invoice.clientPostalCode = clientPostalCode
        invoice.clientCity = clientCity
        invoice.clientProjectAddress = clientProjectAddress
        invoice.date = quoteDate

        // 🧾 Articles actuels
        invoice.invoiceArticlesData = try? JSONEncoder().encode(quoteArticles)
        //factures déja émises sélectionnées
        if invoice.invoiceTypeEnum == .finale {
            let ids = deductedInvoices.compactMap { $0.id }
            invoice.deductedInvoiceIDs = ids as NSArray
        }
        // 🔢 Remise (copiée uniquement si finale)
        if invoice.invoiceTypeEnum == .finale {
            invoice.remiseAmount = remiseAmount
            invoice.remiseIsPercentage = remiseIsPercentage
            invoice.remiseValue = remiseValue
        }

        // 💶 Calcul des totaux
        if invoice.invoiceTypeEnum == .finale {
            // 👉 Total HT = total des lignes article
            let totalHT = quoteArticles
                .filter { $0.lineType == .article }
                .map { Double($0.quantity) * ($0.unitPrice ?? 0.0) }
                .reduce(0, +)
            invoice.totalHT = totalHT

            // 👉 Remise
            let remise = invoice.remiseIsPercentage
                ? totalHT * invoice.remiseValue / 100
                : invoice.remiseAmount

            // 👉 TVA & TTC
            let htAfterRemise = totalHT - remise
            invoice.tva = invoice.companyIsAutoEntrepreneur ? 0 : htAfterRemise * 0.2
            invoice.totalTTC = htAfterRemise + invoice.tva

        } else {
            // ✅ Pour acompte / intermédiaire : utiliser partialAmount
            invoice.totalHT = invoice.partialAmount
            invoice.tva = invoice.companyIsAutoEntrepreneur ? 0 : invoice.totalHT * 0.2
            invoice.totalTTC = invoice.totalHT + invoice.tva
        }

        // 💾 Sauvegarde Core Data
        do {
            try viewContext.save()
            print("✅ Facture enregistrée")
        } catch {
            print("❌ Erreur lors de l’enregistrement : \(error)")
        }
    }

    func computeTotalHT() -> Double {
        let totalSansRemise = quoteArticles.reduce(0) { $0 + $1.totalHT }
        return totalSansRemise - remiseAmount
    }
    private func loadQuoteData(from quote: QuoteEntity) {
        projectName = quote.projectName ?? ""
        documentNumber = invoice.invoiceNumber ?? generateNewInvoiceNumber()
        devisNumber = quote.devisNumber ?? ""

        sousTotal = quote.sousTotal
        remiseAmount = quote.remiseAmount
        remiseIsPercentage = quote.remiseIsPercentage
        remiseValue = quote.remiseValue
        acompteText = quote.acompteText ?? ""
        acomptePercentage = quote.acomptePercentage
        acompteLabel = quote.acompteLabel ?? "Acompte à la signature de"
        showAcompteLine = quote.showAcompteLine
        soldeText = quote.soldeText ?? ""
        soldePercentage = quote.soldePercentage
        soldeLabel = quote.soldeLabel ?? "Solde à la réception du chantier de"
        showSoldeLine = quote.showSoldeLine

        clientStreet = quote.clientStreet ?? ""
        clientPostalCode = quote.clientPostalCode ?? ""
        clientCity = quote.clientCity ?? ""
        clientProjectAddress = quote.clientProjectAddress ?? ""

        let tmpClient = Contact(entity: Contact.entity(), insertInto: nil)
        tmpClient.civility = quote.clientCivility
        tmpClient.firstName = quote.clientFirstName
        tmpClient.lastName = quote.clientLastName
        tmpClient.street = quote.clientStreet
        tmpClient.postalCode = quote.clientPostalCode
        tmpClient.city = quote.clientCity
        selectedClient = tmpClient

        if let data = quote.quoteArticlesData,
           let decoded = try? JSONDecoder().decode([QuoteArticle].self, from: data) {
            quoteArticles = decoded
        }
        

//        print("📦 Facture chargée pour devis \(devisNumber)")
//        print("📄 Articles : \(quoteArticles.count)")
//        print("👤 Client : \(tmpClient.fullName)")
//        print("🧾 Numéro facture : \(documentNumber)")
    }

    func generateNewInvoiceNumber() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let datePart = dateFormatter.string(from: Date())
        let randomPart = Int.random(in: 100...999)
        return "FAC-\(datePart)-\(randomPart)"
    }
    func exportPDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]

        let fullName = [
            invoice.quote?.clientFirstName ?? "",
            invoice.quote?.clientLastName ?? ""
        ].filter { !$0.isEmpty }.joined(separator: " ")

        let number = invoice.invoiceNumber ?? "FACTURE-???"
        panel.nameFieldStringValue = "\(fullName)-\(number).pdf"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    ensureSignatureBlockFits()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        renderA4SheetToPDF(saveURL: url)
                    }
                }
            }
        }
    }

    func previewPDF() {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("PreviewInvoice.pdf")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ensureSignatureBlockFits() // ✅ Ajout ici
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                renderA4SheetToPDF(saveURL: tmpURL)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSWorkspace.shared.open(tmpURL)
            }
        }
    }
    func ensureSignatureBlockFits() {
        guard signatureBlockHeight > 0 else {
            print("⚠️ signatureBlockHeight pas encore mesuré")
            return
        }

        let pageHeight: CGFloat = 842
        let headerHeight: CGFloat = 270
        let articleRowHeight: CGFloat = 22
        let footerHeight: CGFloat = 80
        let padding: CGFloat = 32

        let totalArticleHeight = CGFloat(quoteArticles.count) * articleRowHeight
        let totalBeforeSignatures = headerHeight + totalArticleHeight
        let spaceRemaining = pageHeight - (totalBeforeSignatures.truncatingRemainder(dividingBy: pageHeight))

        let totalSignatureAndFooter = signatureBlockHeight + footerHeight + padding

        print("🧮 Espace restant: \(spaceRemaining) — Signature+footer: \(totalSignatureAndFooter)")

        let lastLines = quoteArticles.suffix(3)
        let hasBreakNearEnd = lastLines.contains(where: { $0.lineType == .pageBreak })

        let lastCategoryIndex = quoteArticles.lastIndex(where: { $0.lineType == .category })
        let hasBreakBeforeLastCategory = lastCategoryIndex != nil
            && lastCategoryIndex! > 0
            && quoteArticles[lastCategoryIndex! - 1].lineType == .pageBreak

        if spaceRemaining < totalSignatureAndFooter {
            if hasBreakNearEnd || hasBreakBeforeLastCategory {
                print("✅ Un .pageBreak est déjà présent")
                return
            }

            print("🚨 Pas assez de place, ajout d’un .pageBreak")

            if let lastCat = lastCategoryIndex {
                let insertAt = max(lastCat, 0)
                quoteArticles.insert(QuoteArticle(lineType: .pageBreak), at: insertAt)
                print("📌 .pageBreak ajouté avant la dernière catégorie (ligne \(insertAt))")
            } else {
                let insertAt = max(quoteArticles.count - 1, 0)
                quoteArticles.insert(QuoteArticle(lineType: .pageBreak), at: insertAt)
                print("📌 .pageBreak ajouté juste avant la fin (ligne \(insertAt))")
            }
        } else {
            print("✅ Assez de place, pas besoin de pageBreak")
        }
    }
    func renderA4SheetToPDF(saveURL: URL) {
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        ensureSignatureBlockFits()

        // 1. Découper les articles par .pageBreak
        var pages: [[QuoteArticle]] = []
        var currentPage: [QuoteArticle] = []

        for article in quoteArticles {
            if article.lineType == .pageBreak {
                pages.append(currentPage)
                currentPage = []
            } else {
                currentPage.append(article)
            }
        }
        if !currentPage.isEmpty {
            pages.append(currentPage)
        }

        var temporaryPDFs: [URL] = []

        for (index, pageArticles) in pages.enumerated() {
            let isFirstPage = index == 0
            let isLastPage = index == pages.count - 1

            let view = A4SheetView(
                showHeader: isFirstPage,             // ✅ Header uniquement première page
                showFooter: true,                    // ✅ Footer toujours
                showSignature: isLastPage,           // ✅ Signature uniquement dernière page
                globalQuoteArticles: quoteArticles,
                isInvoice: true,
                invoiceType: invoice.invoiceTypeEnum,
                invoice: invoice,
                sourceQuote: sourceQuote,
                deductedInvoices: $deductedInvoices,
                selectedClient: $selectedClient,
                quoteArticles: .constant(pageArticles),
                clientProjectAddress: $clientProjectAddress,
                projectName: $projectName,
                companyInfo: $companyInfo,
                clientStreet: $clientStreet,
                clientPostalCode: $clientPostalCode,
                clientCity: $clientCity,
                showingClientSelection: .constant(false),
                showingArticleSelection: .constant(false),
                devisNumber: $devisNumber,
                documentNumber: $documentNumber,
                signatureBlockHeight: $signatureBlockHeight,
                sousTotal: $sousTotal,
                remiseAmount: $remiseAmount,
                remiseIsPercentage: $remiseIsPercentage,
                remiseValue: $remiseValue,
                acompteText: $acompteText,
                soldeText: $soldeText,
                acomptePercentage: $acomptePercentage,
                soldePercentage: $soldePercentage,
                showSoldeLine: $showSoldeLine,
                showAcompteLine: $showAcompteLine,
                acompteLabel: $acompteLabel,
                soldeLabel: $soldeLabel,
                quoteDate: $quoteDate
            )
            .environment(\.isPrinting, true)
            .frame(width: pageWidth, height: pageHeight)

            let hostingView = NSHostingView(rootView: view)
            hostingView.frame = NSRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("invoice_page_\(index).pdf")

            let printInfo = NSPrintInfo()
            printInfo.paperSize = NSSize(width: pageWidth, height: pageHeight)
            printInfo.topMargin = 0
            printInfo.bottomMargin = 0
            printInfo.leftMargin = 0
            printInfo.rightMargin = 0
            printInfo.horizontalPagination = .fit
            printInfo.verticalPagination = .fit
            printInfo.isHorizontallyCentered = false
            printInfo.isVerticallyCentered = false
            printInfo.jobDisposition = .save
            printInfo.dictionary()[NSPrintInfo.AttributeKey("NSJobSavingURL")] = tmpURL as NSURL

            let printOperation = NSPrintOperation(view: hostingView, printInfo: printInfo)
            printOperation.showsPrintPanel = false
            printOperation.showsProgressPanel = false
            printOperation.run()

            temporaryPDFs.append(tmpURL)
        }

        let finalDocument = PDFDocument()
        for (i, url) in temporaryPDFs.enumerated() {
            if let doc = PDFDocument(url: url), let page = doc.page(at: 0) {
                finalDocument.insert(page, at: i)
            }
        }

        finalDocument.write(to: saveURL)
        print("✅ PDF de la facture exporté à : \(saveURL.path)")
    }
}
//extension QuoteArticle {
//    var totalHT: Double {
//        Double(quantity) * unitPrice
//    }
//}
