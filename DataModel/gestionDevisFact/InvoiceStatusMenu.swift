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

    var body: some View {
        Menu {
            ForEach(QuoteStatus.allCases, id: \.self) { status in
                Button {
                    invoice.status = status.rawValue
                    try? viewContext.save()
                } label: {
                    Label(status.rawValue, systemImage: icon(for: status))
                }
            }
        } label: {
            Label {
                Text(invoice.status ?? "—")
            } icon: {
                Image(systemName: icon(for: QuoteStatus(rawValue: invoice.status ?? "") ?? .brouillon))
            }
            .font(.caption)
            .padding(6)
            .background((invoice.statusColor ?? .gray).opacity(0.2))
            .foregroundColor(invoice.statusColor ?? .gray)
            .cornerRadius(6)
        }
    }

    func icon(for status: QuoteStatus) -> String {
        switch status {
        case .brouillon: return "pencil"
        case .finalisé: return "checkmark.circle"
        case .accepté: return "checkmark.seal"
        case .abandonné: return "xmark.circle"
        }
    }
}