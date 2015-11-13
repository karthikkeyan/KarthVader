//
//  NSManagedObjectContext+Extension.swift
//  Components
//
//  Created by Karthik Keyan on 10/31/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

typealias SortDescription = [String: Bool]

private let fetchBatchSize = 20


extension NSManagedObjectContext {
    
    func commit(wait wait: Bool = false, completion: (() -> ())? = nil) {
        let colsure = {
            try! self.save()
            
            if let parent = self.parentContext {
                parent.commit(wait: wait, completion: completion)
            }
            else {
                if let completion = completion {
                    completion()
                }
            }
        }
        
        if wait {
            self.performBlockAndWait(colsure)
        }
        else {
            self.performBlock(colsure)
        }
    }
    
    func objects<T: KarthVaderObject>(entity: T.Type, filter: String? = nil, sort: [NSSortDescriptor]? = nil, range: NSRange = NSRangeZero) -> [T]? {
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
    
    func firstObject<T: KarthVaderObject>(entity: T.Type, filter: String? = nil, sort: [NSSortDescriptor]? = nil) -> T? {
        let result = objects(entity, filter: filter, sort: sort, range: NSMakeRange(0, 1));
        
        if let unrappedResult = result {
            return unrappedResult.first
        }
        
        return nil
    }
    
}
