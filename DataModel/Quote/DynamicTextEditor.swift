import SwiftUI
import AppKit

struct DynamicTextEditor: View {
    @Binding var text: String
    var minHeight: CGFloat = 22
    var width: CGFloat
    @Binding var height: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.system(size: 9))
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                        recalculateHeight(in: geometry.size)
                    }
                    .onChange(of: text) { _ in
                        recalculateHeight(in: geometry.size)
                    }
                })
        }
        .frame(height: height)
    }

    private func recalculateHeight(in size: CGSize) {
        let nsString = NSString(string: text)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9)
        ]
        let boundingRect = nsString.boundingRect(
            with: CGSize(width: width - 4, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: attributes
        )
        DispatchQueue.main.async {
            height = max(minHeight, ceil(boundingRect.height) + 8)
        }
    }
}
