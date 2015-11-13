//
//  NSManagedObjectContext+Parser.swift
//  Components
//
//  Created by Karthik Keyan on 11/2/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

typealias JSONDictionary = [String: AnyObject]

typealias JSONArray = [JSONDictionary]

extension NSManagedObjectContext {
    
    // MARK: - Public Methods
    
    func parse<T: KarthVaderObject>(json: JSONArray, type: T.Type) -> [T] {
        var objects = [T]()
        
        for dict in json {
            if let object = parse(dict, type: type) {
                objects.append(object)
            }
        }
        
        return objects
    }
    
    func parse<T: KarthVaderObject>(json: JSONDictionary, type: T.Type) -> T? {
        let object = createObject(type, json: json)
        
        for (key, value) in json {
            insert(value: value, forKey: key, intoObject: object)
        }
        
        if let specialKeyPaths = type.specialKeyPaths() {
            for (keyPath, attributeName) in specialKeyPaths {
                if let valueForAttribute = (json as NSDictionary).valueForKeyPath(keyPath) {
                    insert(value: valueForAttribute, forKey: attributeName, intoObject: object)
                }
            }
        }
        
        return object
    }
    
    
    // MARK: - Private Methods
    
    func insert<T: KarthVaderObject>(value value: AnyObject, forKey key: String, intoObject object: T) {
        let type = T.self
        var newValue: AnyObject = value
        
        // Object
        if value is JSONDictionary {
            guard let subType = type.classForKey(key), let subObject = parse(value as! JSONDictionary, type: subType) else {
                return
            }
            
            newValue = subObject
        }
        // Array of objects
        else if value is JSONArray {
            // If array have sub models 'classForKey:' method will return the class type
            // else if array dont have sub models, we will consider the array as array of AnyObject
            guard let subType = type.classForKey(key) else {
                return
            }
            
            var subObjects = Set<KarthVaderObject>()
            
            for subValue in value as! JSONArray {
                if let subObject = parse(subValue, type: subType) {
                    subObjects.insert(subObject)
                }
            }
            
            newValue = subObjects
        }
        
        // Simple Key-Value
        if object.respondsToSelector(Selector(key)) {
            object.setValue(newValue, forKeyPath: key)
        }
        else if let forwardKey = type.keyForJSONKey(key) {
            object.setValue(newValue, forKeyPath: forwardKey)
        }
    }
    
    private func createObject<T: KarthVaderObject>(type: T.Type, json: JSONDictionary) -> T {
        if let primaryKey = type.primaryKey(), let value = json[primaryKey] {
            if let object = self.firstObject(type, filter: "\(primaryKey) = \(value)", sort: nil) {
                return object
            }
        }
        
        return type.init(context: self)
    }
    
}
