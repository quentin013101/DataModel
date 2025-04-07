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

            Text("Montant estimé : \(montant.formatted(.currency(code: "EUR")))")
                .font(.caption)
                .padding(.top, 4)

//            Button("Valider") {
//                resultText = "\(title) de \(Int(percentage)) %, soit \(montant.formatted(.currency(code: "EUR")))"
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.top, 8)
        }
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
