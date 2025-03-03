import SwiftUI
import CoreData

struct ContactListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTab: String

    @FetchRequest(
        entity: Contact.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Contact.lastName, ascending: true)]
    ) private var contacts: FetchedResults<Contact>
    
    @State private var searchText = ""
    @State private var showingAddClient = false
    @State private var selectedContact: Contact? = nil
    @State private var sheetID = UUID()
    @State private var sortBy: SortOption = .lastName

    enum SortOption {
        case clientType, lastName, address, postalCode, city, phone, email
    }

    var sortedContacts: [Contact] {
        switch sortBy {
        case .clientType:
            return contacts.sorted { ($0.clientType ?? "") < ($1.clientType ?? "") }
        case .lastName:
            return contacts.sorted { ($0.lastName ?? "") < ($1.lastName ?? "") }
        case .address:
            return contacts.sorted { ($0.street ?? "") < ($1.street ?? "") }
        case .postalCode:
            return contacts.sorted { ($0.postalCode ?? "") < ($1.postalCode ?? "") }
        case .city:
            return contacts.sorted { ($0.city ?? "") < ($1.city ?? "") }
        case .phone:
            return contacts.sorted { ($0.phoneNumber ?? "") < ($1.phoneNumber ?? "") }
        case .email:
            return contacts.sorted { ($0.email ?? "") < ($1.email ?? "") }
        }
    }

    var body: some View {
        VStack {
            // ✅ Barre de recherche + Bouton d'ajout
            HStack {
                TextField("Rechercher un client", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)
                    .padding(.leading, 10)

                Spacer()

                Button(action: { showingAddClient = true }) {
                    Text("NOUVEAU CLIENT")
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle()) // 🔥 Supprime tout fond parasite sur macOS
            }
            .padding(.horizontal)

            Divider()

            // ✅ En-tête des colonnes
            HStack {
                SortableColumn(title: "Type", currentSort: $sortBy, sortOption: .clientType)
                    .frame(width: 80)
                SortableColumn(title: "Nom", currentSort: $sortBy, sortOption: .lastName)
                    .frame(width: 150)
                SortableColumn(title: "Adresse", currentSort: $sortBy, sortOption: .address)
                    .frame(width: 200)
                SortableColumn(title: "Code Postal", currentSort: $sortBy, sortOption: .postalCode)
                    .frame(width: 100)
                SortableColumn(title: "Ville", currentSort: $sortBy, sortOption: .city)
                    .frame(width: 150)
                SortableColumn(title: "Téléphone", currentSort: $sortBy, sortOption: .phone)
                    .frame(width: 120)
                SortableColumn(title: "Email", currentSort: $sortBy, sortOption: .email)
                    .frame(width: 200)
            }
            .padding(.vertical, 5)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            Divider()

            // ✅ Liste des clients sous forme de tableau
            if sortedContacts.isEmpty {
                Text("Aucun client trouvé")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(sortedContacts) { contact in
                            Button(action: {
                                openContactDetail(contact)
                            }) {
                                HStack {
                                    // ✅ Type (Icône)
                                    Image(systemName: contact.clientType == "Entreprise" ? "building.2.fill" : "person.fill")
                                        .foregroundColor(contact.clientType == "Entreprise" ? .blue : .blue)
                                        .frame(width: 80)

                                    // ✅ Nom
                                    Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                                        .frame(width: 150, alignment: .leading)

                                    // ✅ Adresse
                                    Text(contact.street ?? "-")
                                        .frame(width: 200, alignment: .leading)

                                    // ✅ Code Postal : Affichage uniquement si valide
                                    Text((contact.postalCode?.count == 5 && contact.postalCode?.allSatisfy { $0.isNumber } == true) ? contact.postalCode! : "-")
                                        .frame(width: 100, alignment: .leading)

                                    // ✅ Ville
                                    Text(contact.city ?? "-")
                                        .frame(width: 150, alignment: .leading)

                                    // ✅ Téléphone : Affichage propre
                                    Text(contact.phoneNumber?.replacingOccurrences(of: " ", with: "") ?? "-")
                                        .frame(width: 120, alignment: .leading)


                                    // ✅ Email : Format minimal
                                    Text(contact.email?.contains("@") == true ? contact.email! : "-")
                                        .frame(width: 200, alignment: .leading)
                                }
                                .padding()
                                //.background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 1)
                            }
                        }
                        .onDelete(perform: deleteContacts)
                    }
                    .padding()
                }
            }
        }
        .padding()
        .onAppear {
            selectedTab = "clients"
        }
        .sheet(item: $selectedContact) { contact in
            ContactDetailView(contact: contact)
                .id(sheetID) // 🔥 Force la réouverture
        }
        .sheet(isPresented: $showingAddClient) {
            AddContactView(isPresented: $showingAddClient)  // ✅ On passe bien la variable Binding
                .environment(\.managedObjectContext, viewContext)
        }
    }

    private func openContactDetail(_ contact: Contact) {
        selectedContact = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedContact = contact
            sheetID = UUID()
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

// ✅ Composant pour les en-têtes triables des colonnes
struct SortableColumn: View {
    let title: String
    @Binding var currentSort: ContactListView.SortOption
    let sortOption: ContactListView.SortOption

    var body: some View {
        Button(action: {
            currentSort = sortOption
        }) {
            HStack {
                Text(title)
                    .font(.headline)
                    .bold()
                if currentSort == sortOption {
                    Image(systemName: "arrow.down")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
