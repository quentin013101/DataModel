//
//  ArticleSelectionView.swift
//  DataModel
//
//  Created by Quentin FABERES on 03/03/2025.
//
import SwiftUI
import CoreData


struct ArticleSelectionView: View {
    @Binding var selectedArticles: [Article]
    @FetchRequest(entity: Article.entity(), sortDescriptors: []) var articles: FetchedResults<Article>

    var body: some View {
        List(articles, id: \.self) { article in
            Button(action: { selectedArticles.append(article) }) {
                Text(article.name ?? "Inconnu")
            }
        }
    }
}
