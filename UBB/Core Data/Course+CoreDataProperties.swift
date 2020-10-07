//
//  Course+CoreDataProperties.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 07/10/2020.
//
//

import Foundation
import CoreData


extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged public var day: String
    @NSManaged public var endHour: Int16
    @NSManaged public var frequency: String
    @NSManaged public var name: String
    @NSManaged public var room: String
    @NSManaged public var startHour: Int16
    @NSManaged public var teacher: String
    @NSManaged public var type: String

}

extension Course : Identifiable {

}
