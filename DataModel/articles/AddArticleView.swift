import SwiftUI

struct AddArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var type = "Matériaux" // Valeur par défaut
    @State private var unit = "u" // Valeur par défaut

    @State private var cost: Double = 0.0
    @State private var price: Double = 0.0
    @State private var marginPercentage: Double = 0.0

    private let types = ["Matériaux", "Main d'œuvre", "Ouvrage"]
    private let units = ["hr", "u", "m", "m²", "m3", "ml", "l", "kg", "Forfait"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Ajouter un Article")
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

                Button("Enregistrer") { saveArticle() }
                    .foregroundColor(.green)
            }
            .padding()
        }
        .padding()
        .onChange(of: cost) { _ in updatePriceFromMargin() }
        .onChange(of: price) { _ in updateMarginFromPrice() }
        .onChange(of: marginPercentage) { _ in updatePriceFromMargin() }
    }

    private func saveArticle() {
        let newArticle = Article(context: viewContext)
        newArticle.name = name
        newArticle.type = type
        newArticle.unit = unit
        newArticle.cost = cost
        newArticle.price = price
        newArticle.marginPercentage = marginPercentage

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
