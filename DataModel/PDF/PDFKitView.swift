//
//  PDFKitView.swift
//  DataModel
//
//  Created by Quentin FABERES on 03/03/2025.
//


import SwiftUI
import PDFKit

struct PDFKitView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {}
}