//
//  NSManagedObjectContext+Fetch.swift
//  KarthVaderExample
//
//  Created by Karthik Keyan on 11/17/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

private let fetchBatchSize = 20

public let NSRangeZero = NSMakeRange(0, 0)

extension NSManagedObjectContext {
    
    func fetch<T: NSManagedObject>(entity: T.Type, filter: String? = nil, sort: [NSSortDescriptor]? = nil, range: NSRange = NSRangeZero) -> [T]? {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        fetchRequest.fetchBatchSize = fetchBatchSize
        fetchRequest.fetchOffset = range.location
        fetchRequest.fetchLimit = range.length
        
        if let filter = filter {
            let predicate = NSPredicate(format: filter)
            fetchRequest.predicate = predicate
        }
        
        if let sort = sort {
            fetchRequest.sortDescriptors = sort
        }
        
        let result = try! self.executeFetchRequest(fetchRequest)
        
        return result as? [T]
    }
    
    func firstObject<T: NSManagedObject>(entity: T.Type, filter: String? = nil, sort: [NSSortDescriptor]? = nil) -> T? {
        let result = fetch(entity, filter: filter, sort: sort, range: NSMakeRange(0, 1));
        
        if let unrappedResult = result {
            return unrappedResult.first
        }
        
        return nil
    }
    
}