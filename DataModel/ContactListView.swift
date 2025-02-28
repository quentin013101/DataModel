import SwiftUI
import CoreData

struct ContactListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Contact.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Contact.lastName, ascending: true)]
    ) private var contacts: FetchedResults<Contact>
    
    @State private var searchText = ""
    @State private var showingAddClient = false
    @State private var selectedContact: Contact?
    @State private var isDetailPresented = false

    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return Array(contacts)
        } else {
            return contacts.filter { contact in
                (contact.firstName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (contact.lastName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (contact.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (contact.city?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (contact.street?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            VStack {
                // 🔍 Barre de recherche et boutons
                HStack {
                    TextField("Rechercher un client", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 10)

                    Button(action: { print("Rechercher") }) {
                        Image(systemName: "magnifyingglass")
                            .padding()
                    }

                    Spacer()

                    Button(action: { print("Exporter Excel") }) {
                        Text("EXPORT EXCEL")
                            .bold()
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }

                    Button(action: { showingAddClient = true }) {
                        Text("NOUVEAU CLIENT")
                            .bold()
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                .padding(.horizontal)

                Divider()

                // 📋 Liste des contacts avec affichage amélioré
                if filteredContacts.isEmpty {
                    Text("Aucun résultat ne correspond aux critères de recherche")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(filteredContacts) { contact in
                            Button(action: {
                                selectedContact = contact
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        isDetailPresented = true
                                    }
                                }
                            }) {
                                HStack {
                                    // 🏢 Icône "Entreprise" ou 👤 "Particulier"
                                    Image(systemName: contact.clientType == "Entreprise" ? "building.2.fill" : "person.fill")
                                        .foregroundColor(contact.clientType == "Entreprise" ? .blue : .blue)
                                        .font(.title2)

                                    VStack(alignment: .leading) {
                                        // 📌 Nom et Email
                                        Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                                            .font(.headline)
                                        Text(contact.email ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        // 📍 Adresse complète
                                        if let street = contact.street, let city = contact.city, !street.isEmpty, !city.isEmpty {
                                            Text("\(street), \(city)")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    
                                    // 📞 Numéro de téléphone
                                    Text(contact.phoneNumber ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .onDelete(perform: deleteContacts)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $isDetailPresented) {
            if let contact = selectedContact {
                ContactDetailView(contact: contact)
                    .id(contact.objectID) // 🔥 Forcer le rafraîchissement
            }
        }
        .sheet(isPresented: $showingAddClient) {
            AddContactView().environment(\.managedObjectContext, viewContext)
        }
    }

    private func deleteContacts(at offsets: IndexSet) {
        for index in offsets {
            let contact = contacts[index]
            viewContext.delete(contact)
        }
        try? viewContext.save()
    }
}
