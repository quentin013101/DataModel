//
//  PDFViewer.swift
//  DataModel
//
//  Created by Quentin FABERES on 03/03/2025.
//
import SwiftUI
import PDFKit

struct PDFViewer: View {
    let url: URL
    let onClose: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            PDFKitView(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
