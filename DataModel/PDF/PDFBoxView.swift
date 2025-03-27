//
//  PDFBoxView.swift
//  DataModel
//
//  Created by Quentin FABERES on 27/03/2025.
//


import SwiftUI
import AppKit

struct PDFBoxView: NSViewRepresentable {
    var backgroundColor: NSColor
    var cornerRadius: CGFloat = 0

    func makeNSView(context: Context) -> NSView {
        let box = NSBox()
        box.boxType = .custom
        box.fillColor = backgroundColor
        box.borderColor = .clear
        box.borderWidth = 0
        box.cornerRadius = cornerRadius
        return box
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let box = nsView as? NSBox else { return }
        box.fillColor = backgroundColor
    }
}
