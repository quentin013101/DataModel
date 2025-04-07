import SwiftUI
import AppKit
import PDFKit
import CoreData



struct A4SheetView: View {
    let showHeader: Bool
    let showFooter: Bool
    let showSignature: Bool
    let globalQuoteArticles: [QuoteArticle]
    
    // let companyInfo: CompanyInfo
    
    @Binding var selectedClient: Contact?
    @Binding var quoteArticles: [QuoteArticle]
    @Binding var clientProjectAddress: String
    @Binding var projectName: String
    @Binding var companyInfo: CompanyInfo
    
    @Binding var showingClientSelection: Bool
    @Binding var showingArticleSelection: Bool
    @Binding var devisNumber: String
    @State private var isShowingRemisePopup = false
    
    @State private var arrowIndex: Int? = nil
    @State private var highlightIndex: Int? = nil
    @Binding var signatureBlockHeight: CGFloat
    // @State private var sousTotal: Double = 0.0
   // @State private var remiseAmount: Double = 0.0
   // @State private var remiseIsPercentage: Bool = false
   // @State private var remiseValue: Double = 0.0
    @State private var remiseLabel: String = "Remise"
    @Binding var sousTotal: Double
    @Binding var remiseAmount: Double
    @Binding var remiseIsPercentage: Bool
    @Binding var remiseValue: Double
    @State private var showingAcomptePopover = false
    @State private var showingSoldePopover = false
    @State private var acompteLabelDraft: String = ""
    @State private var soldeLabelDraft: String = ""
    @Binding var acompteText: String
    @Binding var soldeText: String
    @Binding var acomptePercentage: Double
    @Binding var soldePercentage: Double
    @State private var showAcompteTrash = false
    @State private var showSoldeTrash = false
    @Binding var showSoldeLine: Bool
    @Binding var showAcompteLine: Bool
    @State private var acompteTextDraft: String = ""
    @State private var soldeTextDraft: String = ""
    @State private var acomptePercentageDraft: Double = 30
    @State private var soldePercentageDraft: Double = 70
    @State private var soldeAmount: Double = 0.0
    @Binding var acompteLabel: String
    @Binding var soldeLabel: String

    
    

    @Environment(\.isPrinting) private var isPrinting
    


    
    private func computeCategoryTotal(startIndex: Int) -> Double {
        let isAuto = companyInfo.legalForm.lowercased().contains("auto")
        var sum: Double = 0
        
        let nextCatIndex = findNextCategoryIndex(after: startIndex)

        for i in (startIndex+1) ..< nextCatIndex {
            let line = quoteArticles[i]
            if line.lineType == .article {
                let price = line.unitPrice ?? 0.0
                let tvaRate = isAuto ? 0.0 : 0.20
                sum += Double(line.quantity) * price * (1 + tvaRate)
            }
        }
        return sum // ✅ Ajout du return pour éviter l'erreur
    }
    private func findNextCategoryIndex(after idx: Int) -> Int {
        var i = idx + 1
        while i < quoteArticles.count {
            if quoteArticles[i].lineType == .category {
                return i
            }
            i += 1
        }
        return quoteArticles.count
    }
    private var netAPayer: Double {
        let total = sousTotal
        let remise = remiseIsPercentage ? (total * remiseValue / 100) : remiseValue
        return total - remise
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            if showHeader {
                headerSection

            }
            projectNameField
            articlesSection
            
            if showSignature {
                VStack(spacing: 0) {
                    signatureSection
                        .padding(.top, 16)

                    clientProSignatureSection
                        .padding(.top, 16)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                signatureBlockHeight = geo.size.height
                                print("📏 Signature block height: \(signatureBlockHeight)")
                            }
                            .onChange(of: geo.size.height) { newHeight in
                                signatureBlockHeight = newHeight
                            }
                    }
                )
            }
            
            Spacer(minLength: 0)
                .layoutPriority(-1)
            
            if showFooter {
            
                footerSection

            
            }
        }
        .font(.system(size: 9))
        .frame(width: 595, alignment: .top)
        .background(Color.white)
       // .background(Color.red) // temporaire
        .environment(\.colorScheme, .light)
        .animation(.default, value: highlightIndex)
        .onChange(of: quoteArticles) { new in
            print("📄 A4SheetView a reçu une modification :")
            for q in new {
                print("- \(q.designation) — \(q.quantity) — \(q.unitPrice)")
            }
            // ⬇️ AJOUTE CECI
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                print("🧪 [retardé] Contenu réel de quoteArticles (vérif après édition) :")
                for (i, article) in quoteArticles.enumerated() {
                    print("➡️ [\(i)] \(article.id) — \(article.designation)")
                }
            }
            
        }
        .onChange(of: acompteLabel) { _ in
            acompteText = "\(acompteLabel) \(Int(acomptePercentage)) %, soit \(String(format: "%.2f", netAPayer * acomptePercentage / 100)) €"
        }
        .onChange(of: acomptePercentage) { _ in
            acompteText = "\(acompteLabel) \(Int(acomptePercentage)) %, soit \(String(format: "%.2f", netAPayer * acomptePercentage / 100)) €"
        }
        .onChange(of: soldeLabel) { _ in
            soldeText = "\(soldeLabel) \(Int(soldePercentage)) %, soit \(String(format: "%.2f", netAPayer * soldePercentage / 100)) €"
        }
        .onChange(of: soldePercentage) { _ in
            soldeText = "\(soldeLabel) \(Int(soldePercentage)) %, soit \(String(format: "%.2f", netAPayer * soldePercentage / 100)) €"
        }
    }
    
    // MARK: - 1) Header
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                if let logoData = companyInfo.logoData,
                   let nsImage = NSImage(data: logoData) {
                    LogoImageView(imageData: companyInfo.logoData, size: CGSize(width: 100, height: 100))
                        .frame(width: 100, height: 100)
                }  else {
                    Text(companyInfo.companyName)
                        .font(.title2)
                        .bold()
                }
                Text(companyInfo.addressLine1)
                Text(companyInfo.addressLine2)
                Text(companyInfo.phone)
                Text(companyInfo.email)
            }
            .padding(.leading, 16)
            
            Spacer(minLength: 180)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Devis N° \(devisNumber)") // 🔹 Numéro unique généré
                    .font(.headline)
                    .padding(.top, 16)
                
                Text("En date du \(formattedToday)")
                    .font(.system(size: 10))
                Text("Valable 3 mois")
                    .font(.subheadline)
                    .padding(.bottom, 10)
                
                ZStack(alignment: .topLeading) {
                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.5), cornerRadius: 8)
                        .frame(width: 260, height: 80)
                    if let client = selectedClient {
                        VStack(alignment: .leading, spacing: 6) {
                            let civ = client.civility ?? "M."
                            let nomMaj = (client.lastName ?? "").uppercased()
                            let prenom = client.firstName ?? ""
                            
                            Text("\(civ) \(nomMaj) \(prenom)")
                                .font(.headline)
                                .onTapGesture {
                                    showingClientSelection = true
                                }
                            
                            TextEditor(text: $clientProjectAddress)
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                                .scrollDisabled(true)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 24)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        
                    } else {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                Button(action: {
                                    showingClientSelection = true
                                }) {
                                    Text("Sélectionner un client")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    if devisNumber.isEmpty {
                        generateUniqueDevisNumber()
                    } // 🔹 Génère le numéro au chargement
                }
                .frame(width: 260, height: 80)
                .clipped()
            }
            .padding(.trailing, 16)
        }
        .padding(.top, 16)
    }
    private func generateUniqueDevisNumber() {
        let today = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMM"
        let dateString = formatter.string(from: today) // 🔹 Format "2025-03-21"
        
        let key = "devisNumbers-\(dateString)" // 🔹 Clé unique par jour pour le compteur
        
        // 🔹 Charger les numéros de devis du jour
        let existingNumbers = UserDefaults.standard.stringArray(forKey: key) ?? []
        
        // 🔹 Déterminer le dernier numéro utilisé
        let lastNumber = existingNumbers
            .compactMap { Int($0.components(separatedBy: "-").last ?? "0") }
            .max() ?? 0

        // 🔹 Incrémenter le compteur du jour
        let newNumber = lastNumber + 1
        let formattedNumber = String(format: "%03d", newNumber) // Ex: "001"

        // 🔹 Générer le numéro final
        devisNumber = "DEV-\(dateString)-\(formattedNumber)"

        // 🔹 Sauvegarder pour éviter les doublons
        var updatedNumbers = existingNumbers
        updatedNumbers.append(devisNumber)
        UserDefaults.standard.set(updatedNumbers, forKey: key)
    }
    
    private var formattedToday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    // MARK: - 2) Nom du projet
    
    private var projectNameField: some View {
        Group {
            if !isPrinting {
                TextField("Nom du projet", text: $projectName)
                    .font(.system(size: 13).bold().italic())
            } else {
                Text(projectName) // ✅ Affiche le nom du projet en lecture seule lors de l'export
                    .font(.system(size: 13).bold().italic())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .padding(.top, 16)
    }
    
    // MARK: - 3) Articles
    
    private var articlesSection: some View {
        let tableWidth: CGFloat = 560

        return VStack(spacing: 0) {
            VStack(spacing: 0) {
                headerRow(width: tableWidth)

                if !quoteArticles.isEmpty {
                    ForEach(quoteArticles.indices, id: \.self) { i in
                        let binding = Binding<QuoteArticle>(
                            get: { quoteArticles[i] },
                            set: {
                                quoteArticles[i] = $0
                                print("✅ Modif appliquée à quoteArticles[\(i)] — \($0.designation)")
                            }
                        )

                        DevisLineRowHoverArrows(
                            quoteArticle: binding, // 👈 ça c’est la clé !
                            index: i,
                            computeLineNumber: lineNumber,
                            isHovering: arrowIndex == i,
                            highlight: highlightIndex == i,
                            isAutoEntrepreneur: companyInfo.legalForm.lowercased() == "auto-entrepreneur",
                            onHoverChanged: { hovering in
                                if hovering { arrowIndex = i } else if arrowIndex == i { arrowIndex = nil }
                            },
                            onMoveUp: { moveUp(i) },
                            onMoveDown: { moveDown(i) },
                            onInsertLineAboveCategory: { insertCategoryAbove(i) },
                            onInsertLineAbovePrestation: { insertPrestationAbove(i) },
                            onInsertPageBreakBelow: { insertPageBreakBelow(i) },
                            onInsertPageBreakAbove: { insertPageBreakAbove(i) },
                            onDelete: { confirmDelete(index: i) },
                            computeCategoryTotal: { _ in computeCategoryTotal(startIndex: i) }
                        )
                    }
                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(height: 1)
                }
            }
            .frame(width: tableWidth)

            if isPrinting {
                Spacer().frame(height: 40) // 🟢 Remplace les boutons à l’export
            } else {
                HStack(spacing: 16) {
                    Button("+ Prestation") {
                        showingArticleSelection = true
                    }
                    Button("Catégorie") {
                        addCategory()
                    }
                    Button("Saut de page") {
                        addPageBreak()
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    private func computeIndex(for article: QuoteArticle) -> Int {
        return quoteArticles.firstIndex(where: { $0.id == article.id }) ?? 0
    }
    /// N°(40) / Désignation(270) / Qté(50) / PU(70) / TVA(50) / Total(80)
    private func headerRow(width: CGFloat) -> some View {
        ZStack {
            PDFBoxView(backgroundColor: NSColor(calibratedRed: 106/255, green: 133/255, blue: 187/255, alpha: 1))
                .frame(width: width, height: 22)

            HStack(spacing: 0) {

                Text("N°")
                    .frame(width: 40, alignment: .center)

                PDFBoxView(backgroundColor: .white)
                    .frame(width: 1, height: 22)

                Text("Désignation")
                    .frame(width: 270, alignment: .center)

                PDFBoxView(backgroundColor: .white)
                    .frame(width: 1, height: 22)

                Text("Qté")
                    .frame(width: 50, alignment: .center)

                PDFBoxView(backgroundColor: .white)
                    .frame(width: 1, height: 22)

                Text("PU €")
                    .frame(width: 70, alignment: .center)

                PDFBoxView(backgroundColor: .white)
                    .frame(width: 1, height: 22)

                Text("TVA")
                    .frame(width: 50, alignment: .center)

                PDFBoxView(backgroundColor: .white)
                    .frame(width: 1, height: 22)

                Text("Total €")
                    .frame(width: 80, alignment: .center)

            }
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
          //  .background(Color.green) // autour du .frame(width: 560)
            .frame(width: width) // <== AJOUTE CETTE LIGNE


        }
        .frame(width: width, height: 22)

    }
    
    
    
    // MARK: - 5) Signature / net à payer
    
    private var signatureSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Paiement en espèces, par chèque ou par virement bancaire.")
                if showAcompteLine {
                    Group {
                        if isPrinting {
                            Text("\(acompteLabel) \(Int(acomptePercentage)) %, soit \(String(format: "%.2f", netAPayer * acomptePercentage / 100)) €")
                                .font(.system(size: 9))
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                // Label modifiable
                                TextField("", text: $acompteLabel)
                                    .font(.system(size: 9))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .fixedSize()

                                // Pourcentage
                                Text("\(Int(acomptePercentage)) %")
                                    .font(.system(size: 9))

                                // Montant
                                Text("soit \(String(format: "%.2f", netAPayer * acomptePercentage / 100)) €")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)

                                // Corbeille
                                if showAcompteTrash {
                                    Button {
                                        showAcompteLine = false
                                        acompteLabel = "Acompte à la signature de"
                                        acomptePercentage = 30
                                        acompteText = ""
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .onHover { hovering in
                                showAcompteTrash = hovering
                            }
                        }
                    }
                }
                
                if showSoldeLine {
                    Group {
                        if isPrinting {
                            Text("\(soldeLabel) \(Int(soldePercentage)) %, soit \(String(format: "%.2f", netAPayer * soldePercentage / 100)) €")
                                .font(.system(size: 9))
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {

                                // Label modifiable
                                TextField("", text: $soldeLabel)
                                    .font(.system(size: 9))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .fixedSize()

                                // Pourcentage
                                Text("\(Int(soldePercentage)) %")
                                    .font(.system(size: 9))

                                // Montant
                                Text("soit \(String(format: "%.2f", netAPayer * soldePercentage / 100)) €")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                
                                if showSoldeTrash {
                                    Button(action: {
                                        showSoldeLine = false
                                        soldeLabel = "Solde à la réception du chantier de"
                                        soldePercentage = 70
                                        soldeText = ""
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .onHover { hovering in
                                showSoldeTrash = hovering
                            }
                        }
                    }
                }
                Text("Le montant peut être révisé en fonction du temps réel passé sur le chantier et de l’ajustement des fournitures et/ou de leurs prix.")
                if companyInfo.legalForm.lowercased().contains("auto") {
                    Text("TVA non applicable, article 293 B du Code Général des Impôts.")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .trailing, spacing: 8) {
                if remiseAmount != 0 {
                    HStack {
                        Text("Sous-total :").font(.system(size: 10).bold())
                        Text(String(format: "%.2f €", sousTotal))
                            .font(.system(size: 10))
                    }
                    
                    HStack {
                        // 🔹 TextField pour modifier le mot "Remise"
                        TextField("Remise :", text: $remiseLabel)
                            .font(.system(size: 10).bold())
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        // Valeur de la remise
                        Text(remiseIsPercentage ? "\(remiseValue)%" : String(format: "%.2f €", remiseAmount))
                            .font(.system(size: 10))
                    }
                    .contextMenu {
                        Button("Supprimer la remise") {
                            remiseAmount = 0
                            remiseIsPercentage = false
                            remiseValue = 0
                            remiseLabel = "Remise" // Remet le texte par défaut
                        }
                    }
                }
                
                HStack {
                    Text("Net à payer : \(String(format: "%.2f €", computeTotal()))")
                        .bold()
                }
                .font(.system(size: 12))
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    PDFBoxView(backgroundColor: NSColor(calibratedRed: 106/255, green: 133/255, blue: 187/255, alpha: 1))
                )                .foregroundColor(.white)
                .cornerRadius(4)
                if !isPrinting {
                    Button("Remise") {
                        isShowingRemisePopup = true
                    }
                .sheet(isPresented: $isShowingRemisePopup) {
                    RemisePopupView(
                        isPresented: $isShowingRemisePopup,
                        totalBeforeDiscount: sousTotal,
                        onApply: { (remise: Double, isPercentage: Bool) in
                            remiseIsPercentage = isPercentage
                            remiseValue = remise
                            remiseAmount = isPercentage ? (sousTotal * remise / 100) : remise
                        }
                    )
                }
                }
                if !isPrinting {
                    Menu("Acompte") {
                        Button("Acompte à la signature") {
                            acompteTextDraft = acompteText
                            acomptePercentageDraft = acomptePercentage
                            acompteLabelDraft = acompteLabel // ✅ AJOUT ICI
                            showingAcomptePopover = true
                        }
                        Button("Solde à la réception") {
                            soldeTextDraft = soldeText
                            soldePercentageDraft = soldePercentage
                            soldeLabelDraft = soldeLabel // ✅ AJOUT ICI
                            showingSoldePopover = true
                        }
                    }
                    .padding(.top, 8)
                    .popover(isPresented: $showingAcomptePopover) {
                        VStack(alignment: .leading, spacing: 12) {
                            AcomptePopoverView(
                                title: "Acompte à la signature",
                                percentage: $acomptePercentageDraft,
                                netAPayer: netAPayer,
                                resultText: $acompteTextDraft
                            )

                            HStack {
                                Spacer()
                                Button("Annuler") {
                                    showingAcomptePopover = false
                                }
                                Button("Valider") {
                                    acompteText = acompteTextDraft
                                    acomptePercentage = acomptePercentageDraft
                                    acompteLabel = acompteLabelDraft
                                    showAcompteLine = true
                                    showingAcomptePopover = false
                                }
                                .keyboardShortcut(.defaultAction)
                            }
                        }
                        .padding()
                        .frame(width: 300)
                    }
                    .popover(isPresented: $showingSoldePopover) {
                        VStack(alignment: .leading, spacing: 12) {
                            AcomptePopoverView(
                                title: "Solde à la réception",
                                percentage: $soldePercentageDraft,
                                netAPayer: netAPayer,
                                resultText: $soldeTextDraft
                            )

                            HStack {
                                Spacer()
                                Button("Annuler") {
                                    showingSoldePopover = false
                                }
                                Button("Valider") {
                                    soldeText = soldeTextDraft
                                    soldePercentage = soldePercentageDraft
                                    soldeLabel = soldeLabelDraft
                                    showSoldeLine = true
                                    showingSoldePopover = false
                                }
                                .keyboardShortcut(.defaultAction)
                            }
                        }
                        .padding()
                        .frame(width: 300)
                    }
                }
            }
            //.padding()
            .frame(width: 200, alignment: .trailing)
            .padding()
            .onAppear {
                
               // computeTotal()
            }
            .frame(width: 200, alignment: .trailing)
            .padding(.top, -50)

        }
        .padding(.horizontal, 16)
    }
    
    struct EditableTextView: View {
        @Binding var text: String
        var body: some View {
            TextEditor(text: $text)
                .frame(height: 40)
                .contextMenu {
                    Button("Supprimer") {
                        text = ""
                    }
                }
        }
    }
    // Exemple de structure de ligne de devis – adaptez-la à votre modèle si besoin
    struct InvoiceLine: Identifiable {
        let id = UUID()
        var lineNumber: String? // Pour la ligne de remise, ce sera nil
        var designation: String
        var quantity: String?   // Vide pour la remise
        var unitPrice: String?  // Vide pour la remise
        var total: Double
    }
    
    func computeTotalBeforeDiscount() -> Double {
        return computeTotal()
    }
//    func addDiscountLine(discountAmount: Double) {
//       // let discountLine = QuoteArticle(discountAmount: discountAmount)
//       // quoteArticles.append(discountLine)
//    }
    
//    func recalcNetTotal() -> Double {
//       // let articlesTotal = computeTotal()  // total des articles
//       // let discountTotal = quoteArticles.filter { $0.lineType == .remise }
//        //    .reduce(0) { $0 + $1.total }
//       // return articlesTotal + discountTotal
//    }
    // MARK: - 6) Signatures client / pro
    
    private var clientProSignatureSection: some View {
        HStack(alignment: .top, spacing: 40) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Le Client")
                    .font(.system(size: 9).bold())
                ZStack(alignment: .topLeading) {
                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.5), cornerRadius: 8)
                        .frame(width: 240, height: 90)
                    Text("Mention manuscrite et datée :\n« Devis reçu avant l’exécution des travaux. Bon pour travaux. ")
                        .font(.system(size: 7))
                        .foregroundColor(.gray)
                        .padding(4)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text(companyInfo.companyName)
                    .font(.system(size: 9).bold())
                
                ZStack {
                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.5), cornerRadius: 8)
                        .frame(width: 240, height: 90)

                    if let signatureData = companyInfo.signatureData,
                       let nsImage = NSImage(data: signatureData) {
                        LogoImageView(imageData: companyInfo.signatureData, size: CGSize(width: 160, height: 80))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - 7) Footer
    
    private var footerSection: some View {
        VStack(spacing: 6) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            let isAuto = companyInfo.legalForm.lowercased().contains("auto")
            Text(isAuto ? "TVA non applicable (auto-entrepreneur)" : "TVA 20% ...")
                .font(.footnote)
            
            Text("Forme juridique : \(companyInfo.legalForm)")
                .font(.footnote)
            Text("SIRET : \(companyInfo.siret) — APE : \(companyInfo.apeCode)")
                .font(.footnote)
            Text("TVA : \(companyInfo.vatNumber) — IBAN : \(companyInfo.iban)")
                .font(.footnote)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Fonctions calcul
    private func computeTotal() -> Double {
        DispatchQueue.main.async {
            self.sousTotal = quoteArticles
                .filter { $0.lineType == .article }
                .map { Double($0.quantity) * ($0.unitPrice ?? 0.0) }
                .reduce(0, +)

            // ✅ Si la remise est en pourcentage, calculer la vraie valeur en €
            self.remiseAmount = remiseIsPercentage ? (sousTotal * remiseValue / 100) : remiseValue
        }
        return sousTotal - remiseAmount
    }
    func updateAcompteText() {
        let amount = netAPayer * acomptePercentage / 100
        if acompteText.isEmpty {
            acompteText = "Acompte à la signature de"
        }
        // Le texte reste intact, seul le montant change (affiché séparément)
    }

    func updateSoldeText() {
        let amount = netAPayer * soldePercentage / 100
        if soldeText.isEmpty {
            soldeText = "Solde à la réception du chantier de"
        }
    }

    // MARK: - Logique articles
    
//    private func lineNumber(for index: Int) -> String {
//        var categoryCount = 0
//        var noCategoryArticleCount = 0
//        var articleCountInCategory = 0
//        for i in 0...index {
//            let line = quoteArticles[i]
//            switch line.lineType {
//            case .category:
//                categoryCount += 1
//                articleCountInCategory = 0
//            case .article:
//                if categoryCount == 0 {
//                    noCategoryArticleCount += 1
//                } else {
//                    articleCountInCategory += 1
//                }
//            case .pageBreak:
//                break
//          //  case .remise:
//                // Vous pouvez décider de ne rien faire ou de gérer différemment
//                break
//            }
//        }
//        let currentLine = quoteArticles[index]
//        switch currentLine.lineType {
//        case .category:
//            return "\(categoryCount)"
//        case .article:
//            if categoryCount == 0 {
//                return "\(noCategoryArticleCount)"
//            } else {
//                return "\(categoryCount).\(articleCountInCategory)"
//            }
//        //case .pageBreak, .remise:
//            return ""
//        case .pageBreak:
//            return ""
//        default: // ✅ Ajout d'un default pour éviter toute future erreur
//            return ""
//        }
//    }
    private func lineNumber(for index: Int) -> String {
        let currentLine = quoteArticles[index]
        
        guard let globalIndex = globalQuoteArticles.firstIndex(where: { $0.id == currentLine.id }) else {
            return ""
        }

        var globalCounter = 0
        var currentCategoryNumber: Int? = nil
        var articleInCategoryCounter = 0

        for i in 0...globalIndex {
            let line = globalQuoteArticles[i]

            switch line.lineType {
            case .category:
                globalCounter += 1
                currentCategoryNumber = globalCounter
                articleInCategoryCounter = 0
            case .article:
                if currentCategoryNumber == nil {
                    globalCounter += 1
                } else {
                    articleInCategoryCounter += 1
                }
            default:
                break
            }

            if i == globalIndex {
                switch currentLine.lineType {
                case .category:
                    return "\(globalCounter)"
                case .article:
                    if let cat = currentCategoryNumber {
                        return "\(cat).\(articleInCategoryCounter)"
                    } else {
                        return "\(globalCounter)"
                    }
                default:
                    return ""
                }
            }
        }

        return ""
    }
    
    // MARK: - Move up/down
    
    private func moveUp(_ index: Int) {
        guard index > 0 else { return }
        quoteArticles.swapAt(index, index - 1)
        highlightIndex = index - 1
        arrowIndex = index - 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if highlightIndex == index - 1 { highlightIndex = nil }
            if arrowIndex == index - 1 { arrowIndex = nil }
        }
    }
    
    private func moveDown(_ index: Int) {
        guard index < quoteArticles.count - 1 else { return }
        quoteArticles.swapAt(index, index + 1)
        highlightIndex = index + 1
        arrowIndex = index + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if highlightIndex == index + 1 { highlightIndex = nil }
            if arrowIndex == index + 1 { arrowIndex = nil }
        }
    }
    
    // MARK: - Insert lines
    
    private func insertCategoryAbove(_ index: Int) {
        quoteArticles.insert(
            QuoteArticle(lineType: .category, comment: "Nouvelle catégorie"),
            at: index
        )
    }
    
    private func insertPrestationAbove(_ index: Int) {
        let newQA = QuoteArticle(lineType: .article, comment: "Nouvelle prestation")
        quoteArticles.insert(newQA, at: index)
    }
    
    private func insertPageBreakBelow(_ index: Int) {
        quoteArticles.insert(
            QuoteArticle(lineType: .pageBreak),
            at: index + 1
        )
    }
    private func insertPageBreakAbove(_ index: Int) {
        quoteArticles.insert(
            QuoteArticle(lineType: .pageBreak),
            at: index
        )
    }
    
    private func addCategory() {
        quoteArticles.append(
            QuoteArticle(lineType: .category, comment: "Nouvelle catégorie")
        )
    }
    
    private func addPageBreak() {
        quoteArticles.append(
            QuoteArticle(lineType: .pageBreak)
        )
    }
    
    private func confirmDelete(index: Int) {
        let line = quoteArticles[index]
        let articleName = line.designation ?? line.comment ?? "-"
        let alert = NSAlert()
        alert.messageText = "Supprimer la ligne ?"
        alert.informativeText = "Voulez-vous vraiment supprimer la ligne «\(articleName)» ?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Supprimer")
        alert.addButton(withTitle: "Annuler")
        
        if alert.runModal() == .alertFirstButtonReturn {
            quoteArticles.remove(at: index)
        }
    }
    }
    
    // MARK: - DevisLineRowHoverArrows (ligne d'article + flèches)
    
    
    fileprivate struct DevisLineRowHoverArrows: View {
        @Environment(\.isPrinting) private var isPrinting
        @Binding var quoteArticle: QuoteArticle

        let index: Int
        let computeLineNumber: (Int) -> String
        private let allUnits = ["hr", "u", "m", "m²", "m3", "ml", "l", "kg", "forfait"]
        
        
        
        let isHovering: Bool
        let highlight: Bool
        let isAutoEntrepreneur: Bool
        
        var onHoverChanged: (Bool) -> Void
        var onMoveUp: () -> Void
        var onMoveDown: () -> Void
        var onInsertLineAboveCategory: () -> Void
        var onInsertLineAbovePrestation: () -> Void
        var onInsertPageBreakBelow: () -> Void
        var onInsertPageBreakAbove: () -> Void
        var onDelete: () -> Void
        
        // Optionnel, si vous gérez les catégories
        var computeCategoryTotal: (Int) -> Double
        
        var body: some View {
            ZStack {
                rowContent

                if isHovering {
                    HStack(spacing: 4) {
                        Button(action: onMoveUp) {
                            Image(systemName: "chevron.up")
                        }
                        Button(action: onMoveDown) {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .padding(.trailing, 4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .onAppear {
                debugPrintRow()
            }
            .onHover { hovering in
                onHoverChanged(hovering)
            }
            .contextMenu {
                Button("Insérer Catégorie au-dessus") { onInsertLineAboveCategory() }
                Button("Insérer Prestation au-dessus") { onInsertLineAbovePrestation() }
                Button("Insérer un saut de page au-dessus") { onInsertPageBreakAbove() }
                Divider()
                Menu("Changer l’unité") {
                    ForEach(["hr", "u", "m", "m²", "m3", "ml", "l", "kg", "Forfait"], id: \.self) { possibleUnit in
                        Button(possibleUnit) {
                            quoteArticle.unit = possibleUnit
                        }
                    }
                }
                Divider()
                Button("Supprimer la ligne", role: .destructive) {
                    onDelete()
                }
            }
            .background(highlight ? Color.yellow : Color.clear)
        }
        
      
        // Propriété calculée pour choisir la vue à afficher en fonction du type de ligne
        @ViewBuilder
        private var rowContent: some View {
            switch quoteArticle.lineType {
            case .category:
                categoryRow
            case .pageBreak:
                pageBreakRow
            case .article:
                articleRow
            default:
                EmptyView()
            }
        }
        private func debugPrintRow() {
            print("🔁 [\(index)] ID: \(quoteArticle.id) — \(quoteArticle.designation)")
        }
        // Définition des autres vues (categoryRow, pageBreakRow, articleRow) reste inchangée…
        private var categoryRow: some View {
            let catTotal = computeCategoryTotal(index)

            return ZStack {
                // 🔹 Fond sur toute la ligne (y compris sous les PDFBoxView)
                PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.5))
                    .frame(width: 560, height: 22)

                HStack(spacing: 0) {
                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)
                    Text(computeLineNumber(index))
                        .frame(width: 37, alignment: .center)
                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)

                    if isPrinting {
                        Text(quoteArticle.comment ?? "")
                            .font(.system(size: 11, weight: .bold))
                            .frame(width: 443, alignment: .leading)
                    } else {
                        TextField("Catégorie", text: Binding(
                            get: { quoteArticle.comment ?? "" },
                            set: { quoteArticle.comment = $0 }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 443, alignment: .leading)
                    }

                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)

                    Text(String(format: "%.2f €", catTotal))
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 77, alignment: .trailing)

                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)
                }
            }
            .frame(height: 22)
        }
        
//        private var pageBreakRow: some View {
//            HStack(spacing: 0) {
//                Text("---- SAUT DE PAGE ----")
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//                    .frame(width: 560, alignment: .center)
//            }
//            .frame(height: 22)
//        }
        private var pageBreakRow: some View {
            Group {
                if !isPrinting {
                    HStack(spacing: 0) {
                        Text("---- SAUT DE PAGE ----")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .frame(width: 560, alignment: .center)
                    }
                    .frame(height: 22)
                } else {
                    EmptyView() // Ne génère rien du tout dans le PDF
                }
            }
        }
        
        private var articleRow: some View {
            let tvaRate = isAutoEntrepreneur ? 0.0 : 0.20
            let total = Double(quoteArticle.quantity) * quoteArticle.unitPrice * (1 + tvaRate)

            return ZStack {
                Color.clear.frame(height: 22)

                HStack(spacing: 0) {
                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)

                    Text(computeLineNumber(index))
                        .frame(width: 37, alignment: .center)

                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)

                    // ✅ Désignation modifiable
                    TextField("Désignation", text: $quoteArticle.designation)
                        .textFieldStyle(.plain)
                        .frame(width: 270, alignment: .leading)
                        .padding(.leading, 2)
                        .onChange(of: quoteArticle.designation) { new in
                            print("✏️ Nouvelle désignation : \(new)")
                        }

                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)

                    // ✅ Quantité
                    HStack(spacing: 0) {
                        TextField("", value: $quoteArticle.quantity, format: .number)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.center)

                        Text(quoteArticle.unit)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 50, alignment: .trailing)

                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)

                    // ✅ Prix unitaire
                    HStack(spacing: 0) {
                        TextField("", value: $quoteArticle.unitPrice, format: .number.precision(.fractionLength(2)))
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)

                        Text(" €")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 70, alignment: .trailing)

                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)

                    Text(String(format: "%.0f%%", tvaRate * 100))
                        .frame(width: 50, alignment: .trailing)

                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)

                    Text(String(format: "%.2f €", total))
                        .frame(width: 77, alignment: .trailing)

                    PDFBoxView(backgroundColor: NSColor.gray.withAlphaComponent(0.2))
                        .frame(width: 1, height: 22)
                }
                .font(.system(size: 9))
                .foregroundColor(.black)
            }
            .frame(width: 560, height: 22)
        }
    }
    

//extension Image {
//    func asNSImage() -> NSImage? {
//        let hostingView = NSHostingView(rootView: self)
//        hostingView.frame = CGRect(x: 0, y: 0, width: 100, height: 100) // Ajuster si besoin
//
//        let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds)!
//        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmapRep)
//        let nsImage = NSImage(size: hostingView.bounds.size)
//        nsImage.addRepresentation(bitmapRep)
//        return nsImage
//    }
//}
//extension View {
//    func asPDF() -> Data {
//        let controller = NSHostingController(rootView: self)
//        let view = controller.view
//        let printInfo = NSPrintInfo()
//        let pdfData = NSMutableData()
//
//        printInfo.jobDisposition = .save
//        printInfo.horizontalPagination = .automatic
//        printInfo.verticalPagination = .automatic
//        printInfo.paperSize = NSSize(width: 595, height: 842) // Format A4
//
//        let printOperation = NSPrintOperation(view: view, printInfo: printInfo)
//        printOperation.showsPrintPanel = false
//        printOperation.showsProgressPanel = false
//        printOperation.run()
//
//        if let pdfDocument = printOperation.view?.dataWithPDF(inside: printOperation.view!.bounds) {
//            pdfData.append(pdfDocument)
//        }
//
//        return pdfData as Data
//    }
//}
