import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: String

    var body: some View {
        List {
            Section(header: Text("ACTIONS")) {
                Button(action: { selectedTab = "devis" }) {
                    HStack {
                        Text("Créer un devis")
                            .foregroundColor(selectedTab == "devis" ? .blue : .primary)
                            .bold(selectedTab == "devis")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTab == "devis" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { selectedTab = "facture" }) {
                    HStack {
                        Text("Créer une facture")
                            .foregroundColor(selectedTab == "facture" ? .blue : .primary)
                            .bold(selectedTab == "facture")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTab == "facture" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }

            Section(header: Text("LISTE")) {
                Button(action: { selectedTab = "devisFactures" }) {
                    HStack {
                        Text("Devis / Factures")
                            .foregroundColor(selectedTab == "devisFactures" ? .blue : .primary)
                            .bold(selectedTab == "devisFactures")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTab == "devisFactures" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { selectedTab = "clients" }) {
                    HStack {
                        Text("Clients")
                            .foregroundColor(selectedTab == "clients" ? .blue : .primary)
                            .bold(selectedTab == "clients")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTab == "clients" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { selectedTab = "articles" }) {
                    HStack {
                        Text("Articles")
                            .foregroundColor(selectedTab == "articles" ? .blue : .primary)
                            .bold(selectedTab == "articles")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTab == "articles" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }

            Section(header: Text("PILOTAGE")) {
                Button(action: { selectedTab = "dashboard" }) {
                    HStack {
                        Text("Tableau de bord")
                            .foregroundColor(selectedTab == "dashboard" ? .blue : .primary)
                            .bold(selectedTab == "dashboard")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTab == "dashboard" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { selectedTab = "analysis" }) {
                    HStack {
                        Text("Tableau d’analyse")
                            .foregroundColor(selectedTab == "analysis" ? .blue : .primary)
                            .bold(selectedTab == "analysis")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTab == "analysis" ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 250)
    }
}

#Preview {
    SidebarView(selectedTab: .constant("clients"))
}
