//
//  IsPrintingKey.swift
//  DataModel
//
//  Created by Quentin FABERES on 28/03/2025.
//


import SwiftUI

private struct IsPrintingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isPrinting: Bool {
        get { self[IsPrintingKey.self] }
        set { self[IsPrintingKey.self] = newValue }
    }
}