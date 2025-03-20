import SwiftUI
import AppKit

struct A4SheetView: View {
    let companyInfo: CompanyInfo

    @Binding var selectedClient: Contact?
    @Binding var quoteArticles: [QuoteArticle]
    @Binding var clientProjectAddress: String
    @Binding var projectName: String

    @Binding var showingClientSelection: Bool
    @Binding var showingArticleSelection: Bool
    @State private var isShowingRemisePopup = false

    @State private var arrowIndex: Int? = nil
    @State private var highlightIndex: Int? = nil
    
    
    private func computeCategoryTotal(startIndex: Int) -> Double {
        let isAuto = companyInfo.legalForm.lowercased().contains("auto")
        var sum: Double = 0

        // Trouver l’index de la prochaine catégorie
        let nextCatIndex = findNextCategoryIndex(after: startIndex)

        // Parcourir les lignes [startIndex+1 ..< nextCatIndex]
        for i in (startIndex+1) ..< nextCatIndex {
            let line = quoteArticles[i]
            if line.lineType == .article {
                let price = line.article?.price ?? 0.0
                let tvaRate = isAuto ? 0.0 : 0.20
                sum += Double(line.quantity) * price * (1 + tvaRate)
            }
        }
        return sum
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            projectNameField
            articlesSection

            signatureSection
                .padding(.top, 16)

            clientProSignatureSection
                .padding(.top, 16)

            Spacer(minLength: 0)
                .layoutPriority(-1)

            footerSection
        }
        .font(.system(size: 9))
        .frame(width: 595, alignment: .top)
        .background(Color.white)
        .environment(\.colorScheme, .light)
        .animation(.default, value: highlightIndex)
    }

    // MARK: - 1) Header

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                if let logo = companyInfo.logo {
                    logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } else {
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
                Text("Devis N° DEV-\(Calendar.current.component(.year, from: Date()))-001")
                    .font(.headline)
                    .padding(.top, 32)

                Text("En date du \(formattedToday)")
                    .font(.subheadline)

                Text("Valable 3 mois")
                    .font(.subheadline)
                    .padding(.bottom, 16)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(white: 0.95))

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
                .frame(width: 260, height: 80)
                .clipped()
            }
            .padding(.trailing, 16)
        }
        .padding(.top, 16)
    }

    private var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }

    // MARK: - 2) Nom du projet

    private var projectNameField: some View {
        TextField("Nom du projet", text: $projectName)
            .font(.system(size: 13).bold().italic())
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .padding(.top, 16)
    }

    // MARK: - 3) Articles

    private var articlesSection: some View {
        let tableWidth: CGFloat = 560
        // Lignes verticales à [0, 40, 310, 360, 430, 480, 560]
        let columnLines: [CGFloat] = [0, 40, 310, 360, 430, 480, 560]

        return VStack(spacing: 0) {
            VStack(spacing: 0) {
                headerRow(width: tableWidth)

                if !quoteArticles.isEmpty {
                    ForEach(quoteArticles.indices, id: \.self) { i in
                        let numberString = lineNumber(for: i)
                        DevisLineRowHoverArrows(
                            index: i,
                            lineNumber: numberString,
                            quoteArticle: $quoteArticles[i],
                            isHovering: (arrowIndex == i),
                            highlight: (highlightIndex == i),
                            isAutoEntrepreneur: companyInfo.legalForm.lowercased() == "auto-entrepreneur",
                            onHoverChanged: { hovering in
                                if hovering { arrowIndex = i }
                                else if arrowIndex == i { arrowIndex = nil }
                            },
                            onMoveUp: { moveUp(i) },
                            onMoveDown: { moveDown(i) },
                            onInsertLineAboveCategory: { insertCategoryAbove(i) },
                            onInsertLineAbovePrestation: { insertPrestationAbove(i) },
                            onInsertPageBreakBelow: { insertPageBreakBelow(i) },
                            onDelete: { confirmDelete(index: i) },
                            // Remplacez l'ancien code par ceci :
                            computeCategoryTotal: { _ in computeCategoryTotal(startIndex: i) }
                        )
                    }

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 2)
                }
            }
            .frame(width: tableWidth, alignment: .topLeading)
            .background(
                VerticalLinesOverlay(positions: columnLines)
            )

            // Boutons sous le tableau
            HStack(spacing: 16) {
                Button("+ Prestation") {
                    showingArticleSelection = true
                }
                .foregroundColor(.blue)

                Button("Catégorie") {
                    addCategory()
                }
                .foregroundColor(.blue)

                Button("Saut de page") {
                    addPageBreak()
                }
                .foregroundColor(.blue)
            }
            .padding(.top, 8)
        }
        .frame(width: tableWidth)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    /// N°(40) / Désignation(270) / Qté(50) / PU(70) / TVA(50) / Total(80)
    private func headerRow(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            Text("N°")
                .frame(width: 40, alignment: .center)
            Text("Désignation")
                .frame(width: 270, alignment: .center)
            Text("Qté")
                // On laisse 50 (pas besoin de marge ?)
                .frame(width: 50, alignment: .center)
            Text("PU €")
                .frame(width: 70, alignment: .center)
            Text("TVA")
                .frame(width: 50, alignment: .center)
            Text("Total €")
                .frame(width: 80, alignment: .center)
        }
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.white)
        .padding(.vertical, 6)
        .background(Color(red: 106/255, green: 133/255, blue: 187/255))
    }

    // MARK: - 5) Signature / net à payer

    private var signatureSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Paiement en espèces, par chèque ou par virement bancaire.")
                Text("Le montant peut être révisé en fonction du temps réel passé sur le chantier et de l’ajustement des fournitures et/ou de leurs prix.")
                if companyInfo.legalForm.lowercased().contains("auto") {
                    Text("TVA non applicable, article 293 B du Code Général des Impôts.")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 8) {
                let net = recalcNetTotal()
                HStack(spacing: 0) {
                    Spacer()
                    Text("Net à payer :")
                        .bold()
                    Text(String(format: "%.2f €", net))
                        .bold()
                        .frame(width: 80, alignment: .trailing)
                }
                .font(.system(size: 12))
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(Color(red: 106/255, green: 133/255, blue: 187/255))
                .foregroundColor(.white)
                .cornerRadius(4)

                Button("Remise") {
                    isShowingRemisePopup = true
                }
                .sheet(isPresented: $isShowingRemisePopup) {
                    RemisePopupView(isPresented: $isShowingRemisePopup, totalBeforeDiscount: computeTotalBeforeDiscount()) { discount in
                        addDiscountLine(discountAmount: discount)
                    }
                }
            }
            
            .frame(width: 200, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
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
    func addDiscountLine(discountAmount: Double) {
        let discountLine = QuoteArticle(discountAmount: discountAmount)
        quoteArticles.append(discountLine)
    }

    func recalcNetTotal() -> Double {
        let articlesTotal = computeTotal()  // total des articles
        let discountTotal = quoteArticles.filter { $0.lineType == .remise }
                                         .reduce(0) { $0 + $1.total }
        return articlesTotal + discountTotal
    }
    // MARK: - 6) Signatures client / pro

    private var clientProSignatureSection: some View {
        HStack(alignment: .top, spacing: 40) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Le Client")
                    .font(.system(size: 9).bold())
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.9))
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
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(white: 0.9))
                    .frame(width: 240, height: 80)
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
        var sum: Double = 0
        let isAuto = companyInfo.legalForm.lowercased().contains("auto")
        for qa in quoteArticles {
            guard qa.lineType == .article else { continue }
            let price = qa.article?.price ?? 0.0
            let tvaRate = isAuto ? 0.0 : 0.20
            sum += Double(qa.quantity) * price * (1 + tvaRate)
        }
        return sum
    }

    // MARK: - Logique articles

    private func lineNumber(for index: Int) -> String {
        var categoryCount = 0
        var noCategoryArticleCount = 0
        var articleCountInCategory = 0
        for i in 0...index {
            let line = quoteArticles[i]
            switch line.lineType {
            case .category:
                categoryCount += 1
                articleCountInCategory = 0
            case .article:
                if categoryCount == 0 {
                    noCategoryArticleCount += 1
                } else {
                    articleCountInCategory += 1
                }
            case .pageBreak:
                break
            case .remise:
                // Vous pouvez décider de ne rien faire ou de gérer différemment
                break
            }
        }
        let currentLine = quoteArticles[index]
        switch currentLine.lineType {
        case .category:
            return "\(categoryCount)"
        case .article:
            if categoryCount == 0 {
                return "\(noCategoryArticleCount)"
            } else {
                return "\(categoryCount).\(articleCountInCategory)"
            }
        case .pageBreak, .remise:
            return ""
        }
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
        let articleName = line.article?.name ?? line.comment ?? "-"
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

// MARK: - Overlay pour dessiner des lignes verticales continues

struct VerticalLinesOverlay: View {
    let positions: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let totalHeight = geo.size.height
                for xPos in positions {
                    path.move(to: CGPoint(x: xPos, y: 0))
                    path.addLine(to: CGPoint(x: xPos, y: totalHeight))
                }
            }
            .stroke(Color.black.opacity(0.2), lineWidth: 1)
        }
    }
}

// MARK: - DevisLineRowHoverArrows (ligne d'article + flèches)

fileprivate struct DevisLineRowHoverArrows: View {
    let index: Int
    let lineNumber: String
    private let allUnits = ["hr", "u", "m", "m²", "m3", "ml", "l", "kg", "forfait"]

    @Binding var quoteArticle: QuoteArticle

    let isHovering: Bool
    let highlight: Bool
    let isAutoEntrepreneur: Bool

    var onHoverChanged: (Bool) -> Void
    var onMoveUp: () -> Void
    var onMoveDown: () -> Void
    var onInsertLineAboveCategory: () -> Void
    var onInsertLineAbovePrestation: () -> Void
    var onInsertPageBreakBelow: () -> Void
    var onDelete: () -> Void

    // Optionnel, si vous gérez les catégories
    var computeCategoryTotal: (Int) -> Double

    var body: some View {
        ZStack {
            rowContent  // Utilisation de la propriété calculée
            if isHovering {
                HStack(spacing: 4) {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up")
                    }
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down")
                    }
                }
                .padding(.leading, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onHover { hovering in
            onHoverChanged(hovering)
        }
        .contextMenu {
            Button("Insérer Catégorie au-dessus") { onInsertLineAboveCategory() }
            Button("Insérer Prestation au-dessus") { onInsertLineAbovePrestation() }
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
        case .remise:
            // Affichage pour la remise
            HStack(spacing: 0) {
                Text("") // Pas de numéro
                    .frame(width: 40, alignment: .center)
                TextField("Remise", text: Binding(
                    get: { quoteArticle.comment ?? "" },
                    set: { quoteArticle.comment = $0 }
                ))
                .textFieldStyle(.plain)
                .frame(width: 266, alignment: .leading)
                .padding(.leading, 4)
                Spacer()
                Text(String(format: "%.2f €", quoteArticle.unitPrice))
                    .frame(width: 76, alignment: .trailing)
                    .padding(.trailing, 4)
            }
        }
    }

    // Définition des autres vues (categoryRow, pageBreakRow, articleRow) reste inchangée…
    private var categoryRow: some View {
        let catTotal = computeCategoryTotal(index)
        return HStack(spacing: 0) {
            Text(lineNumber)
                .frame(width: 40, alignment: .center)
            TextField("Catégorie", text: Binding(
                get: { quoteArticle.comment ?? "" },
                set: { quoteArticle.comment = $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .font(.system(size: 11, weight: .bold))
            .frame(width: 440, alignment: .leading)
            Text(String(format: "%.2f €", catTotal))
                .font(.system(size: 11, weight: .bold))
                .frame(width: 80, alignment: .trailing)
        }
        .frame(height: 22)
        .background(Color(white: 0.95))
    }

    private var pageBreakRow: some View {
        HStack(spacing: 0) {
            Text("---- SAUT DE PAGE ----")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .frame(width: 560, alignment: .center)
        }
        .frame(height: 22)
    }

    private var articleRow: some View {
        let tvaRate = isAutoEntrepreneur ? 0.0 : 0.20
        let total = Double(quoteArticle.quantity) * (quoteArticle.article?.price ?? 0.0) * (1 + tvaRate)
        return HStack(spacing: 0) {
            Text(lineNumber)
                .frame(width: 40, alignment: .center)
            TextField("Désignation", text: Binding(
                get: { quoteArticle.article?.name ?? "" },
                set: { quoteArticle.article?.name = $0 }
            ))
            .textFieldStyle(.plain)
            .frame(width: 266, alignment: .leading)
            .padding(.leading, 4)
            HStack(spacing: 1) {
                TextField("", value: Binding(
                    get: { Double(quoteArticle.quantity) },
                    set: { quoteArticle.quantity = Int16($0) }
                ), format: .number)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                Text(quoteArticle.unit ?? "")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.gray)
            }
            .frame(width: 46, alignment: .trailing)
            .padding(.trailing, 4)
            TextField("", value: Binding(
                get: { quoteArticle.article?.price ?? 0.0 },
                set: { quoteArticle.article?.price = $0 }
            ), format: .number.precision(.fractionLength(2)))
            .textFieldStyle(.plain)
            .multilineTextAlignment(.trailing)
            .frame(width: 66, alignment: .trailing)
            .padding(.trailing, 4)
            Text(String(format: "%.0f%%", tvaRate * 100))
                .frame(width: 46, alignment: .trailing)
                .padding(.trailing, 4)
            Text(String(format: "%.2f €", total))
                .frame(width: 76, alignment: .trailing)
                .padding(.trailing, 4)
        }
        .font(.system(size: 9))
        .frame(height: 22)
    }
}
