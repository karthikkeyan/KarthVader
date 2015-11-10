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

public let ChunkZero = NSMakeRange(0, 0)


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
    
    func objects<T: KarthVaderObject>(entity: T.Type, filter: String? = nil, sort: SortDescription? = nil, chunk: NSRange = ChunkZero, includePendingChanges: Bool = false) -> [T]? {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        fetchRequest.fetchBatchSize = fetchBatchSize
        fetchRequest.fetchOffset = chunk.location
        fetchRequest.fetchLimit = chunk.length
        fetchRequest.includesPendingChanges = includePendingChanges
        
        if let filter = filter {
            let predicate = NSPredicate(format: filter)
            fetchRequest.predicate = predicate
        }
        
        if let sort = sort {
            var sortDescriptors = [NSSortDescriptor]()
            for (key, value) in sort {
                let sortDescriptor = NSSortDescriptor(key: key, ascending: value)
                sortDescriptors.append(sortDescriptor)
            }
            
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        let result = try! self.executeFetchRequest(fetchRequest)
        
        return result as? [T]
    }
    
}
