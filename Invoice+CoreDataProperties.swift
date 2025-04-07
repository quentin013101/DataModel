//
//  Invoice+CoreDataProperties.swift
//  DataModel
//
//  Created by Quentin FABERES on 04/04/2025.
//
//

import Foundation
import CoreData


extension Invoice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Invoice> {
        return NSFetchRequest<Invoice>(entityName: "Invoice")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var status: String?
    @NSManaged public var isPartial: Bool
    @NSManaged public var partialAmount: Double
    @NSManaged public var totalHT: Double
    @NSManaged public var tva: Double
    @NSManaged public var totalTTC: Double
    @NSManaged public var paymentTerms: String?
    @NSManaged public var invoiceNumber: String?
    @NSManaged public var quote: Quote?

}

extension Invoice : Identifiable {

}
