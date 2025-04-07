import SwiftUI

struct NewInvoiceView: View {
    @StateObject var viewModel: InvoiceViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: String

    init(viewModel: InvoiceViewModel, selectedTab: Binding<String>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selectedTab = selectedTab
        print("✅ NewInvoiceView INIT avec : \(viewModel.invoice.invoiceNumber ?? "-")")
    }
    
    var body: some View {
        VStack {
            // 🔹 Barre d’action
            HStack {
                Button("Annuler") {
                    dismiss()
                }
                Spacer()
                Button("Enregistrer") {
                    saveAndClose()
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
            .padding()

            Divider()

            // 🧾 Vue principale
            InvoiceSheetView(viewModel: viewModel)
                .padding()
        }
        .frame(minWidth: 600, minHeight: 842)
    }

    private func saveAndClose() {
        viewModel.saveArticlesToInvoice()
        try? viewContext.save()
        selectedTab = "facture"
        dismiss()
    }
}
