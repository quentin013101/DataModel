//
//  ScalableA4SheetView.swift
//  DataModel
//
//  Created by Quentin FABERES on 19/03/2025.
//


import SwiftUI

struct ScalableA4SheetView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var documentHeight: CGFloat  // hauteur dynamique du document (> ou = à 842)
    
    private let a4Width: CGFloat = 595
    private let a4Height: CGFloat = 842
    
    var body: some View {
        GeometryReader { geometry in
            // Hauteur disponible pour la vue A4SheetView
            let availableHeight = geometry.size.height
            
            // Facteur d'échelle : pour remplir toute la hauteur disponible avec 842 points du doc
            let scaleFactor = availableHeight / a4Height
            
            // Largeur proportionnelle à ce facteur
            let scaledWidth = a4Width * scaleFactor
            
            ScrollView(.vertical) {
                content()
                    .frame(width: a4Width, height: documentHeight)
                    .scaleEffect(scaleFactor, anchor: .topLeading)
                    .frame(width: scaledWidth, height: documentHeight * scaleFactor, alignment: .topLeading)
            }
            .frame(width: scaledWidth, height: availableHeight)
            .background(Color.white.shadow(radius: 2))
        }
    }
}