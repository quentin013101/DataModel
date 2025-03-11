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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            addressSection
            projectNameSection
            articlesSection
            footerSection  // pas de Spacer() => la vue grandit en fonction du contenu
        }
        // Largeur A4 = 595, hauteur min 842, s'agrandit si plus de lignes
        .frame(width: 595)
        .frame(minHeight: 842, alignment: .top)
        .background(Color.white)
        .cornerRadius(4)
        .shadow(radius: 3)
        .environment(\.colorScheme, .light)
    }

    // MARK: - Header / Address / ProjectName (inchangé)

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                if let logo = companyInfo.logo {
                    logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                } else {
                    Text(companyInfo.companyName)
                        .font(.title3).bold()
                }
                Text(companyInfo.addressLine1)
                Text(companyInfo.addressLine2)
                Text(companyInfo.phone)
                Text(companyInfo.email)
            }
            Spacer()
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(white: 0.95))
                    .frame(width: 220, height: 100)
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: { showingClientSelection = true }) {
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.blue, lineWidth: 1)
                            .overlay(
                                Text(selectedClient == nil ? "Sélectionner un client" : "Modifier le client")
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                            )
                            .frame(height: 30)
                    }
                    if let client = selectedClient {
                        Text("\(client.firstName ?? "") \(client.lastName ?? "")")
                            .bold()
                    } else {
                        Text("Aucun client sélectionné").foregroundColor(.gray)
                    }
                }
                .padding(8)
            }
        }
        .padding(16)
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Adresse du projet").bold()
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 0.95))
                .overlay(
                    TextField("Adresse du projet", text: $clientProjectAddress)
                        .padding(.horizontal, 8)
                )
                .frame(height: 36)
        }
        .padding(.horizontal, 16)
    }

    private var projectNameSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Nom du projet").bold()
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                .overlay(
                    TextField("Nom du projet", text: $projectName)
                        .padding(.horizontal, 8)
                )
                .frame(height: 36)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Articles Section

    private var articlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            articlesTable
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Tableau (entête + VStack + boutons)

    private var articlesTable: some View {
        VStack(spacing: 0) {
            // -- En-tête --
            HStack(spacing: 0) {
                Text("N°")
                    .frame(width: 30, alignment: .leading)
                Text("Désignation")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Qté")
                    .frame(width: 40, alignment: .center)
                Text("PU")
                    .frame(width: 60, alignment: .trailing)
                Text("TVA")
                    .frame(width: 50, alignment: .trailing)
                Text("Total")
                    .frame(width: 70, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(5)

            // -- Lignes (pas de List) => ForEach + vue survol
            VStack(spacing: 0) {
                ForEach(quoteArticles.indices, id: \.self) { i in
                    let numberString = lineNumber(for: i)

                    // On passe un Binding pour éditer le quoteArticle
                    DevisLineRowHoverEditable(
                        index: i,
                        lineNumber: numberString,
                        quoteArticle: $quoteArticles[i],  // Binding
                        isAutoEntrepreneur: companyInfo.legalForm.lowercased() == "auto-entrepreneur",
                        onDelete: { confirmDelete(index: i) },
                        onMoveUp: { moveUp(i) },
                        onMoveDown: { moveDown(i) }
                    )
                    .padding(.vertical, 4)

                    Divider()
                }
            }

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
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 6) {
            Rectangle().fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 16)

            let isAuto = companyInfo.legalForm.lowercased() == "auto-entrepreneur"
            Text(isAuto ? "TVA non applicable (auto-entrepreneur)" : "TVA 20% (sauf mention légale contraire)")
                .font(.footnote)

            Text("Forme juridique : \(companyInfo.legalForm)").font(.footnote)
            Text("SIRET : \(companyInfo.siret) — APE : \(companyInfo.apeCode)").font(.footnote)
            Text("TVA : \(companyInfo.vatNumber) — IBAN : \(companyInfo.iban)").font(.footnote)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Fonctions reorder manuelles (flèche haut/bas)

    private func moveUp(_ index: Int) {
        guard index > 0 else { return }
        quoteArticles.swapAt(index, index - 1)
    }

    private func moveDown(_ index: Int) {
        guard index < quoteArticles.count - 1 else { return }
        quoteArticles.swapAt(index, index + 1)
    }

    // MARK: - Fonctions existantes (catégorie, saut de page, etc.)

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
