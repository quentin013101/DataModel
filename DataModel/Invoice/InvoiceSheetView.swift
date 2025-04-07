import SwiftUI

struct InvoiceSheetView: View {
    @ObservedObject var viewModel: InvoiceViewModel
    @State private var documentHeight: CGFloat = 842

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                ZStack {
                    Color.white
                        .cornerRadius(8)
                        .shadow(radius: 3)

                    VStack(alignment: .leading, spacing: 16) {
                        // 🔹 En-tête
                        HStack {
                            Text(viewModel.invoice.invoiceNumber ?? "Facture")
                                .font(.title)
                                .bold()
                            Spacer()
                            DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                                .labelsHidden()
                        }

                        Divider()

                        // 🔸 Texte explicatif
                        TextField("Texte explicatif…", text: $viewModel.note, axis: .vertical)
                            .textFieldStyle(.roundedBorder)

                        Divider()

                        // 🧾 Lignes modifiables
                        VStack(spacing: 8) {
                            ForEach(viewModel.articles.indices, id: \.self) { index in
                                HStack {
                                    TextField("Désignation", text: Binding(
                                        get: { viewModel.articles[index].designation },
                                        set: { viewModel.articles[index].designation = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)

                                    Spacer()

                                    TextField("PU HT", value: Binding(
                                        get: { viewModel.articles[index].unitPrice },
                                        set: { viewModel.articles[index].unitPrice = $0 }
                                    ), format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)

                                    Button(role: .destructive) {
                                        viewModel.articles.remove(at: index)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }

                            Button {
                                viewModel.articles.append(QuoteArticle(
                                    designation: "",
                                    quantity: 1,
                                    unit: "u",
                                    unitPrice: 0.0,
                                    lineType: .article
                                ))
                            } label: {
                                Label("Ajouter une ligne", systemImage: "plus")
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 6)
                        }

                        Divider()

                        // 💶 Totaux
                        VStack(alignment: .trailing, spacing: 4) {
                            if viewModel.totalPreviouslyInvoiced > 0 {
                                Text("Déjà facturé : \(viewModel.totalPreviouslyInvoiced.formattedCurrency())")
                                    .foregroundColor(.secondary)
                            }

                            Text("Total HT : \(viewModel.totalHT.formattedCurrency())")
                            Text("TVA : \(viewModel.tva.formattedCurrency())")
                            Text("Total TTC : \(viewModel.totalTTC.formattedCurrency())")
                                .bold()
                        }

                        Spacer()
                    }
                    .padding()
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    documentHeight = geo.size.height
                                }
                                .onChange(of: geo.size.height) { new in
                                    documentHeight = new
                                }
                        }
                    )
                }
                .frame(width: 595, height: max(documentHeight, 842))
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.gray.opacity(0.2))
        .frame(maxWidth: .infinity)
    }
}

//extension Double {
//    func formattedCurrency() -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = "EUR"
//        formatter.maximumFractionDigits = 2
//        return formatter.string(from: NSNumber(value: self)) ?? "€0.00"
//    }
//}
