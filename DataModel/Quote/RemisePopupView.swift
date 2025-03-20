import SwiftUI

struct RemisePopupView: View {
    @Binding var isPresented: Bool
    @State private var isPercentage: Bool = true
    @State private var inputValue: String = ""
    var totalBeforeDiscount: Double
    var onApply: (Double) -> Void  // Retourne le montant calculé de la remise en €

    var body: some View {
        VStack {
            // Titre de la pop-up
            Text("Ajouter une remise")
                .font(.title)
                .padding(.top)

            // Formulaire de saisie
            Form {
                Section(header: Text("Type de remise")) {
                    Picker("Type", selection: $isPercentage) {
                        Text("Pourcentage").tag(true)
                        Text("Montant (€)").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Valeur")) {
                    TextField("Entrer la valeur", text: $inputValue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                }
            }
            .padding()

            // Boutons en bas
            HStack {
                Button("Annuler") {
                    isPresented = false
                }
                Spacer()
                Button("Valider") {
                    guard let value = Double(inputValue.replacingOccurrences(of: ",", with: ".")) else {
                        // gestion d'erreur
                        return
                    }
                    let discountAmount: Double
                    if isPercentage {
                        discountAmount = totalBeforeDiscount * (value / 100.0)
                    } else {
                        discountAmount = value
                    }
                    onApply(discountAmount)
                    isPresented = false
                }
            }
            .padding([.leading, .trailing, .bottom])
        }
        .frame(width: 400, height: 300)
    }
}
