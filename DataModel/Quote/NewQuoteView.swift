import SwiftUI
import PDFKit
// ✅ Déclaration unique pour éviter les conflits
struct PDFWrapper: Identifiable {
    let id = UUID()
    let url: URL
}

struct NewQuoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var selectedClient: Contact?
    @State private var quoteArticles: [QuoteArticle] = []
    @State private var projectAddress = ""
    @State private var discount: Double = 0.0
    @State private var pdfWrapper: PDFWrapper?
    @State private var showingPDF = false
    @State private var showingClientSelection = false
    @State private var showingArticleSelection = false
    @State private var selectedArticles: [Article] = []

    var body: some View {
        VStack(spacing: 20) {
            // 🔹 Bouton de fermeture
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            Text("Devis n° DEV-2025-0006")
                .font(.title)
                .bold()
            
            // 🔹 Section Client & Adresse
            HStack(alignment: .top, spacing: 30) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Client :").font(.headline)
                    Button(action: { showingClientSelection = true }) {
                        if let client = selectedClient {
                            VStack(alignment: .leading) {
                                Text("\(client.firstName ?? "") \(client.lastName ?? "")").bold()
                                Text("\(client.street ?? ""), \(client.postalCode ?? "") \(client.city ?? "")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Text("+ Sélectionner un client").foregroundColor(.blue)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Adresse du projet :").font(.headline)
                    TextField("Ajouter une adresse", text: $projectAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 250)
                }
            }
            .padding()
            
            // 🔹 Section Articles
            VStack {
                HStack {
                    Text("Désignation").frame(width: 200, alignment: .leading)
                    Spacer()
                    Text("Qté").frame(width: 50, alignment: .center)
                    Text("PU HT").frame(width: 80, alignment: .trailing)
                    Text("Total HT").frame(width: 80, alignment: .trailing)
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(5)
                
                // 🔹 Affichage des articles sélectionnés
                ForEach($quoteArticles, id: \.self) { $quoteArticle in
                    HStack {
                        Button(action: {
                            quoteArticles.removeAll { $0 == quoteArticle }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text($quoteArticle.article.wrappedValue?.name ?? "-")
                            .frame(width: 200, alignment: .leading)
                        
                        Spacer()
                        
                        TextField("Qté", value: $quoteArticle.quantity, format: .number)
                            .frame(width: 50)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Prix", value: $quoteArticle.unitPrice, format: .currency(code: "EUR"))
                            .frame(width: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text(String(format: "%.2f €", $quoteArticle.unitPrice.wrappedValue * Double($quoteArticle.quantity.wrappedValue)))
                            .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.vertical, 5)
                }
                
                Button("+ Ajouter un article") {
                    showingArticleSelection = true
                }
                .foregroundColor(.blue)
            }
            .padding()
            
            // 🔹 Section Total
            VStack {
                HStack {
                    Text("Total HT :")
                    Spacer()
                    Text(String(format: "%.2f €", calculateTotal())).bold()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)
            
            // 🔹 Boutons d'action
            HStack {
                Button("Annuler") { dismiss() }
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button("Enregistrer") { saveQuote() }
                    .foregroundColor(.green)
                    .disabled(selectedClient == nil || quoteArticles.isEmpty)
                
                Button("Générer PDF") {
                    if let wrapper = generatePDF() {
                        pdfWrapper = wrapper
                        showingPDF = true
                    }
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
        .popover(isPresented: $showingClientSelection, arrowEdge: .top) {
            ClientSelectionView(selectedClient: $selectedClient)
                .environment(\.managedObjectContext, viewContext)
                .frame(minWidth: 400, minHeight: 500)
        }
        .popover(isPresented: $showingArticleSelection, arrowEdge: .top) {
            ArticleSelectionView(
                onArticleSelected: { article, quantity in
                    let newQuoteArticle = QuoteArticle(context: viewContext)
                    newQuoteArticle.article = article
                    newQuoteArticle.quantity = quantity  // ✅ Utilise la quantité sélectionnée
                    newQuoteArticle.unitPrice = article.price

                    quoteArticles.append(newQuoteArticle) // ✅ Ajout correct

                    try? viewContext.save() // ✅ Sauvegarde Core Data
                }
            )
            .environment(\.managedObjectContext, viewContext)
            .frame(minWidth: 400, minHeight: 500)
        }
    }

    // ✅ Calcul du total
    private func calculateTotal() -> Double {
        return quoteArticles.reduce(0.0) { total, quoteArticle in
            total + ((quoteArticle.unitPrice ?? 0) * Double(quoteArticle.quantity))
        }
    }

    // ✅ Enregistrement du devis
    private func saveQuote() {
        let newQuote = Quote(context: viewContext)
        newQuote.client = selectedClient
        newQuote.total = calculateTotal()

        guard !quoteArticles.isEmpty else {
            print("❌ Impossible d'enregistrer : Aucun article sélectionné.")
            return
        }

        for quoteArticle in quoteArticles {
            quoteArticle.quote = newQuote
        }

        do {
            try viewContext.save()
            print("✅ Devis enregistré avec succès.")
            dismiss()
        } catch {
            print("❌ Erreur lors de l'enregistrement du devis : \(error.localizedDescription)")
        }
    }
}

// ✅ Génération du PDF
private func generatePDF() -> PDFWrapper? {
    let pdfDocument = PDFDocument()
    let pdfPage = PDFPage(image: createImageFromView())

    if let pdfPage = pdfPage {
        pdfDocument.insert(pdfPage, at: 0)
    }

    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Devis.pdf")

    if let data = pdfDocument.dataRepresentation() {
        do {
            try data.write(to: fileURL)
            return PDFWrapper(url: fileURL) // ✅ Retourne un `PDFWrapper`
        } catch {
            print("❌ Erreur lors de la sauvegarde du PDF : \(error)")
        }
    }
    return nil
}

// ✅ Capture la vue en image pour PDF
private func createImageFromView() -> NSImage {
    let size = CGSize(width: 612, height: 792)
    let image = NSImage(size: size)

    image.lockFocus()
    NSColor.white.set()
    let rect = NSRect(origin: .zero, size: size)
    rect.fill()

    let title = "Devis n° DEV-2025-0006"
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 20)
    ]
    title.draw(at: CGPoint(x: 50, y: 750), withAttributes: attributes)

    image.unlockFocus()
    return image
}
