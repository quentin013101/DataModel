import SwiftUI

struct ContactDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var isEditing = false // 🔹 Active/Désactive l'édition
    
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
                    // 📌 Type (Particulier / Entreprise)
                    Text("Type").bold()
                    Picker("Type", selection: $clientType) {
                        Text("Particulier").tag("Particulier")
                        Text("Entreprise").tag("Entreprise")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!isEditing)

                    // 📌 Civilité, Prénom, Nom
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

                    // 📌 Numéro fiscal
                    Text("Numéro fiscal").bold()
                    TextField("Numéro fiscal", text: $fiscalNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    // 📌 Adresse email
                    Text("Adresse email").bold()
                    TextField("Adresse email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    // 📌 Téléphone
                    Text("Téléphone").bold()
                    TextField("Téléphone", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)

                    // 📌 Adresse complète
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

                    // 📌 Notes
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
                        resetFields() // 🔄 Réinitialise les champs en mode édition
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
            dismiss() // 🔥 Ferme la pop-up après l'enregistrement
        } catch {
            print("❌ Erreur lors de l'enregistrement : \(error.localizedDescription)")
        }
    }

    private func resetFields() {
        clientType = contact.clientType ?? "Particulier"
        civility = contact.civility ?? "M."
        firstName = contact.firstName ?? ""
        lastName = contact.lastName ?? ""
        fiscalNumber = contact.fiscalNumber ?? ""
        email = contact.email ?? ""
        phoneNumber = contact.phoneNumber ?? ""
        street = contact.street ?? ""
        addressDetail = contact.addressDetail ?? ""
        postalCode = contact.postalCode ?? ""
        city = contact.city ?? ""
        country = contact.country ?? "France"
        notes = contact.notes ?? ""
    }
}
