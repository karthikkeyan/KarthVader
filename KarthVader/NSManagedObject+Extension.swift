//
//  NSManagedObject+Extension.swift
//  Components
//
//  Created by Karthik Keyan on 11/10/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    convenience public init(context: NSManagedObjectContext, values: Dictionary<String, AnyObject>? = nil) {
        let entity = NSEntityDescription.entityForName(self.dynamicType.entityName, inManagedObjectContext: context)
        
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
    }
    
    
    public class var entityName: String {
        let fullClassName = NSStringFromClass(self)
        
        let classComponent = fullClassName.componentsSeparatedByString(".")
        
        let className = classComponent.last
        
        return className!
    }
    
}
