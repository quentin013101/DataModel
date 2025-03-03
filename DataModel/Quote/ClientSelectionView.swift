//
//  ClientSelectionView.swift
//  DataModel
//
//  Created by Quentin FABERES on 03/03/2025.
//
import SwiftUI
import CoreData

struct ClientSelectionView: View {
    @Binding var selectedContact: Contact?
    @FetchRequest(entity: Contact.entity(), sortDescriptors: []) var contacts: FetchedResults<Contact>

    var body: some View {
        List(contacts, id: \.self) { contact in
            Button(action: { selectedContact = contact }) {
                Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
            }
        }
    }
}
