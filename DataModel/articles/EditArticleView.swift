import SwiftUI

struct EditArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    var article: Article

    @State private var name: String
    @State private var type: String
    @State private var unit: String
    @State private var costString: String
    @State private var priceString: String
    @State private var marginString: String
    @State private var isEditingPrice = false
    @State private var isEditingMargin = false

    private let types = ["Matériaux", "Main d'œuvre", "Ouvrage"]
    private let units = ["hr", "u", "m", "m²", "m3", "ml", "l", "kg"]

    init(article: Article) {
        self.article = article
        _name = State(initialValue: article.name ?? "")
        _type = State(initialValue: article.type ?? "Matériaux")
        _unit = State(initialValue: article.unit ?? "u")
        _costString = State(initialValue: EditArticleView.formatNumber(article.cost))
        _priceString = State(initialValue: EditArticleView.formatNumber(article.price))
        _marginString = State(initialValue: EditArticleView.formatNumber(article.marginPercentage))
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

                    TextField("Déboursé sec (€ HT)", text: $costString)
                        .onChange(of: costString) { _ in updatePriceFromMargin() }

                    TextField("Prix facturé (€ HT)", text: $priceString, onEditingChanged: { editing in
                        isEditingPrice = editing
                        if !editing { updateMarginFromPrice() } // ✅ Mise à jour seulement quand l'utilisateur finit d'écrire
                    })

                    TextField("Marge (%)", text: $marginString, onEditingChanged: { editing in
                        isEditingMargin = editing
                        if !editing { updatePriceFromMargin() } // ✅ Mise à jour seulement quand l'utilisateur finit d'écrire
                    })
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
    }

    private func saveChanges() {
        article.name = name
        article.type = type
        article.unit = unit
        article.cost = Double(costString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        article.price = Double(priceString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        article.marginPercentage = Double(marginString.replacingOccurrences(of: ",", with: ".")) ?? 0.0

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Erreur lors de l'enregistrement : \(error)")
        }
    }

    private func updatePriceFromMargin() {
        guard !isEditingPrice else { return } // ✅ Ne pas modifier si l'utilisateur tape un prix
        if let cost = Double(costString.replacingOccurrences(of: ",", with: ".")),
           let margin = Double(marginString.replacingOccurrences(of: ",", with: ".")) {
            let newPrice = cost * (1 + margin / 100)
            priceString = EditArticleView.formatNumber(newPrice)
        }
    }

    private func updateMarginFromPrice() {
        guard !isEditingMargin else { return } // ✅ Ne pas modifier si l'utilisateur tape une marge
        if let cost = Double(costString.replacingOccurrences(of: ",", with: ".")),
           let price = Double(priceString.replacingOccurrences(of: ",", with: ".")), cost > 0 {
            let newMargin = ((price / cost) - 1) * 100
            marginString = EditArticleView.formatNumber(newMargin)
        }
    }

    static func formatNumber(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }
}
