//
//  SelectedContactManager.swift
//  DataModel
//
//  Created by Quentin FABERES on 27/02/2025.
//


import SwiftUI

class SelectedContactManager: ObservableObject {
    @Published var contact: Contact?
}