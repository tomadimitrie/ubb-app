//
//  NSManagedObjectContext+Extensions.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 21.02.2022.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    public func executeAndMergeChanges(_ batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
