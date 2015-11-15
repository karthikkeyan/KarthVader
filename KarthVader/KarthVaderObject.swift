//
//  KarthVaderObject.swift
//  Components
//
//  Created by Karthik Keyan on 10/31/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

typealias JSONDictionary = [String: AnyObject]

typealias JSONArray = [JSONDictionary]


private let fetchBatchSize = 20

public let NSRangeZero = NSMakeRange(0, 0)


class KarthVaderObject: NSManagedObject {
    
    required override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    required convenience init(context: NSManagedObjectContext, values: Dictionary<String, AnyObject>? = nil) {
        let entity = NSEntityDescription.entityForName(self.dynamicType.entityName, inManagedObjectContext: context)
        
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        if let unwrappedValues = values {
            for (key, value) in unwrappedValues {
                if self.respondsToSelector(Selector(key)) {
                    self.setValue(value, forKeyPath: key)
                }
                else if let forwardKey = self.dynamicType.keyForJSONKey(key) {
                    self.setValue(value, forKeyPath: forwardKey)
                }
            }
        }
    }
    
}


// MARK: - Parsing Utility

extension KarthVaderObject {
    
    class func primaryKey() -> String? {
        return nil
    }
    
    class func classForKey(key: String) -> KarthVaderObject.Type? {
        return nil
    }
    
    class func keyForJSONKey(key: String) -> String? {
        return nil
    }
    
    class func specialKeyPaths() -> [String: String]? {
        return nil
    }
    
}



// MARK: - Parser

extension KarthVaderObject {
    
    class func parse<T: KarthVaderObject>(json: JSONArray, context: NSManagedObjectContext, type: T.Type) -> [T] {
        var objects = [T]()
        
        for dict in json {
            if let object = parse(dict, context: context, type: type) {
                objects.append(object)
            }
        }
        
        return objects as [T]
    }
    
    class func parse<T: KarthVaderObject>(json: JSONDictionary, context: NSManagedObjectContext, type: T.Type) -> T? {
        let object = createObject(type, json: json, context: context)
        
        for (key, value) in json {
            insert(value: value, forKey: key, intoObject: object, context: context)
        }
        
        if let specialKeyPaths = self.specialKeyPaths() {
            for (keyPath, attributeName) in specialKeyPaths {
                if let valueForAttribute = (json as NSDictionary).valueForKeyPath(keyPath) {
                    insert(value: valueForAttribute, forKey: attributeName, intoObject: object, context: context)
                }
            }
        }
        
        return object
    }
    
    
    // MARK: - Private Methods
    
    private class func insert<T: KarthVaderObject>(value value: AnyObject, forKey key: String, intoObject object: T, context: NSManagedObjectContext) {
        var newValue: AnyObject = value
        
        // Object
        if value is JSONDictionary {
            guard let subType = self.classForKey(key), let subObject = subType.parse(value as! JSONDictionary, context: context, type: subType) else {
                return
            }
            
            newValue = subObject
        }
            // Array of objects
        else if value is JSONArray {
            // If array have sub models 'classForKey:' method will return the class type
            // else if array dont have sub models, we will consider the array as array of AnyObject
            guard let subType = self.classForKey(key) else {
                return
            }
            
            var subObjects = Set<T>()
            
            for subValue in value as! JSONArray {
                if let subObject = subType.parse(subValue, context: context, type: subType) as? T {
                    subObjects.insert(subObject)
                }
            }
            
            newValue = subObjects
        }
        
        // Simple Key-Value
        if object.respondsToSelector(Selector(key)) {
            object.setValue(newValue, forKeyPath: key)
        }
        else if let forwardKey = self.keyForJSONKey(key) {
            object.setValue(newValue, forKeyPath: forwardKey)
        }
    }
    
    private class func createObject<T: KarthVaderObject>(type: T.Type, json: JSONDictionary, context: NSManagedObjectContext) -> T {
        if let primaryKey = self.primaryKey(), let value = json[primaryKey] {
            if let object = self.firstObject(type, context: context, filter: "\(primaryKey) = \(value)", sort: nil) {
                return object
            }
        }
        
        return type.init(context: context)
    }
}



// MARK: - Fetch

extension KarthVaderObject {
    class func fetch<T: KarthVaderObject>(entity: T.Type, context: NSManagedObjectContext, filter: String? = nil, sort: [NSSortDescriptor]? = nil, range: NSRange = NSRangeZero) -> [T]? {
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
        
        let result = try! context.executeFetchRequest(fetchRequest)
        
        return result as? [T]
    }
    
    class func firstObject<T: KarthVaderObject>(entity: T.Type, context: NSManagedObjectContext, filter: String? = nil, sort: [NSSortDescriptor]? = nil) -> T? {
        let result = fetch(entity, context: context, filter: filter, sort: sort, range: NSMakeRange(0, 1));
        
        if let unrappedResult = result {
            return unrappedResult.first
        }
        
        return nil
    }
}
