import SwiftUI
import PDFKit
import AppKit
import UniformTypeIdentifiers
import CoreData
import Foundation

struct NewQuoteView: View {
    @Binding var selectedTab: String // ⬅️ Ajout ici
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @State private var quoteDate: Date = Date()
    @State private var acompteLabel: String = "Acompte à la signature de"
    @State private var soldeLabel: String = "Solde à la réception du chantier de"
    @State private var showingProjectNameSheet = false
    @State private var tempProjectName = ""
    @State private var hasLoadedQuote = false
    @State private var acompteText: String = ""
    @State private var soldeText: String = ""
    @State private var documentNumber: String = ""
    @State private var acomptePercentage: Double = 30
    @State private var soldePercentage: Double = 70
    @State private var showAcompteLine: Bool = false
    @State private var showSoldeLine: Bool = false
    @State private var receivedQuoteToEdit: QuoteEntity? = nil
    @State private var companyInfo: CompanyInfo = CompanyInfo.loadFromUserDefaults()
    @State private var selectedClient: Contact?
    @State private var clientStreet: String = ""
    @State private var clientPostalCode: String = ""
    @State private var clientCity: String = ""
    @State private var deductedInvoices: Set<Invoice> = []
    @State private var quoteArticles: [QuoteArticle] = [] {
        didSet {
            print("🧩 [didSet] quoteArticles a été mis à jour.")
            for q in quoteArticles {
                print("➡️ \(q.id) — \(q.designation) — \(q.quantity) — \(q.unitPrice)")
            }
        }
    }
    
    private func debugQuoteArticles() {
        print("🧪 DEBUG depuis NewQuoteView :")
        for (index, article) in quoteArticles.enumerated() {
            print("- [\(index)] \(article.designation) | Qté: \(article.quantity) | PU: \(article.unitPrice)")
        }
    }

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
    @State private var signatureBlockHeight: CGFloat = 0
    let existingQuote: QuoteEntity?

    init(existingQuote: QuoteEntity? = nil, selectedTab: Binding<String>? = nil) {
        self.existingQuote = existingQuote
        _companyInfo = State(initialValue: CompanyInfo.loadFromUserDefaults())
        
        if let selectedTab = selectedTab {
            _selectedTab = selectedTab
        } else {
            _selectedTab = .constant("")
        }
    }
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Button(action: exportPDF) {
                    Label("Export PDF", systemImage: "square.and.arrow.up")
                        .padding(6)
//                        .background(Color.blue.opacity(0.2))
//                        .foregroundColor(.blue)
//                        .cornerRadius(6)
                }
                .buttonStyle(DefaultButtonStyle()) // ou PlainButtonStyle si besoin
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(6)
                .help("Export PDF")

                Button(action: previewPDF) {
                    Label("Prévisualiser", systemImage: "eye.circle")
                        .padding(6)
//                        .background(Color.blue.opacity(0.2))
//                        .foregroundColor(.blue)
//                        .cornerRadius(6)
                }
                .buttonStyle(DefaultButtonStyle()) // ou PlainButtonStyle si besoin
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(6)
                .help("Prévisualisation PDF")

                Button(action: {
                    if clientProjectAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        clientProjectAddress = "\(clientStreet)\n\(clientPostalCode) \(clientCity)"
                    }
                    print("💬 clientProjectAddress: \(clientProjectAddress)")
                    saveQuoteToCoreData(
                        context: context,
                        quoteArticles: quoteArticles,
                        clientCivility: selectedClient?.civility ?? "",
                        clientProjectAddress: clientProjectAddress,
                        clientFirstName: selectedClient?.firstName ?? "",
                        clientLastName: selectedClient?.lastName ?? "",
                        projectName: projectName,
                        sousTotal: sousTotal,
                        remiseAmount: remiseAmount,
                        remiseIsPercentage: remiseIsPercentage,
                        remiseValue: remiseValue,
                        devisNumber: devisNumber,
                        clientStreet: clientStreet,
                        clientPostalCode: clientPostalCode,
                        clientCity: clientCity,
                        quoteDate: quoteDate
                    )
                    selectedTab = "devisFactures"
                }) {
                    Label("Enregistrer", systemImage: "externaldrive.fill.badge.checkmark")
                        .padding(6)
//                        .background(Color.green.opacity(0.2))
//                        .foregroundColor(.green)
//                        .cornerRadius(6)
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

            ZStack {
                Color.gray.opacity(0.2).ignoresSafeArea()

                GeometryReader { geo in
                    if #available(macOS 13, *) {
                        let scaleFactor = geo.size.height / 842
                        let scaledWidth = 595 * scaleFactor

                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                A4SheetView(
                                    showHeader: true,
                                    showFooter: true,
                                    showSignature: true,
                                    globalQuoteArticles: quoteArticles,
                                    isInvoice: false,
                                    invoiceType: nil,
                                    invoice: nil,
                                    sourceQuote: nil,
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
                    } else {
                        // macOS 12 et en dessous – pas de scaleEffect, ni de position(), car crash potentiel
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                A4SheetView(
                                    showHeader: true,
                                    showFooter: true,
                                    showSignature: true,
                                    globalQuoteArticles: quoteArticles,
                                    isInvoice: false,
                                    invoiceType: nil,
                                    invoice: nil,
                                    sourceQuote: nil,
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
                                .frame(width: 595, height: documentHeight)
                            }
                            .frame(width: 595, height: max(documentHeight, 842), alignment: .top)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .padding()
                    }
                }
  
            }
            
//            .sheet(isPresented: $showingArticleSelection) {
//                Text("Test Sheet")
//            }

//            .alert(isPresented: $showingProjectNameAlert) {
//                Alert(
//                    title: Text("Nom du projet"),
//                    message: Text("Veuillez saisir le nom du projet."),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//            .onAppear {
//                if let quote = existingQuote, !hasLoadedQuote {
//                    print("📦 Chargement du devis existant depuis onAppear")
//                    hasLoadedQuote = true
//                    loadQuote(from: quote)
//                }
//
//                if existingQuote == nil && projectName.isEmpty {
//                    showingProjectNameAlert = true
//                }
//                
//            }
            .onAppear {
                if let quote = existingQuote, !hasLoadedQuote {
                    hasLoadedQuote = true
                    DispatchQueue.main.async {
                        loadQuote(from: quote)
                    }
                }

                // ✅ Si c’est un nouveau devis : on construit l’adresse une fois
                if existingQuote == nil && clientProjectAddress.isEmpty,
                   !clientStreet.isEmpty || !clientPostalCode.isEmpty || !clientCity.isEmpty {
                    clientProjectAddress = "\(clientStreet)\n\(clientPostalCode) \(clientCity)"
                }

                // ✅ Ou si nom du chantier manquant
                if existingQuote == nil && projectName.isEmpty {
                    DispatchQueue.main.async {
                        tempProjectName = projectName
                        showingProjectNameSheet = true
                    }
                }
            }

        }
        .onChange(of: selectedClient) { newClient in
            guard let client = newClient else { return }

            // Met à jour les champs individuels
            clientStreet = client.street ?? ""
            clientPostalCode = client.postalCode ?? ""
            clientCity = client.city ?? ""

            // 🔁 Force la mise à jour pour que SwiftUI considère que le champ a "changé"
            clientProjectAddress = "\(clientStreet)\n\(clientPostalCode) \(clientCity)"
        }
        .popover(isPresented: $showingClientSelection) {
            ClientSelectionWrapper(
                selectedClient: $selectedClient,
                clientProjectAddress: $clientProjectAddress,
                showingClientSelection: $showingClientSelection
            )
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
        .sheet(isPresented: $showingProjectNameSheet) {
            VStack(spacing: 20) {
                Text("Nom du projet")
                    .font(.title2)
                    .bold()

                TextField("Nom du projet", text: $tempProjectName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)

                HStack {
                    Button("Annuler") {
                        showingProjectNameSheet = false
                    }

                    Spacer()

                    Button("Valider") {
                        if !tempProjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            projectName = tempProjectName
                        }
                        showingProjectNameSheet = false
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding(.horizontal)
            }
            .padding()
            .frame(width: 400)
        }
    }
    
    
    @ViewBuilder
    private func renderSheetView() -> some View {
        let acompteTextBinding = $acompteText
        let soldeTextBinding = $soldeText
        let acomptePercentageBinding = $acomptePercentage
        let soldePercentageBinding = $soldePercentage
        let showAcompteLineBinding = $showAcompteLine
        let showSoldeLineBinding = $showSoldeLine

        A4SheetView(
            showHeader: true,
            showFooter: true,
            showSignature: true,
            globalQuoteArticles: quoteArticles,
            isInvoice: false,
            invoiceType: nil,
            invoice: nil,
            sourceQuote: nil,
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
    }
    @ToolbarContentBuilder
    private func articleToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Fermer") {
                showingArticleSelection = false
            }
        }
    }
    func exportPDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]

        let fullName = [
            selectedClient?.firstName ?? "",
            selectedClient?.lastName ?? ""
        ].filter { !$0.isEmpty }.joined(separator: " ")

        let number = devisNumber.isEmpty ? "DEV-???" : devisNumber
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
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("PreviewQuote.pdf")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ensureSignatureBlockFits()
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

        // Vérifie si un .pageBreak est déjà dans les 3 dernières lignes
        let lastLines = quoteArticles.suffix(3)
        let hasBreakNearEnd = lastLines.contains(where: { $0.lineType == .pageBreak })

        // Vérifie si un .pageBreak existe juste avant la dernière catégorie
        let lastCategoryIndex = quoteArticles.lastIndex(where: { $0.lineType == .category })
        let hasBreakBeforeLastCategory = lastCategoryIndex != nil
            && lastCategoryIndex! > 0
            && quoteArticles[lastCategoryIndex! - 1].lineType == .pageBreak

        if spaceRemaining < totalSignatureAndFooter {
            if hasBreakNearEnd || hasBreakBeforeLastCategory {
                print("✅ Un .pageBreak est déjà présent (en fin ou avant dernière catégorie)")
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
        let showAcompte = !acompteText.isEmpty
        let showSolde = !soldeText.isEmpty

        ensureSignatureBlockFits()

        // 1. Découper par .pageBreak
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
                isInvoice: false,
                invoiceType: nil,
                invoice: nil,
                sourceQuote: nil,
                deductedInvoices: $deductedInvoices,
                selectedClient: $selectedClient,
                quoteArticles: .constant(pageArticles),
               // quoteArticles: $quoteArticles,
                clientProjectAddress: $clientProjectAddress,
                projectName: $projectName,
                companyInfo: $companyInfo,
                clientStreet: $clientStreet,
                clientPostalCode: $clientPostalCode,
                clientCity: $clientCity,
                showingClientSelection: $showingClientSelection,
                showingArticleSelection: $showingArticleSelection,
                devisNumber: .constant(""), // ← AJOUT ICI
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

            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("page_\(index).pdf")

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
        print("✅ PDF final exporté à : \(saveURL.path)")
    }
    
    func saveQuoteToCoreData(
        context: NSManagedObjectContext,
        quoteArticles: [QuoteArticle],
        clientCivility: String,
        clientProjectAddress: String,
        clientFirstName: String,
        clientLastName: String,
        projectName: String,
        sousTotal: Double,
        remiseAmount: Double,
        remiseIsPercentage: Bool,
        remiseValue: Double,
        devisNumber: String,
        clientStreet: String,
        clientPostalCode: String,
        clientCity: String,
        quoteDate: Date
    ) {
        let fetchRequest: NSFetchRequest<QuoteEntity> = QuoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "devisNumber == %@", devisNumber)

        do {
            let results = try context.fetch(fetchRequest)
            let quoteToUpdate: QuoteEntity
            let isNewQuote: Bool

            if let existingQuote = existingQuote {
                quoteToUpdate = existingQuote
                isNewQuote = false
            } else if let found = results.first {
                quoteToUpdate = found
                isNewQuote = false
            } else {
                quoteToUpdate = QuoteEntity(context: context)
                quoteToUpdate.id = UUID()
                quoteToUpdate.date = quoteDate
                isNewQuote = true
            }

            quoteToUpdate.clientCivility = clientCivility
            quoteToUpdate.clientFirstName = clientFirstName
            quoteToUpdate.clientLastName = clientLastName
            quoteToUpdate.clientProjectAddress = clientProjectAddress
            quoteToUpdate.clientStreet = clientStreet
            quoteToUpdate.clientPostalCode = clientPostalCode
            quoteToUpdate.clientCity = clientCity
            quoteToUpdate.projectName = projectName

            quoteToUpdate.quoteArticlesData = try? JSONEncoder().encode(quoteArticles)
            quoteToUpdate.sousTotal = sousTotal
            quoteToUpdate.remiseAmount = remiseAmount
            quoteToUpdate.remiseIsPercentage = remiseIsPercentage
            quoteToUpdate.remiseValue = remiseValue
            quoteToUpdate.devisNumber = devisNumber

            quoteToUpdate.acompteText = acompteText
            quoteToUpdate.acomptePercentage = acomptePercentage
            quoteToUpdate.acompteLabel = acompteLabel
            quoteToUpdate.showAcompteLine = showAcompteLine
            quoteToUpdate.soldeText = soldeText
            quoteToUpdate.soldePercentage = soldePercentage
            quoteToUpdate.soldeLabel = soldeLabel
            quoteToUpdate.showSoldeLine = showSoldeLine
            quoteToUpdate.date = quoteDate

            // Données de contact facultatives
            if let phone = selectedClient?.phoneNumber, !phone.isEmpty {
                quoteToUpdate.clientPhone = phone
            }
            if let email = selectedClient?.email, !email.isEmpty {
                quoteToUpdate.clientEmail = email
            }

            try context.save()
            print("✅ Devis \(isNewQuote ? "créé" : "mis à jour")")
        } catch {
            print("❌ Erreur lors de la sauvegarde : \(error)")
        }
    }
    func loadQuote(from quote: QuoteEntity) {
        projectName = quote.projectName ?? ""
        devisNumber = quote.devisNumber ?? ""
        sousTotal = quote.sousTotal
        remiseAmount = quote.remiseAmount
        remiseIsPercentage = quote.remiseIsPercentage
        remiseValue = quote.remiseValue
        acompteText = quote.acompteText ?? ""
        acomptePercentage = quote.acomptePercentage
        acompteLabel = quote.acompteLabel ?? "Acompte à la signature de"
        showAcompteLine = quote.showAcompteLine
        clientStreet = quote.clientStreet ?? ""
        clientPostalCode = quote.clientPostalCode ?? ""
        clientCity = quote.clientCity ?? ""
        soldeText = quote.soldeText ?? ""
        soldePercentage = quote.soldePercentage
        soldeLabel = quote.soldeLabel ?? "Solde à la réception du chantier de"
        showSoldeLine = quote.showSoldeLine
        quoteDate = quote.date ?? Date()
        
        // Mise à jour de l'adresse projet
        clientProjectAddress = "\(quote.clientStreet ?? "")\n\(quote.clientPostalCode ?? "") \(quote.clientCity ?? "")"
        
        if let data = quote.quoteArticlesData,
           let articles = try? JSONDecoder().decode([QuoteArticle].self, from: data) {
            quoteArticles = articles
        }

        // Création d’un Contact temporaire pour affichage (hors Core Data)
        let temporaryClient = Contact(entity: Contact.entity(), insertInto: nil)
        temporaryClient.civility = quote.clientCivility // C'est ça qui manquait
        temporaryClient.firstName = quote.clientFirstName
        temporaryClient.lastName = quote.clientLastName
        temporaryClient.street = quote.clientStreet
        temporaryClient.postalCode = quote.clientPostalCode
        temporaryClient.city = quote.clientCity
        selectedClient = temporaryClient
        clientProjectAddress = "\(clientStreet)\n\(clientPostalCode) \(clientCity)"        // Pas besoin de mettre à jour l'adresse ici à nouveau, c'est déjà fait ci-dessus
    }

}
struct ClientSelectionWrapper: View {
    @Binding var selectedClient: Contact?
    @Binding var clientProjectAddress: String
    @Binding var showingClientSelection: Bool
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            ClientSelectionView(
                onClientSelected: {
                    showingClientSelection = false // ✅ ferme la popover dès sélection
                },
                selectedClient: $selectedClient,
                clientProjectAddress: $clientProjectAddress
            )
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
    }
}
extension Notification.Name {
    static let editQuote = Notification.Name("editQuote")
}
extension Contact {
    var fullName: String {
        let civ = civility ?? ""
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(civ) \(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}
func generateNewQuoteNumber() -> String {
    // Exemple basique : format "DV-20250401-001"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    let datePart = dateFormatter.string(from: Date())
    
    let randomPart = Int.random(in: 100...999)
    return "DV-\(datePart)-\(randomPart)"
}
