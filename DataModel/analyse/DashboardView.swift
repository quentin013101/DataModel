import SwiftUI
import CoreData
import Charts

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)],
        animation: .default
    ) private var allQuotes: FetchedResults<QuoteEntity>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)],
        animation: .default
    ) private var allInvoices: FetchedResults<Invoice>

    @Binding var selectedTab: String
    @Binding var quoteToEdit: QuoteEntity?
    @Binding var invoiceToEdit: Invoice?
    @Binding var selectedQuoteForInvoice: QuoteEntity?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Bonjour \(CompanyInfo.loadFromUserDefaults().artisanName), bienvenue sur votre application")
                    .font(.title)
                    .padding(.top)

                Button("Créer un nouveau devis") {
                    selectedTab = "devis"
                }
                .padding()
                .buttonStyle(.borderless)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                HStack(alignment: .top, spacing: 20) {
                    recentQuotesSection
                    recentInvoicesSection
                }

                HStack(alignment: .top, spacing: 20) {
                    pieChartWithDetails(
                        title: "Devis en attente de validation",
                        items: allQuotes.filter { $0.status == "finalisé" },
                        color: .blue,
                        totalCalculator: \QuoteEntity.estimatedTotalTTC,
                        onSelect: { quote in
                            quoteToEdit = quote
                            selectedTab = "devis"
                        }
                    )

                    pieChartWithDetails(
                        title: "Factures en attente de paiement",
                        items: allInvoices.filter { ($0.status ?? "").lowercased() == "envoyée" },
                        color: .orange,
                        totalCalculator: \Invoice.totalTTC,
                        onSelect: { invoice in
                            invoiceToEdit = invoice
                            selectedQuoteForInvoice = invoice.quote
                            selectedTab = "facture"
                        }
                    )
                }
            }
            .padding()
        }
    }

    func pieChartWithDetails<T: Identifiable>(
        title: String,
        items: [T],
        color: Color,
        totalCalculator: KeyPath<T, Double>,
        onSelect: @escaping (T) -> Void
    ) -> some View {
        let total = items.reduce(0.0) { $0 + $1[keyPath: totalCalculator] }

        return VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            HStack(alignment: .center, spacing: 20) {
                if #available(macOS 14.0, *) {
                    Chart {
                        ForEach(items.prefix(5)) { item in
                            let value = item[keyPath: totalCalculator]
                            SectorMark(
                                angle: .value("Montant", value),
                                innerRadius: .ratio(0.5),
                                angularInset: 1
                            )
                            .foregroundStyle(color)
                        }
                    }
                    .frame(width: 120, height: 120)
                } else {
                    VStack {
                        Text("Camembert non disponible")
                            .foregroundColor(.gray)
                            .italic()
                            .frame(width: 120, height: 120)
                            .multilineTextAlignment(.center)
                    }
                }

                VStack(alignment: .leading) {
                    Text("\(items.count) éléments en attente")
                    Text("Total : \(total, specifier: "%.2f") € TTC")
                        .bold()
                    ForEach(items.prefix(3)) { item in
                        Button(action: { onSelect(item) }) {
                            if let quote = item as? QuoteEntity {
                                Text("\(quote.dashboardClientFullName) — \(quote.projectName ?? "")")
                            } else if let invoice = item as? Invoice {
                                Text("\(invoice.quote?.dashboardClientFullName ?? "-") — \(invoice.projectName ?? "")")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(.footnote)
                    }
                }
            }
        }
    }

    var recentQuotesSection: some View {
        VStack(alignment: .leading) {
            Label("Derniers devis modifiés", systemImage: "doc")
                .font(.headline)
            ForEach(allQuotes.prefix(3)) { quote in
                Button {
                    quoteToEdit = quote
                    selectedTab = "devis"
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(quote.dashboardClientFullName)
                            Text(quote.projectName ?? "").font(.subheadline)
                        }
                        Spacer()
                        Text("€ \(quote.estimatedTotalTTC, specifier: "%.0f")")
                            .bold()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    var recentInvoicesSection: some View {
        VStack(alignment: .leading) {
            Label("Dernières factures modifiées", systemImage: "doc.text")
                .font(.headline)
            ForEach(allInvoices.prefix(3)) { invoice in
                Button {
                    invoiceToEdit = invoice
                    selectedQuoteForInvoice = invoice.quote
                    selectedTab = "facture"
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(invoice.quote?.dashboardClientFullName ?? "—")
                            Text(invoice.projectName ?? "").font(.subheadline)
                        }
                        Spacer()
                        Text("€ \(invoice.totalTTC, specifier: "%.0f")")
                            .bold()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Extensions

extension QuoteEntity {
    var estimatedTotalTTC: Double {
        let remise = remiseIsPercentage ? (sousTotal * remiseValue / 100.0) : remiseAmount
        let htAfterRemise = sousTotal - remise
        let legalForm = CompanyInfo.loadFromUserDefaults().legalForm ?? ""
        let tva = legalForm.lowercased().contains("auto") ? 0 : htAfterRemise * 0.2
        return htAfterRemise + tva
    }

    var dashboardClientFullName: String {
        [clientCivility, clientFirstName, clientLastName]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
