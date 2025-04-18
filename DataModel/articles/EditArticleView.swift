import SwiftUI

struct EditArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var article: Article

    @State private var name: String
    @State private var type: String
    @State private var unit: String
    @State private var costText: String
    @State private var priceText: String
    @State private var marginText: String

    private let types = ["Matériaux", "Main d'œuvre", "Ouvrage"]
    private let units = ["hr", "u", "m", "m²", "m3", "ml", "l", "kg", "Forfait"]

    init(article: Article) {
        self.article = article
        _name = State(initialValue: article.name ?? "")
        _type = State(initialValue: article.type ?? "Matériaux")
        _unit = State(initialValue: article.unit ?? "u")
        _costText = State(initialValue: String(format: "%.2f", article.cost))
        _priceText = State(initialValue: String(format: "%.2f", article.price))
        _marginText = State(initialValue: String(format: "%.2f", article.marginPercentage))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Modifier l'article")
                .font(.title)
                .bold()

            Form {
                Section(header: Text("Détails de l'article").bold()) {
                    TextField("Nom", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Picker("Unité", selection: $unit) {
                        ForEach(units, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Déboursé sec (€ HT)")
                                .frame(width: 180, alignment: .leading)
                            TextField("", text: $costText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                                .onChange(of: costText) { _ in updateMarginFromPrice() }
                        }

                        HStack {
                            Text("Prix facturé (€ HT)")
                                .frame(width: 180, alignment: .leading)
                            TextField("", text: $priceText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                                .onChange(of: priceText) { _ in updateMarginFromPrice() }
                        }

                        HStack {
                            Text("Marge (%)")
                                .frame(width: 180, alignment: .leading)
                            Text(marginText + " %")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            HStack {
                Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)

                Spacer()

                Button("Enregistrer") {
                    saveChanges()
                }
                .foregroundColor(.green)
            }
            .padding()
        }
        .padding()
    }

    private func updateMarginFromPrice() {
        guard let price = Double(priceText),
              let cost = Double(costText),
              cost > 0 else {
            marginText = "0.00"
            return
        }

        let margin = ((price / cost) - 1) * 100
        marginText = String(format: "%.2f", margin)
    }

    private func saveChanges() {
        guard let cost = Double(costText),
              let price = Double(priceText) else {
            print("❌ Erreur de conversion des champs numériques")
            return
        }

        let margin = ((price / cost) - 1) * 100

        article.name = name
        article.type = type
        article.unit = unit
        article.cost = cost
        article.price = price
        article.marginPercentage = margin

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("❌ Erreur lors de l'enregistrement : \(error)")
        }
    }
}
