//
//  SidebarView.swift
//  DataModel
//
//  Created by Quentin FABERES on 27/02/2025.
//


import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            Section(header: Text("ACTIONS")) {
                SidebarItem(title: "Créez un devis")
                SidebarItem(title: "Créez une facture")
                SidebarItem(title: "Enregistrez un paiement")
                SidebarItem(title: "Validez vos paiements")
                SidebarItem(title: "Relancez une facture")
                SidebarItem(title: "Créez un document")
            }
            
            Section(header: Text("LISTE")) {
                SidebarItem(title: "Documents")
                SidebarItem(title: "Clients", isSelected: true)
                SidebarItem(title: "Articles")
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

struct SidebarItem: View {
    let title: String
    var isSelected: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(isSelected ? .blue : .primary)
            Spacer()
        }
        .padding(.vertical, 5)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(5)
    }
}

#Preview {
    SidebarView()
}