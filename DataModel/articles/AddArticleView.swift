import SwiftUI

struct AddArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var type = ""
    @State private var unit = ""
    @State private var cost = ""
    @State private var price = ""
    @State private var marginPercentage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Ajouter un Article")
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
                    saveArticle()
                }
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
        newArticle.cost = Double(cost) ?? 0.0
        newArticle.price = Double(price) ?? 0.0
        newArticle.marginPercentage = Double(marginPercentage) ?? 0.0

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Erreur lors de l'enregistrement : \(error)")
        }
    }
}
