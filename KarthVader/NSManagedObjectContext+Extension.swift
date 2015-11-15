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
    
}
