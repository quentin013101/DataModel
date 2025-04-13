import SwiftUI
import CoreData

struct QuoteGroupView: View {
    @FetchRequest var relatedInvoices: FetchedResults<Invoice>
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTab: String
    @Binding var quoteToEdit: QuoteEntity?
    @Binding var invoiceToEdit: Invoice?
    @Binding var selectedQuoteForInvoice: QuoteEntity?

    let quote: QuoteEntity
    @State private var companyInfo: CompanyInfo = CompanyInfo.loadFromUserDefaults()
    @State private var showPercentageInput = false
    @State private var invoiceToCreateType: InvoiceType?
    @State private var invoiceToDelete: Invoice?
    @State private var customPercentage: Double = 30
    @State private var showDeleteConfirmation = false
    @State private var showInvoiceDeleteConfirmation = false
    @State private var isAutoEntrepreneur: Bool = true // ou false selon le profil

    init(
        selectedTab: Binding<String>,
        quoteToEdit: Binding<QuoteEntity?>,
        invoiceToEdit: Binding<Invoice?>,
        selectedQuoteForInvoice: Binding<QuoteEntity?>,
        quote: QuoteEntity
    ) {
        self._selectedTab = selectedTab
        self._quoteToEdit = quoteToEdit
        self._invoiceToEdit = invoiceToEdit
        self._selectedQuoteForInvoice = selectedQuoteForInvoice
        self.quote = quote

        _relatedInvoices = FetchRequest(
            entity: Invoice.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.date, ascending: false)],
            predicate: NSPredicate(format: "quote == %@", quote)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 🏷️ En-tête avec le nom du projet
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(quote.projectName ?? "Nom du projet")
                        .font(.title3).bold()

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Montant devisé : \(quote.total.formattedCurrency())")
                        let totalFacturé = relatedInvoices.reduce(0) { $0 + $1.totalTTC }
                        Text("Montant facturé : \(totalFacturé.formattedCurrency())")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                HStack(spacing: 24) {
                    Text(quote.clientFullName).font(.headline)
                    Text("•")
                    if let fullAddress = quote.clientProjectAddress {
                        Text(fullAddress.replacingOccurrences(of: "\n", with: ", "))
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    if let phone = quote.clientPhone, !phone.isEmpty {
                        Text("•")
                        Text("📞 \(phone)").font(.headline)
                    }
                    if let email = quote.clientEmail, !email.isEmpty {
                        Text("•")
                        Text("✉️ \(email)").font(.headline)
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)

            // 📄 Devis principal
            QuoteHeaderView(
                quote: quote,
                onDelete: {
                    showDeleteConfirmation = true
                },
                onEdit: {
                    quoteToEdit = quote
                    selectedTab = "devis"
                }
            )

            // 📄 Factures liées à ce devis
            ForEach(relatedInvoices) { invoice in
                let montantAffiche = formattedInvoiceAmount(invoice)

                DocumentRowView(
                    icon: "doc.text.fill",
                    number: invoice.invoiceNumber ?? "FACTURE",
                    clientName: invoice.quote?.clientFullName ?? "—",
                    amount: invoice.totalTTC.formattedCurrency(),
                    date: invoice.date.map { formattedDateFR($0) } ?? "",
                    statusMenu: AnyView(InvoiceStatusMenu(invoice: invoice)),
                    onDelete: {
                        invoiceToDelete = invoice
                        showInvoiceDeleteConfirmation = true
                    },
                    onTap: {
                        invoiceToEdit = invoice
                        selectedQuoteForInvoice = quote
                        selectedTab = "facture"
                    }
                )
            }

            // ➕ Menu Créer facture
            HStack {
                Spacer()
                Menu {
                    Button("Créer facture d’acompte") {
                        invoiceToCreateType = .acompte
                        selectedQuoteForInvoice = quote
                        showPercentageInput = true
                    }
                    Button("Créer facture intermédiaire") {
                        invoiceToCreateType = .intermediaire
                        selectedQuoteForInvoice = quote
                        showPercentageInput = true
                    }
                    Button("Créer une facture finale") {
                        let invoice = createInvoice(from: quote, type: .finale)
                        invoiceToEdit = invoice
                        selectedQuoteForInvoice = quote
                        selectedTab = "facture"
                    }
                } label: {
                    Label("Créer…", systemImage: "plus.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.blue))
        .padding(.horizontal)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Supprimer ce devis ?"),
                message: Text("Cette action est irréversible."),
                primaryButton: .destructive(Text("Supprimer")) {
                    viewContext.delete(quote)
                    try? viewContext.save()
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showInvoiceDeleteConfirmation) {
            Alert(
                title: Text("Supprimer cette facture ?"),
                message: Text("Cette action est irréversible."),
                primaryButton: .destructive(Text("Supprimer")) {
                    if let invoice = invoiceToDelete {
                        viewContext.delete(invoice)
                        try? viewContext.save()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .popover(isPresented: $showPercentageInput) {
            PercentagePopover(
                customPercentage: $customPercentage,
                onValidate: {
                    if let type = invoiceToCreateType {
                        let invoice = createInvoice(from: quote, type: type, percentage: customPercentage)
                        selectedQuoteForInvoice = quote
                        openInvoice(invoice)
                    }
                    showPercentageInput = false
                    invoiceToCreateType = nil
                },
                onCancel: {
                    showPercentageInput = false
                    invoiceToCreateType = nil
                },
                quote: quote,
                isAutoEntrepreneur: companyInfo.legalForm.lowercased().contains("auto")
            )
        }
    }
    func formattedInvoiceAmount(_ invoice: Invoice) -> String {
        return invoice.totalTTC.formattedCurrency()
    }


    func createInvoice(from quote: QuoteEntity, type: InvoiceType, percentage: Double? = nil) -> Invoice {
        let invoice = Invoice(context: viewContext)
        invoice.id = UUID()
        invoice.date = Date()
        invoice.status = "Brouillon"
        invoice.quote = quote
        invoice.isPartial = (type != .finale)
        invoice.invoiceType = type.rawValue // "acompte", "intermediaire", "finale"
        invoice.invoiceNumber = generateNextInvoiceNumber(context: viewContext)
        invoice.referenceQuoteNumber = quote.devisNumber
        invoice.referenceQuoteDate = quote.date
        invoice.referenceQuoteTotal = quote.total

        let isAutoEntrepreneur = companyInfo.legalForm.lowercased().contains("auto")

        if type != .finale {
            // Acompte / intermédiaire (inchangé ici)
            let baseTotal = quote.total
            let p = percentage ?? 30
            invoice.partialPercentage = p
            invoice.partialAmount = baseTotal * (p / 100)
            invoice.totalHT = invoice.partialAmount

            invoice.tva = isAutoEntrepreneur ? 0 : invoice.totalHT * 0.2
            invoice.totalTTC = invoice.totalHT + invoice.tva

            invoice.invoiceNote = defaultInfoText(for: invoice)

            let designation = type == .acompte
                ? "Acompte de \(Int(p))% pour le devis \(quote.devisNumber ?? "")"
                : "Facture intermédiaire de \(Int(p))% pour le devis \(quote.devisNumber ?? "")"

            let article = QuoteArticle(
                designation: designation,
                quantity: 1,
                unit: "forfait",
                unitPrice: invoice.totalHT,
                lineType: .article
            )

            invoice.invoiceArticlesData = try? JSONEncoder().encode([article])

        } else {
            // ✅ Facture finale : copie du devis avec sous-total et remise

            invoice.totalHT = quote.sousTotal

            // Appliquer la remise du devis
            let remiseIsPercentage = quote.remiseIsPercentage
            let remiseValue = quote.remiseValue
            let remiseAmount = remiseIsPercentage
                ? quote.sousTotal * remiseValue / 100
                : remiseValue

            invoice.remiseIsPercentage = remiseIsPercentage
            invoice.remiseValue = remiseValue
            invoice.remiseAmount = remiseAmount

            let totalHTAfterRemise = invoice.totalHT - remiseAmount
            invoice.tva = isAutoEntrepreneur ? 0 : totalHTAfterRemise * 0.2
            invoice.totalTTC = totalHTAfterRemise + invoice.tva

            invoice.invoiceArticlesData = quote.quoteArticlesData
            if let previousInvoices = quote.invoices?.allObjects as? [Invoice] {
                let previousFinalized = previousInvoices.filter { $0 != invoice && $0.isPartial }

                if !previousFinalized.isEmpty,
                   var existingArticles = try? JSONDecoder().decode([QuoteArticle].self, from: quote.quoteArticlesData ?? Data()) {

                    // 🟨 Ajouter la catégorie "Factures déjà émises"
                    existingArticles.append(QuoteArticle(
                        lineType: .category,
                        comment: "Factures déjà émises"
                    ))

                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy"

                    for inv in previousFinalized {
                        let dateStr = formatter.string(from: inv.date ?? Date())
                        let designation = "Facture N° \(inv.invoiceNumber ?? "") du \(dateStr)"
                        let article = QuoteArticle(
                            designation: designation,
                            quantity: 1, // ✅ important pour que le montant soit pris en compte
                            unit: "",    // ✅ on laisse vide pour que ça ne s’affiche pas
                            unitPrice: -(inv.totalTTC), // ✅ montant en négatif
                            lineType: .article
                        )
                        existingArticles.append(article)
                    }

                    invoice.invoiceArticlesData = try? JSONEncoder().encode(existingArticles)
                }
            }
            // 🔍 Log de vérification
//            print("""
//            ✅ Facture finale créée :
//            - HT : \(invoice.totalHT)
//            - Remise : \(invoice.remiseAmount)
//            - HT après remise : \(totalHTAfterRemise)
//            - TVA : \(invoice.tva)
//            - TTC : \(invoice.totalTTC)
//            """)
        }

        do {
            try viewContext.save()
            viewContext.refresh(quote, mergeChanges: true)
            print("✅ Facture créée : \(invoice.invoiceNumber ?? "-")")
            return invoice
        } catch {
            print("❌ Erreur lors de la création de la facture : \(error)")
            return invoice
        }
    }

    func openInvoice(_ invoice: Invoice) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            invoiceToEdit = invoice
            selectedTab = "facture"
        }
    }
}

struct QuoteHeaderView: View {
    let quote: QuoteEntity
    let onDelete: () -> Void
    let onEdit: () -> Void

    var body: some View {
        DocumentRowView(
            icon: "doc.text",
            number: quote.devisNumber ?? "DEV",
            clientName: quote.clientFullName,
            amount: quote.total.formattedCurrency(),
          //  date: quote.date?.formatted(date: .abbreviated, time: .omitted) ?? "",
            date: quote.date.map { formattedDateFR($0) } ?? "",
            statusMenu: AnyView(QuoteStatusMenu(quote: quote)),
            onDelete: onDelete,
            onTap: onEdit
        )
    }
}


struct PercentagePopover: View {
    @Binding var customPercentage: Double
    let onValidate: () -> Void
    let onCancel: () -> Void
    let quote: QuoteEntity
    let isAutoEntrepreneur: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Quel pourcentage souhaitez-vous facturer ?")
                .font(.headline)

            HStack {
                TextField("Pourcentage", value: $customPercentage, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                Text("%")
            }

            let montant = quote.total * (customPercentage / 100)

            VStack(alignment: .leading, spacing: 4) {
                Text("Montant HT : \(montant.formattedCurrency())")
                
                if isAutoEntrepreneur {
                    Text("TVA : 0 €")
                    Text("Total TTC : \(montant.formattedCurrency())")
                } else {
                    let tva = montant * 0.2
                    Text("TVA : \(tva.formattedCurrency())")
                    Text("Total TTC : \((montant + tva).formattedCurrency())")
                }
            }
            .font(.footnote)
            .padding(.top, 4)

            HStack {
                Spacer()
                Button("Annuler", action: onCancel)
                Button("Créer la facture", action: onValidate)
            }
        }
        .padding()
        .frame(width: 280)
    }
}

extension QuoteEntity {
    var clientFullName: String {
        [clientFirstName, clientLastName].compactMap { $0 }.joined(separator: " ")
    }
}

func generateNextInvoiceNumber(context: NSManagedObjectContext) -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMM"
    let ym = formatter.string(from: date)

    let fetchRequest: NSFetchRequest<Invoice> = Invoice.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "invoiceNumber BEGINSWITH %@", "FAC-\(ym)")

    do {
        let existing = try context.fetch(fetchRequest)
        let numbers = existing.compactMap { invoice -> Int? in
            guard let comps = invoice.invoiceNumber?.split(separator: "-"), comps.count == 3 else {
                return nil
            }
            return Int(comps[2])
        }
        let next = (numbers.max() ?? 0) + 1
        return String(format: "FAC-%@-%03d", ym, next)
    } catch {
        return String(format: "FAC-%@-%03d", ym, 1)
    }
}

struct DocumentRowView: View {
    let icon: String
    let number: String
    let clientName: String
    let amount: String
    let date: String
    let statusMenu: AnyView
    let onDelete: (() -> Void)?
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(.blue)

                    Text(number)
                        .fontWeight(.bold)

                    Text(clientName)
                        .lineLimit(1)

                    Spacer()

                    Text(amount)
                        .font(.system(size: 13))

                    Text(date)
                        .foregroundColor(.gray)

                    statusMenu
                }
            }
            .buttonStyle(PlainButtonStyle())

            if let onDelete = onDelete {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Supprimer")
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(6)
    }
}
func formattedDateFR(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr_FR")
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
}
