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
    @State private var selectedContacts = Set<NSManagedObjectID>() // ✅ Stocke les ObjectID

    enum SortOption {
        case clientType, lastName, address, postalCode, city, phone, email
    }

    /// ✅ Applique le tri et la recherche
    var filteredContacts: [Contact] {
        let filtered = contacts.filter { contact in
            searchText.isEmpty ||
            (contact.firstName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (contact.lastName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (contact.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (contact.city?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        
        switch sortBy {
        case .clientType:
            return filtered.sorted { ($0.clientType ?? "") < ($1.clientType ?? "") }
        case .lastName:
            return filtered.sorted { ($0.lastName ?? "") < ($1.lastName ?? "") }
        case .address:
            return filtered.sorted { ($0.street ?? "") < ($1.street ?? "") }
        case .postalCode:
            return filtered.sorted { ($0.postalCode ?? "") < ($1.postalCode ?? "") }
        case .city:
            return filtered.sorted { ($0.city ?? "") < ($1.city ?? "") }
        case .phone:
            return filtered.sorted { ($0.phoneNumber ?? "") < ($1.phoneNumber ?? "") }
        case .email:
            return filtered.sorted { ($0.email ?? "") < ($1.email ?? "") }
        }
    }

    var body: some View {
        VStack {
            // ✅ Barre de recherche + Boutons d'ajout et suppression multiple
            HStack {
                TextField("Rechercher un client", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)
                    .padding(.leading, 10)

                Spacer()

                if !selectedContacts.isEmpty {
                    Button(action: deselectAllContacts) { // ✅ Désélectionner tous les contacts
                        Text("Tout désélectionner")
                            .bold()
                            .foregroundColor(.blue)
                    }

                    Button(action: deleteSelectedContacts) { // ✅ Supprimer les contacts sélectionnés
                        Text("SUPPRIMER (\(selectedContacts.count))")
                            .bold()
                            .foregroundColor(.red)
                    }
                }

                Button(action: { showingAddClient = true }) {
                    Text("NOUVEAU CLIENT")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            Divider()

            // ✅ En-tête des colonnes triables
            HStack {
                SortableColumn(title: "Type", currentSort: $sortBy, sortOption: .clientType).frame(width: 80)
                SortableColumn(title: "Nom", currentSort: $sortBy, sortOption: .lastName).frame(width: 150)
                SortableColumn(title: "Adresse", currentSort: $sortBy, sortOption: .address).frame(width: 200)
                SortableColumn(title: "Code Postal", currentSort: $sortBy, sortOption: .postalCode).frame(width: 100)
                SortableColumn(title: "Ville", currentSort: $sortBy, sortOption: .city).frame(width: 150)
                SortableColumn(title: "Téléphone", currentSort: $sortBy, sortOption: .phone).frame(width: 120)
                SortableColumn(title: "Email", currentSort: $sortBy, sortOption: .email).frame(width: 200)
            }
            .padding(.vertical, 5)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            Divider()

            // ✅ Liste des clients sous forme de tableau avec sélection multiple
            if filteredContacts.isEmpty {
                Text("Aucun client trouvé")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(filteredContacts, id: \.self) { contact in
                            HStack {
                                // ✅ Case à cocher (N'affecte pas le clic pour ouvrir la fiche)
                                Button(action: {
                                    toggleSelection(contact)
                                }) {
                                    Image(systemName: selectedContacts.contains(contact.objectID) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedContacts.contains(contact.objectID) ? .blue : .gray)
                                        .frame(width: 30)
                                }
                                .buttonStyle(PlainButtonStyle())

                                // ✅ Type (Icône)
                                Button(action: {
                                    openContactDetail(contact)
                                }) {
                                    HStack {
                                        Image(systemName: contact.clientType == "Entreprise" ? "building.2.fill" : "person.fill")
                                            .foregroundColor(contact.clientType == "Entreprise" ? .blue : .gray)
                                            .frame(width: 80)

                                        // ✅ Infos client -> Clique ouvre la fiche détaillée
                                        Text("\(contact.firstName ?? "") \(contact.lastName ?? "")").frame(width: 150, alignment: .leading)
                                        Text(contact.street ?? "-").frame(width: 200, alignment: .leading)
                                        Text(contact.postalCode ?? "-").frame(width: 100, alignment: .leading)
                                        Text(contact.city ?? "-").frame(width: 150, alignment: .leading)
                                        Text(contact.phoneNumber ?? "-").frame(width: 120, alignment: .leading)
                                        Text(contact.email ?? "-").frame(width: 200, alignment: .leading)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2)) // 🔥 Fond gris étendu à Type + Infos client
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
        .onAppear { selectedTab = "clients" }
        .sheet(item: $selectedContact) { contact in
            ContactDetailView(contact: contact)
                .id(sheetID)
        }
        .sheet(isPresented: $showingAddClient) {
            AddContactView()
                .environment(\.managedObjectContext, viewContext)
        }
    }

    // ✅ Fonction pour sélectionner/désélectionner un contact
    private func toggleSelection(_ contact: Contact) {
        let contactID = contact.objectID
        if selectedContacts.contains(contactID) {
            selectedContacts.remove(contactID)
        } else {
            selectedContacts.insert(contactID)
        }
    }

    // ✅ Supprime tous les contacts sélectionnés avec confirmation
    private func deleteSelectedContacts() {
        guard !selectedContacts.isEmpty else { return }

        let alert = NSAlert()
        alert.messageText = "Confirmer la suppression"
        alert.informativeText = "Êtes-vous sûr de vouloir supprimer \(selectedContacts.count) contact(s) ? Cette action est irréversible."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Supprimer")
        alert.addButton(withTitle: "Annuler")

        if alert.runModal() == .alertFirstButtonReturn {
            for contactID in selectedContacts {
                if let contact = viewContext.object(with: contactID) as? Contact {
                    viewContext.delete(contact)
                }
            }
            try? viewContext.save()
            selectedContacts.removeAll()
        }
    }

    private func deselectAllContacts() {
        selectedContacts.removeAll()
    }
    
    // ✅ Ouvre la fiche détaillée du contact
    private func openContactDetail(_ contact: Contact) {
        selectedContact = nil // Réinitialisation pour forcer la mise à jour de la vue

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedContact = contact
            sheetID = UUID() // 🔥 Force le rafraîchissement de la sheet
        }
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
