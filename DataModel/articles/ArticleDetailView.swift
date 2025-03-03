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
            VStack(alignment: .leading, spacing: 10) {
                detailRow(label: "Nom", value: article.name)
                detailRow(label: "Type", value: article.type)
                detailRow(label: "Unité", value: article.unit)
                detailRow(label: "Déboursé sec", value: "\(article.cost ?? "0") € HT")
                detailRow(label: "Prix facturé", value: "\(article.price ?? "0") € HT")
                detailRow(label: "Marge", value: "\(article.marginPercentage ?? "0") %")
            }
            .padding(.horizontal)

            Spacer()

            // 📌 Boutons Modifier et Supprimer
            HStack {
                Button("✏️ Modifier") {
                    isEditing = true
                }
                .buttonStyle(.bordered)

                Button("🗑 Supprimer") {
                    showDeleteAlert = true
                }
                .foregroundColor(.red)
                .padding()
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
    private func detailRow(label: String, value: String?) -> some View {
        HStack {
            Text(label + ":")
                .bold()
            Spacer()
            Text(value ?? "Non renseigné")
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
