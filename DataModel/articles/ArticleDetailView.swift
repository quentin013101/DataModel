import SwiftUI

struct ArticleDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var isEditing = false // 🔹 Active/Désactive la modification
    @State private var showDeleteAlert = false // 🔹 Gère l'affichage de l'alerte de suppression

    var article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 🔹 En-tête avec bouton Fermer
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
                .padding()
            }

            Text("Détails de l'article")
                .font(.title)
                .bold()
                .padding(.bottom, 10)

            // 📌 Informations sur l'article
            // 📌 Informations sur l'article
            VStack(alignment: .leading, spacing: 10) {
                detailRow(label: "Nom", value: article.name ?? "Non renseigné")
                detailRow(label: "Type", value: article.type ?? "Non renseigné")
                detailRow(label: "Unité", value: article.unit ?? "Non renseigné")
                detailRow(label: "Déboursé sec", value: String(format: "%.2f € HT", article.cost ?? 0.0))
                detailRow(label: "Prix facturé", value: String(format: "%.2f € HT", article.price ?? 0.0))
                detailRow(label: "Marge", value: String(format: "%.2f %%", article.marginPercentage ?? 0.0))
            }
            .padding(.horizontal)

            Spacer()

            // 📌 Boutons Modifier et Supprimer
            HStack {
                Button(action: { isEditing = true }) {
                    Text("Modifier")
                        .bold()
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }

                Button(action: { showDeleteAlert = true }) {
                    Text("Supprimer")
                        .bold()
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                .alert("Supprimer cet article ?", isPresented: $showDeleteAlert) {
                    Button("Annuler", role: .cancel) {}
                    Button("Supprimer", role: .destructive) {
                        deleteArticle()
                    }
                } message: {
                    Text("Cette action est irréversible.")
                }
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 600)
        .padding()
        .sheet(isPresented: $isEditing) {
            EditArticleView(article: article)
        }
    }

    // 🔹 Fonction pour afficher une ligne de détail
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .bold()
                .frame(width: 200, alignment: .leading)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }

    // 🔹 Suppression de l'article
    private func deleteArticle() {
        viewContext.delete(article)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Erreur lors de la suppression : \(error.localizedDescription)")
        }
    }
}
