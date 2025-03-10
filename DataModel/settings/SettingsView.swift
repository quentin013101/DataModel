import SwiftUI

struct ParametresView: View {
    // MARK: - Environnement et États
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: NSImage?
    @State private var companyName = ""
    @State private var address = ""
    @State private var postalCode = ""
    @State private var city = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var website = ""
    @State private var legalForm = "EURL"
    @State private var vatNumber = ""
    @State private var apeCode = ""
    @State private var shareCapital = ""
    @State private var iban = ""
    @State private var registrationType = "RCS"
    @State private var siret = ""

    // MARK: - Constantes et Chemins
    private let logoFilename = "companyLogo.png"
    private let savePath: URL

    private let legalForms = ["EURL", "SARL", "SAS", "Auto-entrepreneur"]
    private let registrationTypes = ["RCS", "RM", "SIREN", "SIRET"]

    // Largeur fixe pour l'alignement des labels
    private let labelWidth: CGFloat = 150

    // MARK: - Initialisation
    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        savePath = appSupport.appendingPathComponent("MonApp/\(logoFilename)")
    }

    // MARK: - Vue Principale
    var body: some View {
        VStack(spacing: 15) {
            // Titre centré
            Text("Paramètres")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

            Form {
                // Section En-tête
                Section(header: Text("📌 En-tête").frame(maxWidth: .infinity, alignment: .center)) {
                    VStack(alignment: .leading, spacing: 10) {
                        formRow(label: "Nom de l'entreprise", text: $companyName)
                        formRow(label: "Adresse", text: $address)
                        formRow(label: "Code Postal", text: $postalCode)
                        formRow(label: "Ville", text: $city)
                        formRow(label: "Téléphone", text: $phone)
                        formRow(label: "Email", text: $email)
                        formRow(label: "Site internet", text: $website)
                    }
                }

                // Section Logo
                Section(header: Text("📌 Logo de l'entreprise").frame(maxWidth: .infinity, alignment: .center)) {
                    VStack(spacing: 10) {
                        if let image = selectedImage {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .border(Color.gray, width: 1)
                        } else {
                            Text("Aucun logo sélectionné")
                                .foregroundColor(.gray)
                        }
                        HStack(spacing: 20) {
                            Button("Choisir un fichier") { openFilePicker() }
                            Button("Supprimer le logo") { removeLogo() }
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

                // Section Pied de page
                Section(header: Text("📜 Pied de page").frame(maxWidth: .infinity, alignment: .center)) {
                    VStack(alignment: .leading, spacing: 10) {
                        formPicker(label: "Forme juridique", selection: $legalForm, options: legalForms)
                        formRow(label: "N° TVA", text: $vatNumber)
                        formRow(label: "Code APE", text: $apeCode)
                        formRow(label: "Capital Social (€)", text: $shareCapital)
                        formRow(label: "IBAN", text: $iban)
                        formPicker(label: "Immatriculation", selection: $registrationType, options: registrationTypes)
                        // SIRET avec placeholder
                        HStack {
                            Text("SIRET").frame(width: labelWidth, alignment: .leading)
                            TextField("SIRET", text: $siret)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Boutons d'action centrés
            HStack {
                Button("Fermer") { dismiss() }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Spacer()

                Button("Enregistrer") { saveSettings() }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 650)
        .onAppear { loadSettings() }
    }

    // MARK: - Sous-vues

    /// Génère une ligne avec un champ texte.
    private func formRow(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label).frame(width: labelWidth, alignment: .leading)
            TextField("", text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    /// Génère une ligne avec un Picker.
    private func formPicker(label: String, selection: Binding<String>, options: [String]) -> some View {
        HStack {
            Text(label).frame(width: labelWidth, alignment: .leading)
            Picker("", selection: selection) {
                ForEach(options, id: \.self) { Text($0) }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    // MARK: - Gestion des fichiers et paramètres

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if let image = NSImage(data: data) {
                selectedImage = image
                saveImage(data)
            }
        } catch {
            print("❌ Erreur : Impossible de lire l’image - \(error)")
        }
    }

    private func saveImage(_ data: Data) {
        do {
            let folderURL = savePath.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            try data.write(to: savePath)
        } catch {
            print("❌ Erreur de sauvegarde du logo : \(error)")
        }
    }

    /// Charge l'ensemble des paramètres sauvegardés dans UserDefaults, ainsi que le logo.
    private func loadSettings() {
        let defaults = UserDefaults.standard
        companyName = defaults.string(forKey: "companyName") ?? ""
        address = defaults.string(forKey: "address") ?? ""
        postalCode = defaults.string(forKey: "postalCode") ?? ""
        city = defaults.string(forKey: "city") ?? ""
        phone = defaults.string(forKey: "phone") ?? ""
        email = defaults.string(forKey: "email") ?? ""
        website = defaults.string(forKey: "website") ?? ""
        legalForm = defaults.string(forKey: "legalForm") ?? "EURL"
        vatNumber = defaults.string(forKey: "vatNumber") ?? ""
        apeCode = defaults.string(forKey: "apeCode") ?? ""
        shareCapital = defaults.string(forKey: "shareCapital") ?? ""
        iban = defaults.string(forKey: "iban") ?? ""
        registrationType = defaults.string(forKey: "registrationType") ?? "RCS"
        siret = defaults.string(forKey: "siret") ?? ""
        
        // Charger le logo si le fichier existe
        if FileManager.default.fileExists(atPath: savePath.path),
           let imageData = try? Data(contentsOf: savePath),
           let image = NSImage(data: imageData) {
            selectedImage = image
        }
    }

    /// Sauvegarde l'ensemble des paramètres dans UserDefaults.
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(companyName, forKey: "companyName")
        defaults.set(address, forKey: "address")
        defaults.set(postalCode, forKey: "postalCode")
        defaults.set(city, forKey: "city")
        defaults.set(phone, forKey: "phone")
        defaults.set(email, forKey: "email")
        defaults.set(website, forKey: "website")
        defaults.set(legalForm, forKey: "legalForm")
        defaults.set(vatNumber, forKey: "vatNumber")
        defaults.set(apeCode, forKey: "apeCode")
        defaults.set(shareCapital, forKey: "shareCapital")
        defaults.set(iban, forKey: "iban")
        defaults.set(registrationType, forKey: "registrationType")
        defaults.set(siret, forKey: "siret")
        
        // Les modifications sont enregistrées dans UserDefaults
        print("✅ Paramètres sauvegardés")
        dismiss()
    }

    /// Supprime le logo enregistré.
    private func removeLogo() {
        do {
            if FileManager.default.fileExists(atPath: savePath.path) {
                try FileManager.default.removeItem(at: savePath)
                selectedImage = nil
                print("✅ Logo supprimé")
            }
        } catch {
            print("❌ Erreur lors de la suppression du logo : \(error)")
        }
    }
}
