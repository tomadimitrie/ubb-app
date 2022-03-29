//
//  EditedCourse+CoreDataProperties.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 21.02.2022.
//
//

import Foundation
import CoreData


extension EditedCourse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EditedCourse> {
        return NSFetchRequest<EditedCourse>(entityName: "EditedCourse")
    }

    @NSManaged public var id: String
    @NSManaged public var isHidden: Bool

}
