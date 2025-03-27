//
//  PDFBorderedBoxView.swift
//  DataModel
//
//  Created by Quentin FABERES on 27/03/2025.
//


import SwiftUI
import AppKit

struct PDFBorderedBoxView: NSViewRepresentable {
    var backgroundColor: NSColor = .white
    var borderColor: NSColor = .black
    var cornerRadius: CGFloat = 4
    var borderWidth: CGFloat = 1

    func makeNSView(context: Context) -> NSView {
        let view = NSBox()
        view.boxType = .custom
        view.fillColor = backgroundColor
        view.borderColor = borderColor
        view.borderWidth = borderWidth
        view.cornerRadius = cornerRadius
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let box = nsView as? NSBox else { return }
        box.fillColor = backgroundColor
        box.borderColor = borderColor
        box.borderWidth = borderWidth
        box.cornerRadius = cornerRadius
    }
}