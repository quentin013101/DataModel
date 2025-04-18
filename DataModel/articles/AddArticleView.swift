import SwiftUI

struct AddArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var type = "Matériaux"
    @State private var unit = "u"

    @State private var costText = ""
    @State private var priceText = ""
    @State private var marginText = "0.00"

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
                    saveArticle()
                }
                .foregroundColor(.green)
            }
            .padding()
        }
        .padding()
    }

    private func updateMarginFromPrice() {
        guard let price = Double(priceText),
              let cost = Double(costText), cost > 0 else {
            marginText = "0.00"
            return
        }

        let margin = ((price / cost) - 1) * 100
        marginText = String(format: "%.2f", margin)
    }

    private func saveArticle() {
        // Si cost est vide, on le remplit avec price
        if costText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            costText = priceText
        }

        guard let cost = Double(costText),
              let price = Double(priceText) else {
            print("❌ Erreur de conversion des champs numériques")
            return
        }

        let margin = ((price / cost) - 1) * 100

        let newArticle = Article(context: viewContext)
        newArticle.name = name
        newArticle.type = type
        newArticle.unit = unit
        newArticle.cost = cost
        newArticle.price = price
        newArticle.marginPercentage = margin

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Erreur lors de l'enregistrement : \(error)")
        }
    }
}
