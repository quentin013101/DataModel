import SwiftUI

struct AddArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var type = "Matériaux" // Par défaut
    @State private var unit = "u" // Par défaut
    @State private var costString = ""
    @State private var priceString = ""
    @State private var marginString = ""
    @State private var isEditingPrice = false
    @State private var isEditingMargin = false

    private let types = ["Matériaux", "Main d'œuvre", "Ouvrage"]
    private let units = ["hr", "u", "m", "m²", "m3", "ml", "l", "kg"]

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

                    TextField("Déboursé sec (€ HT)", text: $costString)
                        .onChange(of: costString) { _ in updatePriceFromMargin() }

                    TextField("Prix facturé (€ HT)", text: $priceString, onEditingChanged: { editing in
                        isEditingPrice = editing
                        if !editing { updateMarginFromPrice() }
                    })

                    TextField("Marge (%)", text: $marginString, onEditingChanged: { editing in
                        isEditingMargin = editing
                        if !editing { updatePriceFromMargin() }
                    })
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
    }

    private func saveArticle() {
        let newArticle = Article(context: viewContext)
        newArticle.name = name
        newArticle.type = type
        newArticle.unit = unit
        newArticle.cost = Double(costString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        newArticle.price = Double(priceString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        newArticle.marginPercentage = Double(marginString.replacingOccurrences(of: ",", with: ".")) ?? 0.0

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Erreur lors de l'enregistrement : \(error)")
        }
    }

    private func updatePriceFromMargin() {
        guard !isEditingPrice else { return }
        if let cost = Double(costString.replacingOccurrences(of: ",", with: ".")),
           let margin = Double(marginString.replacingOccurrences(of: ",", with: ".")) {
            let newPrice = cost * (1 + margin / 100)
            priceString = formatNumber(newPrice)
        }
    }

    private func updateMarginFromPrice() {
        guard !isEditingMargin else { return }
        if let cost = Double(costString.replacingOccurrences(of: ",", with: ".")),
           let price = Double(priceString.replacingOccurrences(of: ",", with: ".")), cost > 0 {
            let newMargin = ((price / cost) - 1) * 100
            marginString = formatNumber(newMargin)
        }
    }

    private func formatNumber(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }
}
