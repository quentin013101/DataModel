import SwiftUI

struct AcomptePopoverView: View {
    var title: String
    @Binding var percentage: Double
    var netAPayer: Double
    @Binding var resultText: String

    var montant: Double {
        (percentage / 100) * netAPayer
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            HStack {
                Text("Pourcentage :")
                TextField("", value: $percentage, formatter: NumberFormatter.percent)
                    .frame(width: 50)
                Text("%")
            }

            Text("Montant estimé : \(currencyFormat(montant))")
                .font(.caption)
                .padding(.top, 4)

//            Button("Valider") {
//                resultText = "\(title) de \(Int(percentage)) %, soit \(montant.formatted(.currency(code: "EUR")))"
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.top, 8)
        }
    }
    func currencyFormat(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
    }
}

extension NumberFormatter {
    static var percent: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }
}
