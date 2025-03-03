import SwiftUI

struct ContactDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var isEditing = false // 🔹 Active/Désactive l'édition
    @State private var showDeleteAlert = false // 🔹 Gère l'affichage de l'alerte de suppression

    @State private var clientType: String
    @State private var civility: String
    @State private var firstName: String
    @State private var lastName: String
    @State private var fiscalNumber: String
    @State private var email: String
    @State private var phoneNumber: String
    @State private var street: String
    @State private var addressDetail: String
    @State private var postalCode: String
    @State private var city: String
    @State private var country: String
    @State private var notes: String

    var contact: Contact

    init(contact: Contact) {
        self.contact = contact
        _clientType = State(initialValue: contact.clientType ?? "Particulier")
        _civility = State(initialValue: contact.civility ?? "M.")
        _firstName = State(initialValue: contact.firstName ?? "")
        _lastName = State(initialValue: contact.lastName ?? "")
        _fiscalNumber = State(initialValue: contact.fiscalNumber ?? "")
        _email = State(initialValue: contact.email ?? "")
        _phoneNumber = State(initialValue: contact.phoneNumber ?? "")
        _street = State(initialValue: contact.street ?? "")
        _addressDetail = State(initialValue: contact.addressDetail ?? "")
        _postalCode = State(initialValue: contact.postalCode ?? "")
        _city = State(initialValue: contact.city ?? "")
        _country = State(initialValue: contact.country ?? "France")
        _notes = State(initialValue: contact.notes ?? "")
    }

    var body: some View {
        VStack {
            // 🔹 Bouton Fermer
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
                .padding()
            }

            Text("Détails du Contact")
                .font(.title)
                .bold()
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Type").bold()
                    Picker("Type", selection: $clientType) {
                        Text("Particulier").tag("Particulier")
                        Text("Entreprise").tag("Entreprise")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!isEditing)

                    Text("Civilité").bold()
                    Picker("Civilité", selection: $civility) {
                        Text("M.").tag("M.")
                        Text("Mme").tag("Mme")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .disabled(!isEditing)

                    Text("Prénom").bold()
                    TextField("Prénom", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    Text("Nom").bold()
                    TextField("Nom", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    Text("Numéro fiscal").bold()
                    TextField("Numéro fiscal", text: $fiscalNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    Text("Adresse email").bold()
                    TextField("Adresse email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    Text("Téléphone").bold()
                    TextField("Téléphone", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    Text("Adresse").bold()
                    TextField("Numéro et voie", text: $street)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    Text("Complément d’adresse").bold()
                    TextField("Complément d’adresse", text: $addressDetail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Code postal").bold()
                            TextField("Code postal", text: $postalCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(!isEditing)
                        }
                        VStack(alignment: .leading) {
                            Text("Ville").bold()
                            TextField("Ville", text: $city)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(!isEditing)
                        }
                    }

                    Text("Pays").bold()
                    TextField("Pays", text: $country)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    Text("Notes").bold()
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .border(Color.gray, width: 0.5)
                        .disabled(!isEditing)
                }
                .padding(.horizontal)
            }

            Spacer()

            // 📌 Boutons
            HStack {
                Button("Annuler") {
                    if isEditing {
                        resetFields()
                        isEditing = false
                    } else {
                        dismiss()
                    }
                }
                .buttonStyle(.bordered)

                Spacer()

                if isEditing {
                    Button("💾 Enregistrer") {
                        saveContact()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("✏️ Modifier") {
                        isEditing = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()

            // 🗑 Bouton Supprimer
            Button("🗑 Supprimer ce contact") {
                showDeleteAlert = true
            }
            .foregroundColor(.red)
            .padding()
            .alert("Supprimer ce contact ?", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    deleteContact()
                }
            } message: {
                Text("Cette action est irréversible.")
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .padding()
    }
    
    private func saveContact() {
        contact.clientType = clientType
        contact.civility = civility
        contact.firstName = firstName
        contact.lastName = lastName
        contact.fiscalNumber = fiscalNumber
        contact.email = email
        contact.phoneNumber = phoneNumber
        contact.street = street
        contact.addressDetail = addressDetail
        contact.postalCode = postalCode
        contact.city = city
        contact.country = country
        contact.notes = notes

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Erreur lors de l'enregistrement : \(error.localizedDescription)")
        }
    }

    private func deleteContact() {
        viewContext.delete(contact)

        do {
            try viewContext.save()
            dismiss() // 🔥 Ferme la pop-up après suppression
        } catch {
            print("❌ Erreur lors de la suppression : \(error.localizedDescription)")
        }
    }

    private func resetFields() {
        firstName = contact.firstName ?? ""
        lastName = contact.lastName ?? ""
        email = contact.email ?? ""
        phoneNumber = contact.phoneNumber ?? ""
        street = contact.street ?? ""
        city = contact.city ?? ""
        notes = contact.notes ?? ""
    }
}
