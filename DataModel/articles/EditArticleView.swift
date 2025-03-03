//
//  EditArticleView.swift
//  DataModel
//
//  Created by Quentin FABERES on 28/02/2025.
//


import SwiftUI

struct EditArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var type: String
    @State private var unit: String
    @State private var cost: String
    @State private var price: String
    @State private var marginPercentage: String
    @State private var marginAmount: String

    var article: Article

    init(article: Article) {
        self.article = article
        _name = State(initialValue: article.name ?? "")
        _type = State(initialValue: article.type ?? "Matériau")
        _unit = State(initialValue: article.unit ?? "u")
        _cost = State(initialValue: article.cost ?? "")
        _price = State(initialValue: article.price ?? "")
        _marginPercentage = State(initialValue: article.marginPercentage ?? "")
        _marginAmount = State(initialValue: article.marginAmount ?? "")
    }

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

            Text("Modifier l'article")
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
        article.name = name
        article.type = type
        article.unit = unit
        article.cost = cost
        article.price = price
        article.marginPercentage = marginPercentage
        article.marginAmount = marginAmount

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Erreur lors de l'enregistrement : \(error.localizedDescription)")
        }
    }
}