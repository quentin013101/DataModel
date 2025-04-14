//
//  TransparentTextEditor.swift
//  DataModel
//
//  Created by Quentin FABERES on 14/04/2025.
//


import SwiftUI
import AppKit

struct TransparentTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.drawsBackground = false // important
        textView.backgroundColor = .clear // très important
        textView.font = NSFont.systemFont(ofSize: 12)
        textView.textColor = .black

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false // important
        scrollView.backgroundColor = .clear // très important
        scrollView.documentView = textView

        context.coordinator.textView = textView
        textView.delegate = context.coordinator

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let textView = context.coordinator.textView, textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TransparentTextEditor
        weak var textView: NSTextView?

        init(_ parent: TransparentTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            if let textView = textView {
                parent.text = textView.string
            }
        }
    }
}
