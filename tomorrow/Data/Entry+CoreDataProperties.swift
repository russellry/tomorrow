//
//  Entry+CoreDataProperties.swift
//  
//
//  Created by Russell Ong on 9/8/20.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var task: String
    @NSManaged public var dateCreated: Date
    @NSManaged public var done: Bool
    @NSManaged public var id: Int64

}
