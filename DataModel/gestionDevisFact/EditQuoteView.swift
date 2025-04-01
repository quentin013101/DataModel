//
//  EditQuoteView.swift
//  DataModel
//
//  Created by Quentin FABERES on 01/04/2025.
//

import SwiftUI
struct EditQuoteView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss

    @State private var quoteArticles: [QuoteArticle] = []
    @State private var projectName: String = ""
    @State private var clientName: String = ""
    @State private var devisNumber: String = ""

    var quoteEntity: QuoteEntity

    init(quoteEntity: QuoteEntity) {
        self.quoteEntity = quoteEntity
        // initialisation différée dans .onAppear
    }

    var body: some View {
        Form {
            TextField("Nom du client", text: $clientName)
            TextField("Nom du projet", text: $projectName)
            TextField("Numéro de devis", text: $devisNumber)

            // Affiche les articles pour test
            List(quoteArticles, id: \.id) { article in
                Text(article.comment ?? "Article")
            }

            Button("Enregistrer les modifications") {
                saveModifications()
                dismiss()
            }
            Button("Annuler") {
                dismiss()
            }

        }
        .onAppear {
            loadQuote()
        }
    }

    func loadQuote() {
        clientName = quoteEntity.clientName ?? ""
        projectName = quoteEntity.projectName ?? ""
        devisNumber = quoteEntity.devisNumber ?? ""

        if let data = quoteEntity.quoteArticlesData,
           let articles = try? JSONDecoder().decode([QuoteArticle].self, from: data) {
            quoteArticles = articles
        }
    }

    func saveModifications() {
        quoteEntity.clientName = clientName
        quoteEntity.projectName = projectName
        quoteEntity.devisNumber = devisNumber
        quoteEntity.quoteArticlesData = try? JSONEncoder().encode(quoteArticles)

        do {
            try context.save()
            dismiss()
        } catch {
            print("❌ Erreur de sauvegarde : \(error)")
        }
    }
}
