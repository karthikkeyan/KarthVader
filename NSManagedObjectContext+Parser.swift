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
            var newValue: AnyObject = value
            
            // Object
            if value is JSONDictionary {
                guard let subType = type.classForKey(key), let subObject = parse(value as! JSONDictionary, type: subType) else {
                    continue
                }
                
                newValue = subObject
            }
            // Array of objects
            else if value is JSONArray {
                // If array have sub models 'classForKey:' method will return the class type
                // else if array dont have sub models, we will consider the array as array of AnyObject
                guard let subType = type.classForKey(key) else {
                    continue
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
            object[key] = newValue
        }
        
        return object
    }
    
    
    // MARK: - Private Methods
    
    private func createObject<T: KarthVaderObject>(type: T.Type, json: JSONDictionary) -> T {
        if let primaryKey = type.primaryKey(), let value = json[primaryKey] {
            let objects = self.objects(type, filter: "\(primaryKey) = \(value)", sort: nil, chunk: NSMakeRange(0, 1))
            
            if let unwrappedObjects = objects, let firstObject = unwrappedObjects.first {
                return firstObject
            }
        }
        
        return type.init(context: self)
    }
    
}
