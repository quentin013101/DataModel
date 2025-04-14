import SwiftUI
import CoreData

struct ContactDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    let contact: Contact
    let civilities = ["M.", "Mme", "Mlle"]
    @State private var civility: String
    @State private var firstName: String
    @State private var lastName: String
    @State private var street: String
    @State private var postalCode: String
    @State private var city: String
    @State private var phoneNumber: String
    @State private var email: String
    @State private var clientType: String
    @State private var fiscalNumber: String

    @State private var postalCodeError: String? = nil
    @State private var phoneError: String? = nil
    @State private var emailError: String? = nil

    @State private var isEditing = false
    @State private var showingDeleteAlert = false // ✅ Variable pour l'alerte de suppression

    init(contact: Contact) {
        self.contact = contact
        _civility = State(initialValue: contact.civility ?? "M.")
        _firstName = State(initialValue: contact.firstName ?? "")
        _lastName = State(initialValue: contact.lastName ?? "")
        _street = State(initialValue: contact.street ?? "")
        _postalCode = State(initialValue: contact.postalCode ?? "")
        _city = State(initialValue: contact.city ?? "")
        _phoneNumber = State(initialValue: contact.phoneNumber ?? "")
        _email = State(initialValue: contact.email ?? "")
        _clientType = State(initialValue: contact.clientType ?? "Particulier")
        _fiscalNumber = State(initialValue: contact.fiscalNumber ?? "")
    }

    var isFormValid: Bool {
        return postalCodeError == nil && phoneError == nil && emailError == nil && !lastName.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 🔹 En-tête avec croix de fermeture et titre centré
            HStack {
                Spacer()
                Text("Détails du Client")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 10)

            Form {
                // 🔹 Type de client
                Section(header: Text("Type de Client").bold().frame(maxWidth: .infinity, alignment: .center)) {
                    Picker("Type", selection: $clientType) {
                        Text("Particulier").tag("Particulier")
                        Text("Entreprise").tag("Entreprise")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!isEditing)
                }

                // 🔹 Informations personnelles
                Section(header: Text("Informations Personnelles").bold().frame(maxWidth: .infinity, alignment: .center)) {
                    Picker("Civilité", selection: $civility) {
                        Text("M.").tag("M.")
                        Text("Mme").tag("Mme")
                        Text("Mlle").tag("Dr")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!isEditing)
                    InputField(label: "Prénom", text: $firstName, isEditing: isEditing)
                    InputField(label: "Nom *", text: $lastName, isEditing: isEditing)
                    VStack(alignment: .leading) {
                        Text("Numéro Fiscal")
                            .frame(width: 120, alignment: .leading)
                           // .bold()

                        if clientType == "Entreprise" {
                            TextField("", text: $fiscalNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(!isEditing)
                                .transition(.opacity) // Animation fluide
                        } else {
                            TextField("", text: .constant("")) // Champ invisible mais conserve la place
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .hidden()
                                .frame(height: 0) // Hauteur nulle pour éviter l'expansion
                        }
                    }                }

                // 🔹 Coordonnées
                Section(header: Text("Coordonnées").bold().frame(maxWidth: .infinity, alignment: .center)) {
                    InputField(label: "Adresse", text: $street, isEditing: isEditing)
                    
                    InputFieldWithError(label: "Code Postal", text: $postalCode, error: $postalCodeError, isEditing: isEditing)
                        .onChange(of: postalCode) { _ in postalCodeError = validatePostalCode() }

                    InputField(label: "Ville", text: $city, isEditing: isEditing)

                    InputFieldWithError(label: "Téléphone", text: $phoneNumber, error: $phoneError, isEditing: isEditing)
                        .onChange(of: phoneNumber) { _ in phoneError = validatePhoneNumber() }

                    InputFieldWithError(label: "Email", text: $email, error: $emailError, isEditing: isEditing)
                        .onChange(of: email) { _ in emailError = validateEmail() }
                }
            }

            // 🔹 Boutons en bas
            HStack {
                // 🔵 Annuler (à gauche)
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Annuler")
                        .bold()
                        .foregroundColor(.blue)
                }

                Spacer()

                // 🔵 Modifier / Enregistrer (à droite)
                Button(action: {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "✅ Enregistrer" : "✏️ Modifier")
                        .bold()
                        .foregroundColor(isEditing ? Color.green : Color.blue)
                }
                .disabled(isEditing && !isFormValid) // ✅ Désactiver si erreur
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // 🔴 Bouton Supprimer (centré en dessous avec confirmation)
            Button(action: {
                showingDeleteAlert = true // ✅ Affiche la boîte de confirmation
            }) {
                Text("🗑️ Supprimer")
                    .bold()
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .alert(isPresented: $showingDeleteAlert) { // ✅ Affichage de la boîte de dialogue
                Alert(
                    title: Text("Confirmer la suppression"),
                    message: Text("Êtes-vous sûr de vouloir supprimer ce contact ? Cette action est irréversible."),
                    primaryButton: .destructive(Text("Supprimer")) {
                        deleteContact() // ✅ Suppression confirmée
                    },
                    secondaryButton: .cancel(Text("Annuler"))
                )
            }
        }
        .padding()
    }

    // ✅ Fonctions de validation
    private func validatePostalCode() -> String? {
        let regex = "^[0-9]{5}$"
        return postalCode.range(of: regex, options: .regularExpression) != nil ? nil : "Code postal invalide"
    }

    private func validatePhoneNumber() -> String? {
        let regex = "^0[67][0-9]{8}$"
        return phoneNumber.range(of: regex, options: .regularExpression) != nil ? nil : "Numéro invalide"
    }

    private func validateEmail() -> String? {
        let regex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: regex, options: .regularExpression) != nil ? nil : "Email invalide"
    }

    private func saveChanges() {
        contact.civility = civility
        contact.firstName = firstName
        contact.lastName = lastName
        contact.street = street
        contact.postalCode = postalCode
        contact.city = city
        contact.phoneNumber = phoneNumber
        contact.email = email
        contact.fiscalNumber = fiscalNumber

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // ✅ Compatibilité macOS 11
        } catch {
            print("Erreur lors de l'enregistrement : \(error)")
        }
    }

    private func deleteContact() {
        viewContext.delete(contact)
        try? viewContext.save()
        presentationMode.wrappedValue.dismiss() // ✅ Compatibilité macOS 11
    }
//    // ✅ Composant pour un champ Picker
//    private func formRowPicker(label: String, selection: Binding<String>, options: [String]) -> some View {
//        HStack {
//            Text(label)
//                .frame(width: 120, alignment: .leading)
//            Picker("", selection: selection) {
//                ForEach(options, id: \.self) { option in
//                    Text(option)
//                }
//            }
//            .pickerStyle(MenuPickerStyle())
//            .frame(maxWidth: .infinity)
//        }
//    }
}
