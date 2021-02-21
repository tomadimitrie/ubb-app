//
//  UserSettings.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 02/10/2020.
//

import Foundation
import Combine
import SwiftUI
import CoreData

class UserSettings: ObservableObject {
    private init() {}
    
    static let shared = UserSettings()
    
    let persistenceController = PersistenceController.shared
    
    let objectWillChange = ObservableObjectPublisher()
    
    @UserDefault("year") var year: Year? = nil {
        willSet {
            self.group = nil
            self.semigroup = nil
            self.objectWillChange.send()
            self.clearTimetable()
        }
    }
    
    @UserDefault("group") var group: Group? = nil {
        willSet {
            self.semigroup = nil
            self.clearTimetable()
            self.objectWillChange.send()
        }
    }
    
    @UserDefault("semigroup") var semigroup: Semigroup? = nil {
        willSet {
            self.objectWillChange.send()
        }
        didSet {
            self.updateTimetable()
        }
    }
    
    @Published var weekViewType: WeekViewType = .both {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    func clearTimetable() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Course.fetchRequest()
        let result = try! self.persistenceController.container.viewContext.fetch(fetchRequest)
        for managedObject in result {
            if let managedObjectData: NSManagedObject = managedObject as? NSManagedObject {
                self.persistenceController
                    .container
                    .viewContext
                    .delete(managedObjectData)
            }
        }
    }
    
    func updateTimetable() {
        self.clearTimetable()
        if
            let year = self.year,
            let group = self.group,
            let semigroup = self.semigroup
        {
            TimetableService.shared.getTimetable(
                year: year,
                group: group,
                semigroup: semigroup
            ) { timetable in
                try! self.persistenceController
                    .container
                    .viewContext
                    .save()
            }
        }
    }
    
    func validateCourse(_ course: Course) -> Bool {
        if self.weekViewType != .both {
            if
                let week = course.frequency.last,
                let number = Int(String(week))
            {
                if
                    (number == 1 && self.weekViewType != .one) ||
                    (number == 2 && self.weekViewType != .two)
                {
                    return false
                }
            }
        }
        return true
    }
}
