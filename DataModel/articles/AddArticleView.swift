import SwiftUI

struct AddArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var type = "Matériau"
    @State private var unit = "u"
    @State private var cost = ""
    @State private var price = ""
    @State private var marginPercentage = ""
    @State private var marginAmount = ""

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
                .padding()
            }

            Text("Créer un article")
                .font(.title)
                .bold()
                .padding(.bottom, 10)

            Form {
                TextField("Nom", text: $name)
                
                Picker("Type", selection: $type) {
                    Text("Matériau").tag("Matériau")
                    Text("Main d'œuvre").tag("Main d'œuvre")
                    Text("Ouvrage").tag("Ouvrage")
                }
                .pickerStyle(SegmentedPickerStyle())

                TextField("Unité", text: $unit)
                TextField("Déboursé sec", text: $cost)
                TextField("Prix facturé", text: $price)
                TextField("Marge (%)", text: $marginPercentage)
                TextField("Marge (€)", text: $marginAmount)
            }

            Spacer()

            Button("💾 Enregistrer") {
                saveArticle()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }

    private func saveArticle() {
        let newArticle = Article(context: viewContext)
        newArticle.name = name
        newArticle.type = type
        newArticle.unit = unit
        newArticle.cost = cost
        newArticle.price = price
        newArticle.marginPercentage = marginPercentage
        newArticle.marginAmount = marginAmount

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Erreur lors de l'enregistrement : \(error.localizedDescription)")
        }
    }
}
