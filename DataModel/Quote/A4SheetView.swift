

import SwiftUI

struct A4SheetView: View {
    let companyInfo: CompanyInfo

    @Binding var selectedClient: Contact?
    @Binding var quoteArticles: [QuoteArticle]
    @Binding var clientProjectAddress: String
    @Binding var projectName: String

    @Binding var showingClientSelection: Bool
    @Binding var showingArticleSelection: Bool

    private let cols = TableColumns()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            addressSection
            projectNameSection
            articlesTable
            buttonsSection
            Spacer()
            footerSection
        }
        .frame(minWidth: 595, minHeight: 842) // largeur fixe A4, hauteur minimale A4 extensible
        .background(Color.white)
        .cornerRadius(4)
        .shadow(radius: 3)
        .environment(\.colorScheme, .light)
    }

    // Remets ici toutes les sous-vues :
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
                        .foregroundColor(.black)
                }
                Text(companyInfo.addressLine1).foregroundColor(.black)
                Text(companyInfo.addressLine2).foregroundColor(.black)
                Text(companyInfo.phone).foregroundColor(.black)
                Text(companyInfo.email).foregroundColor(.black)
            }
            Spacer()
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6).fill(Color(white: 0.95)).frame(width: 220, height: 100)
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: { showingClientSelection = true }) {
                        RoundedRectangle(cornerRadius: 6).strokeBorder(Color.blue, lineWidth: 1)
                            .overlay(
                                Text(selectedClient == nil ? "Sélectionner un client" : "Modifier le client")
                                    .foregroundColor(.blue).padding(.horizontal, 8)
                            )
                            .frame(height: 30)
                    }
                    if let client = selectedClient {
                        Text("\(client.firstName ?? "") \(client.lastName ?? "")")
                            .bold().foregroundColor(.black)
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
            Text("Adresse du projet").bold().foregroundColor(.black)
            RoundedRectangle(cornerRadius: 6).fill(Color(white: 0.95))
                .overlay(TextField("Adresse du projet", text: $clientProjectAddress).padding(.horizontal, 8))
                .frame(height: 36)
        }
        .padding(.horizontal, 16)
    }

    private var projectNameSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Nom du projet").bold().foregroundColor(.black)
            RoundedRectangle(cornerRadius: 6).strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                .overlay(TextField("Nom du projet", text: $projectName).padding(.horizontal, 8))
                .frame(height: 36)
        }
        .padding(.horizontal, 16).padding(.top, 8)
    }

    private var articlesTable: some View {
        VStack(spacing: 0) {
            HStack {
                Text("N°").frame(width: cols.numero, alignment: .leading)
                Text("Désignation").frame(width: cols.designation, alignment: .leading)
                Text("Qté").frame(width: cols.quantite, alignment: .center)
                Text("PU").frame(width: cols.pu, alignment: .trailing)
                Text("TVA").frame(width: cols.tva, alignment: .trailing)
                Text("Total").frame(width: cols.total, alignment: .trailing)
            }
            .padding().background(Color.gray.opacity(0.2)).cornerRadius(5)

            ForEach(quoteArticles.indices, id: \.self) { index in
                DevisLineRow(
                    index: index,
                    quoteArticle: quoteArticles[index],
                    isAutoEntrepreneur: companyInfo.legalForm.lowercased() == "auto-entrepreneur",
                    columns: cols,
                    onDelete: { confirmDelete(index: index) }
                )
                .padding(.vertical, 2)
            }
            .onMove(perform: moveRow)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var buttonsSection: some View {
        HStack(spacing: 16) {
            Button("+ Prestation") { showingArticleSelection = true }.foregroundColor(.blue)
            Button("Catégorie") { /* action */ }.foregroundColor(.blue)
        }
        .padding(.horizontal, 16).padding(.top, 8)
    }

    private var footerSection: some View {
        VStack(spacing: 6) {
            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1).padding(.horizontal, 16)
            let isAuto = companyInfo.legalForm.lowercased() == "auto-entrepreneur"
            Text(isAuto ? "TVA non applicable (auto-entrepreneur)" : "TVA 20% (sauf mention légale contraire)")
                .foregroundColor(.black).font(.footnote)
            Text("Forme juridique : \(companyInfo.legalForm)").foregroundColor(.black).font(.footnote)
            Text("SIRET : \(companyInfo.siret) — APE : \(companyInfo.apeCode)").foregroundColor(.black).font(.footnote)
            Text("TVA : \(companyInfo.vatNumber) — IBAN : \(companyInfo.iban)").foregroundColor(.black).font(.footnote)
        }
        .padding(.bottom, 16)
    }

    private func confirmDelete(index: Int) {
        let articleName = quoteArticles[index].article.name ?? "-"
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

    private func moveRow(from source: IndexSet, to destination: Int) {
        quoteArticles.move(fromOffsets: source, toOffset: destination)
    }
}

/// Struct pour colonnes
fileprivate struct TableColumns {
    let numero: CGFloat = 30
    let designation: CGFloat = 270
    let quantite: CGFloat = 40
    let pu: CGFloat = 40
    let tva: CGFloat = 40
    let total: CGFloat = 70
}

// Assure-toi d'avoir ce struct ailleurs :
fileprivate struct DevisLineRow: View {
    let index: Int
    let quoteArticle: QuoteArticle
    let isAutoEntrepreneur: Bool
    let columns: TableColumns
    var onDelete: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack {
            // Bouton poubelle quand on survole la ligne
            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "trash").foregroundColor(.red)
                }
                .padding(.trailing, 4)
            }

            // Numéro de ligne
            Text("\(index + 1)")
                .frame(width: columns.numero, alignment: .leading)

            // Désignation de l'article
            Text(quoteArticle.article.name ?? "")
                .frame(width: columns.designation, alignment: .leading)

            // Quantité
            Text("\(quoteArticle.quantity)")
                .frame(width: columns.quantite, alignment: .center)

            // Prix unitaire
            Text(String(format: "%.2f", quoteArticle.article.price))
                .frame(width: columns.pu, alignment: .trailing)

            // TVA
            let tva = isAutoEntrepreneur ? 0.0 : quoteArticle.article.tva
            Text(String(format: "%.2f", tva))
                .frame(width: columns.tva, alignment: .trailing)

            // Total = prix * quantité * (1 + TVA)
            let total = Double(quoteArticle.quantity) * quoteArticle.article.price * (1 + tva)
            Text(String(format: "%.2f", total))
                .frame(width: columns.total, alignment: .trailing)
        }
        .onHover { hovering in isHovering = hovering }
    }
}
