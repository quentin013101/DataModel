import SwiftUI
import AppKit

struct LogoImageView: NSViewRepresentable {
    let imageData: Data?
    let size: CGSize

    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageAlignment = .alignCenter
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.wantsLayer = true

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size.width),
            imageView.heightAnchor.constraint(equalToConstant: size.height)
        ])

        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
        if let data = imageData, let nsImage = NSImage(data: data) {
            nsView.image = nsImage
        } else {
            nsView.image = nil
        }
    }
}
