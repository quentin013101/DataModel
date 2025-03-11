//
//  DevisLineRowHoverEditable.swift
//  DataModel
//
//  Created by Quentin FABERES on 11/03/2025.
//
import SwiftUI
import AppKit

struct DevisLineRowHoverEditable: View {
    let index: Int
    let lineNumber: String
    @Binding var quoteArticle: QuoteArticle   // <-- Binding pour éditer
    let isAutoEntrepreneur: Bool

    var onDelete: () -> Void
    var onMoveUp: () -> Void
    var onMoveDown: () -> Void

    @State private var isHovering = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // Contenu principal
            HStack(spacing: 0) {
                switch quoteArticle.lineType {
                case .category:
                    categoryRow
                case .pageBreak:
                    pageBreakRow
                case .article:
                    articleRow
                }
            }

            // Au survol, on affiche les flèches
            if isHovering {
                HStack(spacing: 8) {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up")
                    }
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down")
                    }
                }
                .padding(.trailing, 8)
            }
        }
        .onHover { hover in
            isHovering = hover
        }
    }

    // MARK: - Category row (éditable)
    private var categoryRow: some View {
        HStack(spacing: 0) {
            Text(lineNumber)
                .frame(width: 30, alignment: .leading)
            // Édition du commentaire (catégorie)
            TextField("Catégorie", text: Binding(
                get: { quoteArticle.comment ?? "" },
                set: { quoteArticle.comment = $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
        }
    }

    // MARK: - PageBreak row
    private var pageBreakRow: some View {
        HStack {
            Text("---- SAUT DE PAGE ----")
                .frame(maxWidth: .infinity)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Article row (éditable)
    private var articleRow: some View {
        HStack(spacing: 0) {
            // N°
            Text(lineNumber)
                .frame(width: 30, alignment: .leading)

            // Désignation
            TextField("Désignation", text: Binding(
                get: { quoteArticle.article?.name ?? "" },
                set: { newVal in
                    quoteArticle.article?.name = newVal
                }
            ))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 4)
            .textFieldStyle(.roundedBorder)

            // Quantité
            TextField("", value: Binding(
                get: { Double(quoteArticle.quantity) },
                set: { newVal in
                    quoteArticle.quantity = Int16(newVal)
                }
            ), format: .number)
            .frame(width: 40, alignment: .center)
            .multilineTextAlignment(.trailing)
            .textFieldStyle(.roundedBorder)

            // Prix unitaire
            TextField("", value: Binding(
                get: { quoteArticle.article?.price ?? 0.0 },
                set: { newVal in
                    quoteArticle.article?.price = newVal
                }
            ), format: .number)
            .frame(width: 60, alignment: .trailing)
            .multilineTextAlignment(.trailing)
            .textFieldStyle(.roundedBorder)

            // TVA
            let tvaRate = isAutoEntrepreneur ? 0.0 : 0.20
            Text(String(format: "%.0f%%", tvaRate * 100))
                .frame(width: 50, alignment: .trailing)

            // Total
            let total = Double(quoteArticle.quantity) * (quoteArticle.article?.price ?? 0.0) * (1 + tvaRate)
            Text(String(format: "%.2f", total))
                .frame(width: 70, alignment: .trailing)
        }
    }
}
