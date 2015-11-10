//
//  KarthVaderObject.swift
//  Components
//
//  Created by Karthik Keyan on 10/31/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData


class KarthVaderObject: NSManagedObject {
    
    required override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    required convenience init(context: NSManagedObjectContext, values: Dictionary<String, AnyObject>? = nil) {
        let entity = NSEntityDescription.entityForName(self.dynamicType.entityName, inManagedObjectContext: context)
        
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        if let unwrappedValues = values {
            for (key, value) in unwrappedValues {
                self[key] = value
            }
        }
    }
    
    class func primaryKey() -> String? {
        return nil
    }
    
    class func classForKey(key: String) -> KarthVaderObject.Type? {
        return nil
    }
    
    class func keyForJSONKey(key: String) -> String? {
        return nil
    }
    
    
    // MARK: - Public Methods
    
    subscript(key: String) -> AnyObject? {
        get {
            return self.valueForKeyPath(key)
        }
        set {
            if self.respondsToSelector(Selector(key)) {
                self.setValue(newValue, forKeyPath: key)
            }
            else if let forwardKey = self.dynamicType.keyForJSONKey(key) {
                self.setValue(newValue, forKeyPath: forwardKey)
            }
        }
    }
    
}
