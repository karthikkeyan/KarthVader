//
//  NSManagedObjectContext+Parse.swift
//  KarthVaderExample
//
//  Created by Karthik Keyan on 11/17/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

typealias JSONDictionary = [String: AnyObject]

typealias JSONArray = [JSONDictionary]

extension NSManagedObjectContext {
    
    func parse<T: NSManagedObject>(json: JSONArray, type: T.Type) -> [T] {
        var objects = [T]()
        
        for dict in json {
            if let object = parse(dict, type: type) {
                objects.append(object)
            }
        }
        
        return objects as [T]
    }
    
    func parse<T: NSManagedObject>(json: JSONDictionary, type: T.Type) -> T? {
        let object = createObject(type, json: json)
        
        for (key, value) in json {
            insert(value: value, forKey: key, intoObject: object)
        }
        
        if let karthVaderObject = self as? KarthVaderObject, let specialKeyPaths = karthVaderObject.dynamicType.specialKeyPaths() {
            for (keyPath, attributeName) in specialKeyPaths {
                if let valueForAttribute = (json as NSDictionary).valueForKeyPath(keyPath) {
                    insert(value: valueForAttribute, forKey: attributeName, intoObject: object)
                }
            }
        }
        
        return object
    }
    
    
    // MARK: - Private Methods
    
    private func insert<T: NSManagedObject>(value value: AnyObject, forKey key: String, intoObject object: T) {
        var newValue: AnyObject = value
        
        // Object
        if value is JSONDictionary {
            guard let karthVaderObject = self as? KarthVaderObject, let subType = karthVaderObject.dynamicType.classForKey(key), let subObject = parse(value as! JSONDictionary, type: subType) else {
                return
            }
            
            newValue = subObject
        }
            // Array of objects
        else if value is JSONArray {
            // If array have sub models 'classForKey:' method will return the class type
            // else if array dont have sub models, we will consider the array as array of AnyObject
            guard let karthVaderObject = self as? KarthVaderObject, let subType = karthVaderObject.dynamicType.classForKey(key) else {
                return
            }
            
            var subObjects = Set<T>()
            
            for subValue in value as! JSONArray {
                if let subObject = parse(subValue, type: subType) as? T {
                    subObjects.insert(subObject)
                }
            }
            
            newValue = subObjects
        }
        
        // Simple Key-Value
        if object.respondsToSelector(Selector(key)) {
            object.setValue(newValue, forKeyPath: key)
        }
        else if let karthVaderObject = self as? KarthVaderObject, let forwardKey = karthVaderObject.dynamicType.keyForJSONKey(key) {
            object.setValue(newValue, forKeyPath: forwardKey)
        }
    }
    
    private func createObject<T: NSManagedObject>(type: T.Type, json: JSONDictionary) -> T {
        if let karthVaderObject = self as? KarthVaderObject, let primaryKey = karthVaderObject.dynamicType.primaryKey(), let value = json[primaryKey] {
            
            let fetchRequest = NSFetchRequest(entityName: type.entityName)
            fetchRequest.fetchOffset = 0
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "\(primaryKey) = \(value)")
            
            let result = try! self.executeFetchRequest(fetchRequest)
            
            if result.count > 0 {
                if let object = result.first as? T {
                    return object
                }
            }
        }
        
        
        let entity = NSEntityDescription.entityForName(type.entityName, inManagedObjectContext: self)
        
        return type.init(entity: entity!, insertIntoManagedObjectContext: self)
    }
    
}
