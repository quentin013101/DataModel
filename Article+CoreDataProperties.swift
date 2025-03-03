//
//  Article+CoreDataProperties.swift
//  DataModel
//
//  Created by Quentin FABERES on 28/02/2025.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var unit: String?
    @NSManaged public var cost: String?
    @NSManaged public var price: String?
    @NSManaged public var marginPercentage: String?
    @NSManaged public var marginAmount: String?

}

extension Article : Identifiable {

}
