import SwiftUI

struct RemisePopupView: View {
    @Binding var isPresented: Bool
    var totalBeforeDiscount: Double
    var onApply: (Double, Bool) -> Void

    @State private var inputValue: String = ""
    @State private var remiseMode: RemiseType = .montant
    @State private var equivalentValue: String = "" // ✅ Indicateur dynamique

    enum RemiseType {
        case montant, pourcentage
    }

    var body: some View {
        VStack {
            Text("Type de remise") // ✅ Centré et en gras au-dessus du Picker
                .font(.headline)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.bottom, 4)

            Picker("", selection: $remiseMode) { // ✅ Supprime "Type de remise" du Picker
                Text("Montant (€)").tag(RemiseType.montant)
                Text("Pourcentage (%)").tag(RemiseType.pourcentage)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: remiseMode) { _ in
                if !equivalentValue.isEmpty { // ✅ Si une équivalence existe, on la met dans le TextField
                    inputValue = equivalentValue.replacingOccurrences(of: "≈ ", with: "")
                        .replacingOccurrences(of: " €", with: "")
                        .replacingOccurrences(of: "% du total", with: "")
                }
            }

            TextField("Entrer la remise", text: $inputValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
                .frame(height: 40)
                .padding()
                .onChange(of: inputValue) { newValue in
                    updateEquivalentValue()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSText.didEndEditingNotification)) { _ in
                    applyRemise()
                }

            // ✅ Affichage de l'équivalence sous le champ de saisie (EN GRAS + PLUS GRAND)
            if !equivalentValue.isEmpty {
                Text(equivalentValue)
                    .font(.system(size: 14)) // ✅ Augmente la taille
                    .bold() // ✅ Met en gras
                    .foregroundColor(.gray)
                    .padding(.bottom, 4)
            }

            HStack {
                Button("Annuler") {
                    isPresented = false
                }
                .foregroundColor(.red)

                Spacer()

                Button("Valider") {
                    applyRemise() // ✅ Action commune au bouton et à la touche Entrée
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
        .frame(width: 300)
        .cornerRadius(10)
        .shadow(radius: 10)
    }

    // ✅ Fonction qui met à jour l'équivalence affichée
    private func updateEquivalentValue() {
        guard let value = Double(inputValue.replacingOccurrences(of: ",", with: ".")), totalBeforeDiscount > 0 else {
            equivalentValue = ""
            return
        }

        if remiseMode == .montant {
            let percentEquivalent = ceil((value / totalBeforeDiscount) * 100) // ✅ Arrondi au supérieur
            equivalentValue = "≈ \(Int(percentEquivalent))% du total" // ✅ Supprime la décimale
        } else {
            let euroEquivalent = (value / 100) * totalBeforeDiscount
            equivalentValue = String(format: "≈ %.2f €", euroEquivalent)
        }
    }

    // ✅ Fonction qui applique la remise au moment de la validation
    private func applyRemise() {
        guard let value = Double(inputValue.replacingOccurrences(of: ",", with: ".")) else {
            return // Gestion d'erreur si la conversion échoue
        }

        let isPercentage = remiseMode == .pourcentage
        onApply(value, isPercentage)

        isPresented = false
    }
}
