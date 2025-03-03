import SwiftUI

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var viewContext
        @Binding var selectedTab: String // 🔹 Gère la sélection active
        @State private var showingNewQuote = false // ✅ Ajout de l'état pour afficher la vue de devis


    var body: some View {
        List {
            Section(header: Text("ACTIONS")) {
                Button(action: { showingNewQuote = true }) {
                                    SidebarItem(title: "Créez un devis")
                                }
                                .buttonStyle(PlainButtonStyle()) // ✅ Supprime l'effet par défaut
                                
                SidebarItem(title: "Créez une facture")
            }

            Section(header: Text("LISTE")) {
                SidebarItem(title: "Devis / Factures")

                // ✅ Bouton pour "Clients" (décalé et toute la largeur cliquable)
                Button(action: { selectedTab = "clients" }) {
                    HStack {
                        Text("Clients")
                            .foregroundColor(selectedTab == "clients" ? .blue : .primary)
                            .bold(selectedTab == "clients")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8) // 🔹 Décalage vers la gauche
                    .frame(maxWidth: .infinity, alignment: .leading) // 🔹 Toute la ligne cliquable
                    .background(selectedTab == "clients" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8) // ✅ Angles arrondis
                    .contentShape(Rectangle()) // 🔥 Rend tout cliquable
                }
                .buttonStyle(PlainButtonStyle()) // ❌ Supprime l'effet par défaut

                // ✅ Bouton pour "Articles" (décalé et toute la largeur cliquable)
                Button(action: { selectedTab = "articles" }) {
                    HStack {
                        Text("Articles")
                            .foregroundColor(selectedTab == "articles" ? .blue : .primary)
                            .bold(selectedTab == "articles")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8) // 🔹 Décalage vers la gauche
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTab == "articles" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8) // ✅ Angles arrondis
                    .contentShape(Rectangle()) // 🔥 Rend tout cliquable
                }
                .buttonStyle(PlainButtonStyle()) // ❌ Supprime l'effet par défaut
            }

            Section(header: Text("PILOTAGE")) {
                SidebarItem(title: "Tableau de bord")
                SidebarItem(title: "Tableau d’analyse")
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 250)
    }
}

// ✅ Correction de SidebarItem (avec léger décalage)
struct SidebarItem: View {
    let title: String

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.leading, 8) // 🔹 Décalage vers la gauche
    }
}

#Preview {
    SidebarView(selectedTab: .constant("clients"))
}
