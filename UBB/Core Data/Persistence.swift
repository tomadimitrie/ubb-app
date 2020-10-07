//
//  Persistence.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 07/10/2020.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: "Timetable")
        if inMemory {
            self.container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        self.container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
