//
//  DiscountCommissionPopup.swift
//  DataModel
//
//  Created by Quentin FABERES on 19/03/2025.
//


import SwiftUI
import AppKit

struct DiscountCommissionPopup: View {
    @Binding var quoteArticles: [QuoteArticle]
    let netTotal: Double
    var applyDiscount: (Double, Bool) -> Void
    var applyCommission: (Double, Bool) -> Void
    
    @State private var isPercentage = true
    @State private var isDiscount = true
    @State private var amount: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Ajouter une Remise / Commission")
                .font(.headline)
                .padding(.top, 10)
            
            Picker("Type", selection: $isDiscount) {
                Text("Remise").tag(true)
                Text("Commission").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            
            TextField("Montant", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            Picker("Mode", selection: $isPercentage) {
                Text("Pourcentage").tag(true)
                Text("Montant Fixe").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            
            HStack {
                Button("Annuler") {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Appliquer") {
                    guard let value = Double(amount), value > 0 else { return }
                    if isDiscount {
                        applyDiscount(value, isPercentage)
                    } else {
                        applyCommission(value, isPercentage)
                    }
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 300)
        .padding()
    }
}
