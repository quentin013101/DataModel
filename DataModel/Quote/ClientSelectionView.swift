import SwiftUI
import CoreData

struct ClientSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
   // @Environment(\.dismiss) private var dismiss
    var onClientSelected: (() -> Void)?

    @Binding var selectedClient: Contact?
    @Binding var clientProjectAddress: String
    @State private var searchText = ""
    @State private var showingAddClient = false

    @FetchRequest(
        entity: Contact.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Contact.lastName, ascending: true)]
    ) private var clients: FetchedResults<Contact>

    var body: some View {
        VStack {
            Text("Sélectionner un client")
                .font(.title2)
                .bold()
                .padding()

            TextField("Rechercher un client...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if filteredClients.isEmpty {
                Text("Aucun client trouvé")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(filteredClients, id: \.self) { client in
                    Button(action: {
                        selectedClient = client
                        let streetLine = client.street ?? ""
                        let postalCityLine = "\(client.postalCode ?? "") \(client.city ?? "")"
                        clientProjectAddress = streetLine + "\n" + postalCityLine
                        onClientSelected?()
                    }) {
                        HStack {
                            Text("\(client.firstName ?? "") \(client.lastName ?? "") — \(client.street ?? ""), \(client.postalCode ?? "") \(client.city ?? "")")
                                .font(.system(size: 12))
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .frame(maxHeight: 300) // ✅ Pour éviter qu'elle dépasse dans la popover
            }

            Divider()

            Button("Ajouter un nouveau client") {
                showingAddClient = true
            }
            .padding()

        }
        .frame(width: 400, height: 500)
        .sheet(isPresented: $showingAddClient) {
            AddContactView().environment(\.managedObjectContext, viewContext)
        }
    }

    var filteredClients: [Contact] {
        if searchText.isEmpty {
            return Array(clients)
        } else {
            return clients.filter { client in
                let fullName = "\(client.firstName ?? "") \(client.lastName ?? "")"
                return fullName.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
