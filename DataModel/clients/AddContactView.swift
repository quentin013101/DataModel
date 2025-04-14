import SwiftUI
import CoreData

struct AddContactView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var civility: String = "M."
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var street: String = ""
    @State private var postalCode: String = ""
    @State private var city: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var clientType: String = "Particulier"
    @State private var fiscalNumber: String = ""

    @State private var postalCodeError: String? = nil
    @State private var phoneError: String? = nil
    @State private var emailError: String? = nil

    let clientTypes = ["Particulier", "Entreprise"]
    let civilities = ["M.", "Mme", "Mlle"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Text("Nouveau Client")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)
                Spacer()
            }

            Form {
                Section {
                    HStack {
                        Text("Type")
                            .frame(width: 120, alignment: .leading)
                        Picker("", selection: $clientType) {
                            ForEach(clientTypes, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                }

                Section(header: sectionHeader("Informations Personnelles")) {
                    formRowPicker(label: "Civilité", selection: $civility, options: civilities)
                    formRow(label: "Prénom", text: $firstName)
                    formRow(label: "Nom *", text: $lastName)

                    if clientType == "Entreprise" {
                        formRow(label: "Numéro Fiscal", text: $fiscalNumber)
                    }
                }

                Section(header: sectionHeader("Coordonnées")) {
                    formRow(label: "Adresse", text: $street)
                    formRowWithError(label: "Code Postal", text: $postalCode, error: $postalCodeError)
                        .onChange(of: postalCode) { _ in validatePostalCode() }
                    formRow(label: "Ville", text: $city)
                    formRowWithError(label: "Téléphone", text: $phoneNumber, error: $phoneError)
                        .onChange(of: phoneNumber) { _ in validatePhoneNumber() }
                    formRowWithError(label: "Email", text: $email, error: $emailError)
                        .onChange(of: email) { _ in validateEmail() }
                }
            }
            .padding(.horizontal, -10)

            HStack {
                Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)

                Spacer()

                Button(action: saveContact) {
                    Text("Enregistrer")
                        .bold()
                        .foregroundColor(isFormValid() ? Color.green : Color.gray)
                }
                .disabled(!isFormValid())
            }
            .padding()
        }
        .padding()
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(.gray)
            Spacer()
        }
    }

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
        let regex = "^0[67][0-9]{8}$"
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
        newContact.civility = civility
        newContact.firstName = firstName
        newContact.lastName = lastName
        newContact.street = street
        newContact.postalCode = postalCode
        newContact.city = city
        newContact.phoneNumber = phoneNumber
        newContact.email = email
        newContact.clientType = clientType

        if clientType == "Entreprise" {
            newContact.fiscalNumber = fiscalNumber
        }

        do {
            try viewContext.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("Erreur lors de la sauvegarde : \(error)")
        }
    }

    private func formRow(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            TextField("", text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
        }
    }

    private func formRowWithError(label: String, text: Binding<String>, error: Binding<String?>) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            VStack(alignment: .leading) {
                TextField("", text: text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                if let errorMessage = error.wrappedValue {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
    }

    private func formRowPicker(label: String, selection: Binding<String>, options: [String]) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            Picker("", selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity)
        }
    }
}
