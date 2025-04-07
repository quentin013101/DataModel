import SwiftUI
import CoreData

struct QuoteGroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTab: String
    @Binding var quoteToEdit: QuoteEntity?
    @Binding var invoiceToEdit: Invoice?

    let quote: QuoteEntity

    @State private var showPercentageInput = false
    @State private var invoiceToCreateType: InvoiceType?
    @State private var customPercentage: Double = 30
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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

            // 📄 Factures associées
            ForEach(quote.invoicesArray) { invoice in
                Button {
                    let invoice = createInvoice(from: quote, type: .finale)
                    invoiceToEdit = invoice
                    selectedTab = "facture"
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(invoice.invoiceNumber ?? "FAC")
                            .bold()
                        Text(quote.clientName ?? "—")
                        Spacer()
                        Text(invoice.totalTTC.formattedCurrency())
                        Text(invoice.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        InvoiceStatusMenu(invoice: invoice)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }

            // ➕ Menu Créer facture
            HStack {
                Spacer()
                Menu {
                    Button("Créer facture d’acompte") {
                        invoiceToCreateType = .acompte
                        showPercentageInput = true
                    }
                    Button("Créer facture intermédiaire") {
                        invoiceToCreateType = .intermediaire
                        showPercentageInput = true
                    }
                    Button("Créer facture finale") {
                        let invoice = createInvoice(from: quote, type: .finale)
                        openInvoice(invoice)
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
        .popover(isPresented: $showPercentageInput) {
            PercentagePopover(
                customPercentage: $customPercentage,
                onValidate: {
                    if let type = invoiceToCreateType {
                        let invoice = createInvoice(from: quote, type: type, percentage: customPercentage)
                        openInvoice(invoice)
                    }
                    showPercentageInput = false
                    invoiceToCreateType = nil
                },
                onCancel: {
                    showPercentageInput = false
                    invoiceToCreateType = nil
                },
                quote: quote
            )
        }
    }

    func createInvoice(from quote: QuoteEntity, type: InvoiceType, percentage: Double? = nil) -> Invoice {
        let invoice = Invoice(context: viewContext)
        invoice.id = UUID()
        invoice.date = Date()
        invoice.status = "Brouillon"
        invoice.quote = quote
        invoice.isPartial = (type != .finale)
        invoice.invoiceNumber = generateNextInvoiceNumber(context: viewContext)
        invoice.referenceQuoteNumber = quote.devisNumber
        invoice.referenceQuoteDate = quote.date
        invoice.referenceQuoteTotal = quote.total

        if type != .finale {
            let p = percentage ?? 30
            invoice.partialPercentage = p
            invoice.partialAmount = quote.total * (p / 100)
            invoice.totalHT = invoice.partialAmount
            invoice.tva = invoice.totalHT * 0.2
            invoice.totalTTC = invoice.totalHT + invoice.tva
            invoice.invoiceNote = defaultInfoText(for: invoice)
        } else {
            invoice.partialAmount = quote.total
            invoice.totalHT = quote.sousTotal
            invoice.tva = invoice.totalHT * 0.2
            invoice.totalTTC = invoice.totalHT + invoice.tva
            invoice.invoiceArticlesData = quote.quoteArticlesData
        }

        do {
            try viewContext.save()
            print("✅ Facture créée : \(invoice.invoiceNumber ?? "-")")
            return invoice
        } catch {
            print("❌ Erreur lors de la création de la facture : \(error)")
            return invoice
        }
    }

    func openInvoice(_ invoice: Invoice) {
        // ⏳ Délai léger pour laisser le temps à SwiftUI de prendre en compte invoiceToEdit
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
        Button(action: onEdit) {
            HStack {
                Image(systemName: "doc.text")
                Text(quote.devisNumber ?? "DEV").bold()
                Text(quote.clientName ?? "—")
                Spacer()
                Text(quote.total.formattedCurrency())
                Text(quote.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                HStack(spacing: 8) {
                    QuoteStatusMenu(quote: quote)
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PercentagePopover: View {
    @Binding var customPercentage: Double
    let onValidate: () -> Void
    let onCancel: () -> Void
    let quote: QuoteEntity

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
                Text("TVA : \((montant * 0.2).formattedCurrency())")
                Text("Total TTC : \((montant * 1.2).formattedCurrency())")
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
func generateNextInvoiceNumber(context: NSManagedObjectContext) -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
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
