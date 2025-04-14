//
//  EditQuoteView.swift
//  DataModel
//
//  Created by Quentin FABERES on 01/04/2025.
//

import SwiftUI
struct EditQuoteView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    @State private var quoteArticles: [QuoteArticle] = []
    @State private var projectName: String = ""
    @State private var clientFirstName: String = ""
    @State private var clientLastName: String = ""
    @State private var clientCivility: String = ""
    @State private var devisNumber: String = ""

    var quoteEntity: QuoteEntity

    init(quoteEntity: QuoteEntity) {
        self.quoteEntity = quoteEntity
        // initialisation différée dans .onAppear
    }

    var body: some View {
        Form {
            TextField("Prénom", text: $clientFirstName)
            TextField("Nom", text: $clientLastName)
            TextField("Nom du projet", text: $projectName)
            TextField("Numéro de devis", text: $devisNumber)

            // Affiche les articles pour test
            List(quoteArticles, id: \.id) { article in
                Text(article.comment ?? "Article")
            }

            Button("Enregistrer les modifications") {
                saveModifications()
                presentationMode.wrappedValue.dismiss()
            }
            Button("Annuler") {
                presentationMode.wrappedValue.dismiss()
            }

        }
        .onAppear {
            loadQuote()
        }
    }

    func loadQuote() {
        clientCivility = quoteEntity.clientCivility ?? ""
        clientFirstName = quoteEntity.clientFirstName ?? ""
        clientLastName = quoteEntity.clientLastName ?? ""
        projectName = quoteEntity.projectName ?? ""
        devisNumber = quoteEntity.devisNumber ?? ""

        if let data = quoteEntity.quoteArticlesData,
           let articles = try? JSONDecoder().decode([QuoteArticle].self, from: data) {
            quoteArticles = articles
        }
    }

    func saveModifications() {
        quoteEntity.clientCivility = clientCivility
        quoteEntity.clientFirstName = clientFirstName
        quoteEntity.clientLastName = clientLastName
        quoteEntity.projectName = projectName
        quoteEntity.devisNumber = devisNumber
        quoteEntity.quoteArticlesData = try? JSONEncoder().encode(quoteArticles)

        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("❌ Erreur de sauvegarde : \(error)")
        }
    }
}
