import SwiftUI
import CoreData

struct AddContactView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool  // ✅ Ajout pour contrôler la sheet
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var street = ""
    @State private var postalCode = ""
    @State private var city = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var clientType = "Particulier"

    @State private var postalCodeError: String? = nil
    @State private var phoneError: String? = nil
    @State private var emailError: String? = nil

    let clientTypes = ["Particulier", "Entreprise"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Nouveau Client")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 10)

            Form {
                Section(header: Text("Type de Client")) {
                    Picker("Type", selection: $clientType) {
                        ForEach(clientTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Informations Personnelles")) {
                    InputField(label: "Prénom", text: $firstName)
                    InputField(label: "Nom *", text: $lastName)
                }

                Section(header: Text("Coordonnées")) {
                    InputField(label: "Adresse", text: $street)

                    InputFieldWithError(label: "Code Postal", text: $postalCode, error: $postalCodeError)
                        .onChange(of: postalCode) { _ in validatePostalCode() }

                    InputField(label: "Ville", text: $city)

                    InputFieldWithError(label: "Téléphone", text: $phoneNumber, error: $phoneError)
                        .onChange(of: phoneNumber) { _ in validatePhoneNumber() }

                    InputFieldWithError(label: "Email", text: $email, error: $emailError)
                        .onChange(of: email) { _ in validateEmail() }
                }
            }

            // 🔹 Boutons
            HStack {
                Button("Annuler") {
                    dismiss()
                }
                .foregroundColor(.red)

                Spacer()

                Button("Enregistrer") {
                    saveContact()
                }
                .disabled(!isFormValid()) // 🔥 Désactive si invalide
                .foregroundColor(.white)
                .padding()
                .background(isFormValid() ? Color.blue : Color.gray)
                .cornerRadius(5)
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .padding()
    }

    // ✅ Vérifie que le formulaire est valide
    private func isFormValid() -> Bool {
        guard !lastName.isEmpty else { return false }
        return (postalCode.isEmpty || validatePostalCode()) &&
               (phoneNumber.isEmpty || validatePhoneNumber()) &&
               (email.isEmpty || validateEmail())
    }

    private func validatePostalCode() -> Bool {
        if postalCode.isEmpty { postalCodeError = nil; return true }
        let regex = "^[0-9]{5}$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = test.evaluate(with: postalCode)
        postalCodeError = isValid ? nil : "Code postal invalide"
        return isValid
    }

    private func validatePhoneNumber() -> Bool {
        if phoneNumber.isEmpty { phoneError = nil; return true }
        let regex = "^(?:\\+33|0)[1-9](?:[\\s.-]?[0-9]{2}){4}$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = test.evaluate(with: phoneNumber)
        phoneError = isValid ? nil : "Numéro invalide"
        return isValid
    }

    private func validateEmail() -> Bool {
        if email.isEmpty { emailError = nil; return true }
        let regex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = test.evaluate(with: email)
        emailError = isValid ? nil : "Email invalide"
        return isValid
    }

    private func saveContact() {
        let newContact = Contact(context: viewContext)
        newContact.firstName = firstName
        newContact.lastName = lastName
        newContact.street = street
        newContact.postalCode = postalCode
        newContact.city = city
        newContact.phoneNumber = phoneNumber
        newContact.email = email
        newContact.clientType = clientType

        do {
            try viewContext.save()
            
            // ✅ Fermer la sheet correctement
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPresented = false
            }
        } catch {
            print("Erreur lors de la sauvegarde : \(error)")
        }
    }
}

// ✅ Composant pour un champ de saisie simple
struct InputField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .fontWeight(.bold)
            TextField(label, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // ✅ Forcer le style
                .frame(maxWidth: .infinity)
        }
    }
}

// ✅ Composant pour un champ avec erreur
struct InputFieldWithError: View {
    let label: String
    @Binding var text: String
    @Binding var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .fontWeight(.bold)
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            TextField(label, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
        }
    }
}
