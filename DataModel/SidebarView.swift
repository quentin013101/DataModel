import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: String
    @State private var showingSettings = false // ✅ État pour afficher les paramètres

    var body: some View {
        VStack {
            List {
                Section(header: Text("ACTIONS")) {
                    SidebarButton(title: "Créer un devis", tab: "devis", selectedTab: $selectedTab)
                    SidebarButton(title: "Créer une facture", tab: "facture", selectedTab: $selectedTab)
                }

                Section(header: Text("LISTE")) {
                    SidebarButton(title: "Devis / Factures", tab: "devisFactures", selectedTab: $selectedTab)
                    SidebarButton(title: "Clients", tab: "clients", selectedTab: $selectedTab)
                    SidebarButton(title: "Articles", tab: "articles", selectedTab: $selectedTab)
                }

                Section(header: Text("PILOTAGE")) {
                    SidebarButton(title: "Tableau de bord", tab: "dashboard", selectedTab: $selectedTab)
                    SidebarButton(title: "Tableau d’analyse", tab: "analysis", selectedTab: $selectedTab)
                }
            }
            .listStyle(SidebarListStyle())

            Spacer()

            // ✅ Bouton Paramètres en bas de la barre latérale
            Button(action: { showingSettings = true }) {
                HStack {
                    Image(systemName: "gearshape.fill")

                    Text("Paramètres")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .sheet(isPresented: $showingSettings) {
                ParametresView()
            }
        }
        .frame(minWidth: 250)
    }
}

// ✅ Composant SidebarButton pour éviter la répétition
struct SidebarButton: View {
    let title: String
    let tab: String
    @Binding var selectedTab: String

    var body: some View {
        Button(action: { selectedTab = tab }) {
            HStack {
                Text(title)
                    .foregroundColor(selectedTab == tab ? .blue : .primary)
                    .bold(selectedTab == tab)
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.leading, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SidebarView(selectedTab: .constant("clients"))
}
