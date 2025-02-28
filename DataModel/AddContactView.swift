import SwiftUI
import CoreData

struct AddContactView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // 🔹 États pour stocker les nouvelles informations
    @State private var clientType = "Particulier"
    @State private var civility = "M."
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var fiscalNumber = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var street = ""
    @State private var addressDetail = ""
    @State private var postalCode = ""
    @State private var city = ""
    @State private var country = "France"
    @State private var notes = ""

    var body: some View {
        VStack {
            // 🔹 En-tête avec bouton Fermer
            HStack {
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
                .padding()
            }

            Text("Nouveau Client")
                .font(.title)
                .bold()
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // 📌 Type (Particulier / Entreprise)
                    HStack {
                        Text("Type :")
                            .bold()
                        Picker("Type", selection: $clientType) {
                            Text("Particulier").tag("Particulier")
                            Text("Entreprise").tag("Entreprise")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // 📌 Civilité, Prénom, Nom
                    HStack {
                        Picker("Civilité", selection: $civility) {
                            Text("M.").tag("M.")
                            Text("Mme").tag("Mme")
                        }
                        .pickerStyle(MenuPickerStyle())

                        TextField("Prénom", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Nom", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // 📌 Numéro fiscal
                    TextField("Numéro fiscal", text: $fiscalNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 📌 Adresse email
                    TextField("Adresse email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 📌 Téléphone
                    TextField("Téléphone", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 📌 Adresse complète
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Adresse").bold()
                        
                        TextField("Numéro et voie", text: $street)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Complément d’adresse", text: $addressDetail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        HStack {
                            TextField("Code postal", text: $postalCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Ville", text: $city)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        TextField("Pays", text: $country)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // 📌 Notes
                    Text("Notes").bold()
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .border(Color.gray, width: 0.5)
                }
                .padding(.horizontal)
            }

            Spacer()
            
            // 📌 Boutons
            HStack {
                Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)

                Spacer()
                
                Button("💾 Enregistrer") {
                    saveContact()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 600) // ✅ Taille minimale pour éviter un affichage dans la sidebar
        .padding()
    }
    
    private func saveContact() {
        let newContact = Contact(context: viewContext)
        newContact.clientType = clientType
        newContact.civility = civility
        newContact.firstName = firstName
        newContact.lastName = lastName
        newContact.fiscalNumber = fiscalNumber
        newContact.email = email
        newContact.phoneNumber = phoneNumber
        newContact.street = street
        newContact.addressDetail = addressDetail
        newContact.postalCode = postalCode
        newContact.city = city
        newContact.country = country
        newContact.notes = notes

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("❌ Erreur lors de l'enregistrement : \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddContactView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
