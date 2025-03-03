import SwiftUI

struct EditArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    var article: Article

    @State private var name: String
    @State private var type: String
    @State private var unit: String
    @State private var cost: String
    @State private var price: String
    @State private var marginPercentage: String

    init(article: Article) {
        self.article = article
        _name = State(initialValue: article.name ?? "")
        _type = State(initialValue: article.type ?? "")
        _unit = State(initialValue: article.unit ?? "")
        _cost = State(initialValue: "\(article.cost)")
        _price = State(initialValue: "\(article.price)")
        _marginPercentage = State(initialValue: "\(article.marginPercentage)")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Modifier l'article")
                .font(.title)
                .bold()

            Form {
                Section(header: Text("Détails de l'article").bold()) {
                    TextField("Nom", text: $name)
                    TextField("Type", text: $type)
                    TextField("Unité", text: $unit)
                    TextField("Déboursé sec (€ HT)", text: $cost)
                    TextField("Prix facturé (€ HT)", text: $price)
                    TextField("Marge (%)", text: $marginPercentage)
                }
            }

            HStack {
                Button("Annuler") {
                    dismiss()
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

    private func saveChanges() {
        article.name = name
        article.type = type
        article.unit = unit
        article.cost = Double(cost) ?? 0.0
        article.price = Double(price) ?? 0.0
        article.marginPercentage = Double(marginPercentage) ?? 0.0

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Erreur lors de l'enregistrement : \(error)")
        }
    }
}
