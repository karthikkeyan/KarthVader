//
//  NSManagedObject+Extension.swift
//  Components
//
//  Created by Karthik Keyan on 11/10/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    public class var entityName: String {
        let fullClassName = NSStringFromClass(self)
        
        let classComponent = fullClassName.componentsSeparatedByString(".")
        
        let className = classComponent.last
        
        return className!
    }
    
}
