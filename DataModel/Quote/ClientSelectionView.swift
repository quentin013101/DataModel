import SwiftUI
import CoreData

struct ClientSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

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

                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text("\(client.firstName ?? "") \(client.lastName ?? "")")
                                .font(.headline)
                            Text("\(client.street ?? ""), \(client.postalCode ?? "") \(client.city ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
            }

            Button("Ajouter un nouveau client") {
                showingAddClient = true
            }
            .foregroundColor(.blue)
            .padding()
        }
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $showingAddClient) {
            AddContactView().environment(\.managedObjectContext, viewContext)
        }
        .onTapGesture {
            dismiss() // ✅ Ferme la fenêtre si on clique en dehors
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
