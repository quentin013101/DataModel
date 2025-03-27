//
//  PDFLineView.swift
//  DataModel
//
//  Created by Quentin FABERES on 27/03/2025.
//


import SwiftUI
import AppKit

struct PDFLineView: NSViewRepresentable {
    var color: NSColor = .white

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = color.cgColor
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.layer?.backgroundColor = color.cgColor
    }
}
