import SwiftUI

struct EditArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    var article: Article

    @State private var name: String
    @State private var type: String
    @State private var unit: String
    @State private var cost: Double
    @State private var price: Double
    @State private var marginPercentage: Double

    private let types = ["Matériaux", "Main d'œuvre", "Ouvrage"]
    private let units = ["hr", "u", "m", "m²", "m3", "ml", "l", "kg", "Forfait"]

    init(article: Article) {
        self.article = article
        _name = State(initialValue: article.name ?? "")
        _type = State(initialValue: article.type ?? "Matériaux")
        _unit = State(initialValue: article.unit ?? "u")
        _cost = State(initialValue: article.cost)
        _price = State(initialValue: article.price)
        _marginPercentage = State(initialValue: article.marginPercentage)
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
                            TextField("", value: $cost, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }

                        HStack {
                            Text("Prix facturé (€ HT)")
                                .frame(width: 180, alignment: .leading)
                            TextField("", value: $price, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }

                        HStack {
                            Text("Marge (%)")
                                .frame(width: 180, alignment: .leading)
                            TextField("", value: $marginPercentage, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                    }
                }
            }

            HStack {
                Button("Annuler") { dismiss() }
                    .foregroundColor(.blue)

                Spacer()

                Button("Enregistrer") { saveChanges() }
                    .foregroundColor(.green)
            }
            .padding()
        }
        .padding()
        .onChange(of: cost) { _ in updatePriceFromMargin() }
        .onChange(of: price) { _ in updateMarginFromPrice() }
        .onChange(of: marginPercentage) { _ in updatePriceFromMargin() }
    }

    private func saveChanges() {
        article.name = name
        article.type = type
        article.unit = unit
        article.cost = cost
        article.price = price
        article.marginPercentage = marginPercentage

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Erreur lors de l'enregistrement : \(error)")
        }
    }

    private func updatePriceFromMargin() {
        price = cost * (1 + marginPercentage / 100)
    }

    private func updateMarginFromPrice() {
        if cost > 0 {
            marginPercentage = ((price / cost) - 1) * 100
        }
    }
}
