//
//  CompanyInfo.swift
//  DataModel
//
//  Created by Quentin FABERES on 08/03/2025.
//


import SwiftUI

/// Représente toutes les infos de l'entreprise
/// que vous saisissez dans `SettingsView`.
struct CompanyInfo {
    var logoData: Data?             // Logo de l'entreprise
    var companyName: String
    var artisanName: String
    var addressLine1: String     // Ex: "6 chemin du boudard"
    var addressLine2: String     // Ex: "13260 Cassis"
    var phone: String
    var email: String
    var website: String
    var legalForm: String
    var vatNumber: String
    var apeCode: String
    var shareCapital: String
    var iban: String
    var registrationType: String
    var siret: String
}

extension CompanyInfo {
    /// Lit les données dans UserDefaults et charge le logo sur le disque
    static func loadFromUserDefaults() -> CompanyInfo {
        let defaults = UserDefaults.standard

        // Lecture des champs enregistrés par `SettingsView`
        let companyName = defaults.string(forKey: "companyName") ?? ""
        let artisanName = defaults.string(forKey: "artisanName") ?? ""
        let addr        = defaults.string(forKey: "address") ?? ""
        let postal      = defaults.string(forKey: "postalCode") ?? ""
        let city        = defaults.string(forKey: "city") ?? ""
        let phone       = defaults.string(forKey: "phone") ?? ""
        let email       = defaults.string(forKey: "email") ?? ""
        let website     = defaults.string(forKey: "website") ?? ""
        let legalForm   = defaults.string(forKey: "legalForm") ?? "EURL"
        let vatNumber   = defaults.string(forKey: "vatNumber") ?? ""
        let apeCode     = defaults.string(forKey: "apeCode") ?? ""
        let shareCapital = defaults.string(forKey: "shareCapital") ?? ""
        let iban        = defaults.string(forKey: "iban") ?? ""
        let registrationType = defaults.string(forKey: "registrationType") ?? "RCS"
        let siret       = defaults.string(forKey: "siret") ?? ""

        // On construit deux lignes d'adresse (ex. "6 chemin du boudard" et "13260 Cassis")
        let addressLine1 = addr
        let addressLine2 = "\(postal) \(city)"

        // Charger le logo depuis Application Support/MonApp/companyLogo.png
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let savePath   = appSupport.appendingPathComponent("MonApp/companyLogo.png")

        var logoData: Data? = nil
        if FileManager.default.fileExists(atPath: savePath.path),
           let data = try? Data(contentsOf: savePath) {
            logoData = data
        }

        return CompanyInfo(
            logoData: logoData,
            companyName: companyName,
            artisanName: artisanName,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            phone: phone,
            email: email,
            website: website,
            legalForm: legalForm,
            vatNumber: vatNumber,
            apeCode: apeCode,
            shareCapital: shareCapital,
            iban: iban,
            registrationType: registrationType,
            siret: siret
        )
    }
}
