//
//  KarthVaderObject.swift
//  Components
//
//  Created by Karthik Keyan on 10/31/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

protocol KarthVaderObject {
    
    static func primaryKey() -> String?
    
    static func classForKey(key: String) -> NSManagedObject.Type?
    
    static func keyForJSONKey(key: String) -> String?
    
    static func specialKeyPaths() -> [String: String]?
    
}


extension KarthVaderObject {
    
    static func primaryKey() -> String? {
        return nil
    }
    
    static func classForKey(key: String) -> NSManagedObject.Type? {
        return nil
    }
    
    static func keyForJSONKey(key: String) -> String? {
        return nil
    }
    
    static func specialKeyPaths() -> [String: String]? {
        return nil
    }
    
}
