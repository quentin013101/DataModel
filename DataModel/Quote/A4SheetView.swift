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

    @State private var arrowIndex: Int? = nil
    @State private var highlightIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            topClientAddressSection
            projectNameField
            articlesSection

            signatureSection
                .padding(.top, 16)

            clientProSignatureSection
                .padding(.top, 16)

            Spacer()

            footerSection
        }
        .font(.system(size: 9))
        .frame(width: 595)
        .frame(minHeight: 842, alignment: .top)
        .background(Color.white)
        .cornerRadius(4)
        .shadow(radius: 3)
        .environment(\.colorScheme, .light)
        .animation(.default, value: highlightIndex)
    }

    // MARK: - 1) Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                if let logo = companyInfo.logo {
                    logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } else {
                    Text(companyInfo.companyName)
                        .font(.title2).bold()
                }
                Text(companyInfo.addressLine1)
                Text(companyInfo.addressLine2)
                Text(companyInfo.phone)
                Text(companyInfo.email)
            }
        }
        .padding(16)
    }

    // MARK: - 2) Encart client + Adresse projet

    private var topClientAddressSection: some View {
        HStack(alignment: .top) {
            // -- Rectangle de gauche : Adresse du projet --
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(white: 0.95))

                // TextEditor multi-lignes, centré verticalement
                VStack {
                    Spacer()
                   TextEditor(text: $clientProjectAddress)
                        .multilineTextAlignment(.center)
                        .background(Color.clear) // pas de fond blanc
                        .scrollContentBackground(.hidden) // iOS 16 / macOS 13+
                        .frame(height: 36)
                        .padding(.horizontal, 8)

                    
                    Spacer()
                }
            }
            .frame(width: 220, height: 60)
            .overlay(
                // Petit label au-dessus
                VStack(alignment: .leading, spacing: 2) {
                    Text("Adresse du projet")
                        .font(.system(size: 9))
                        .foregroundColor(.black)
                        .padding(.bottom, 2)
                }
                .frame(width: 220, alignment: .topLeading)
                .offset(y: -16) // Décale le titre juste au-dessus du rectangle
                , alignment: .top
            )

            Spacer()

            // -- Rectangle de droite : Client --
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(white: 0.95))

                // On centre verticalement le contenu
                VStack {
                    Spacer()
                    if let client = selectedClient {
                        let civ = client.civility ?? "M."
                        let nomMaj = (client.lastName ?? "").uppercased()
                        let prenom = client.firstName ?? ""
                        Text("\(civ) \(nomMaj) \(prenom)")
                            .bold()
                            .onTapGesture {
                                showingClientSelection = true
                            }
                    } else {
                        Button(action: { showingClientSelection = true }) {
                            Text("Aucun client sélectionné")
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            }
            .frame(width: 220, height: 60)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - 3) Nom du projet

    private var projectNameField: some View {
        TextField("Nom du projet", text: $projectName)
            .font(.system(size: 13).bold().italic())
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
    }

    // MARK: - 4) Articles

    private var articlesSection: some View {
        let tableWidth: CGFloat = 560
        // Colonnes : 0, 30, 310, 360, 430, 480, 560
        let columnLines: [CGFloat] = [0, 30, 310, 360, 430, 480, 560]

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
                            onDelete: { confirmDelete(index: i) }
                        )
                    }

                    // Ligne horizontale pour "fermer" le tableau
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

    private func headerRow(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            Text("N°")
                .frame(width: 30, alignment: .center)
            Text("Désignation")
                .frame(width: 280, alignment: .leading)
                .padding(.leading, 4)
            Text("Qté")
                .frame(width: 50, alignment: .center)
            Text("PU €")
                .frame(width: 70, alignment: .trailing)
            Text("TVA")
                .frame(width: 50, alignment: .trailing)
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
                let total = computeTotal()
                HStack(spacing: 0) {
                    Spacer()
                    Text("Net à payer :")
                        .bold()
                    Text(String(format: "%.2f €", total))
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
                    // action
                }
            }
            .frame(width: 280, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
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
                    Text("Mention manuscrite et datée :\n« Devis reçu avant l’exécution des travaux. Bon pour travaux. »")
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
            Text(isAuto ? "TVA non applicable (auto-entrepreneur)" : "TVA 20% (sauf mention légale contraire)")
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

    // MARK: - Numérotation

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
        case .pageBreak:
            return ""
        }
    }

    // MARK: - Déplacements de ligne

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
                .padding(.leading, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onHover { hovering in
            onHoverChanged(hovering)
        }
        .contextMenu {
            Button("Insérer Catégorie au-dessus") {
                onInsertLineAboveCategory()
            }
            Button("Insérer Prestation au-dessus") {
                onInsertLineAbovePrestation()
            }
            Button("Insérer un saut de page en dessous") {
                onInsertPageBreakBelow()
            }
            Divider()
            Button("Supprimer la ligne", role: .destructive) {
                onDelete()
            }
        }
        .background(highlight ? Color.yellow : Color.clear)
    }

    @ViewBuilder
    private var rowContent: some View {
        switch quoteArticle.lineType {
        case .category:
            categoryRow
        case .pageBreak:
            pageBreakRow
        case .article:
            articleRow
        }
    }

    private var categoryRow: some View {
        HStack(spacing: 0) {
            Text(lineNumber)
                .frame(width: 30, alignment: .center)
            TextField("Catégorie", text: Binding(
                get: { quoteArticle.comment ?? "" },
                set: { quoteArticle.comment = $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .fontWeight(.bold)
            .frame(width: 530, alignment: .center)
            .frame(height: 22)
        }
    }

    private var pageBreakRow: some View {
        HStack(spacing: 0) {
            Text("---- SAUT DE PAGE ----")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                // Largeur totale = 560, on retire 30 pour la colonne "N°" = 530
                .frame(width: 530, alignment: .center)
        }
        .frame(height: 22)
    }

    private var articleRow: some View {
        HStack(spacing: 0) {
            // N°
            Text(lineNumber)
                .frame(width: 30, alignment: .leading)

            // Désignation (petite marge à gauche)
            TextField("Désignation", text: Binding(
                get: { quoteArticle.article?.name ?? "" },
                set: { quoteArticle.article?.name = $0 }
            ))
            .textFieldStyle(.plain)
            .padding(.leading, 4)
            .frame(width: 280, alignment: .leading)

            // Qté + unité
            HStack(spacing: 2) {
                TextField("", value: Binding(
                    get: { Double(quoteArticle.quantity) },
                    set: { quoteArticle.quantity = Int16($0) }
                ), format: .number)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.trailing)
                Text(quoteArticle.article?.unit ?? "")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 4)
            .frame(width: 50, alignment: .trailing)

            // PU € (marge à droite)
            TextField("", value: Binding(
                get: { quoteArticle.article?.price ?? 0.0 },
                set: { quoteArticle.article?.price = $0 }
            ), format: .number.precision(.fractionLength(2)))
            .textFieldStyle(.plain)
            .multilineTextAlignment(.trailing)
            .padding(.trailing, 4)
            .frame(width: 70, alignment: .trailing)

            // TVA
            let tvaRate = isAutoEntrepreneur ? 0.0 : 0.20
            Text(String(format: "%.0f%%", tvaRate * 100))
                .padding(.trailing, 4)
                .frame(width: 50, alignment: .trailing)

            // Total €
            let total = Double(quoteArticle.quantity) * (quoteArticle.article?.price ?? 0.0) * (1 + tvaRate)
            Text(String(format: "%.2f €", total))
                .padding(.trailing, 4)
                .frame(width: 80, alignment: .trailing)
        }
        .font(.system(size: 9))
        .frame(height: 22)
    }
}
