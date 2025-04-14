//
//  InvoiceStatusMenu.swift
//  DataModel
//
//  Created by Quentin FABERES on 04/04/2025.
//


import SwiftUI
struct InvoiceStatusMenu: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var invoice: Invoice

    var statusEnum: InvoiceStatus {
        InvoiceStatus(rawValue: invoice.status ?? "") ?? .brouillon
    }

    var body: some View {
        Menu {
            ForEach(InvoiceStatus.allCases, id: \.self) { status in
                Button {
                    invoice.status = status.rawValue
                    try? viewContext.save()
                } label: {
                    Label(status.rawValue, systemImage: status.icon)
                }
            }
        } label: {
            Label {
                Text(invoice.status ?? "—")
                    .frame(minWidth:40, alignment: .leading) // 👈 fixe une largeur minimale

            } icon: {
                Image(systemName: statusEnum.icon)
            }
            .font(.caption)
            .padding(6)
            .background(statusEnum.color.opacity(0.2))
            .foregroundColor(statusEnum.color)
            .cornerRadius(6)
        }
    }
}
