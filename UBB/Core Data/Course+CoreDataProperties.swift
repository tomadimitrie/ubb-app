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
    public class func fetchRequest() -> NSFetchRequest<Course> {
        NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged public var day: String
    @NSManaged public var endHour: Int16
    @NSManaged public var endMinute: Int16
    @NSManaged public var frequency: String
    @NSManaged public var name: String
    @NSManaged public var room: String
    @NSManaged public var startHour: Int16
    @NSManaged public var startMinute: Int16
    @NSManaged public var teacher: String
    @NSManaged public var type: String
}

extension Course : Identifiable {}
