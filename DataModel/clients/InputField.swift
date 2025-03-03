import SwiftUI

struct InputField: View {
    let label: String
    @Binding var text: String
    let isEditing: Bool // ✅ Ajout de isEditing

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(!isEditing) // ✅ Désactivation si non éditable
        }
    }
}

struct InputFieldWithError: View {
    let label: String
    @Binding var text: String
    @Binding var error: String?
    let isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .frame(width: 120, alignment: .leading)
                TextField("", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!isEditing)
            }
            if let error = error {
                Text(error).foregroundColor(.red).font(.caption)
            }
        }
    }
}
