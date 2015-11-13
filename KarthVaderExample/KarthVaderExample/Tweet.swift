//
//  Tweet.swift
//  KarthVaderExample
//
//  Created by Karthik Keyan on 11/13/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import Foundation
import CoreData


class Tweet: KarthVaderObject {
    
    override class func specialKeyPaths() -> [String: String]? {
        return ["user.screen_name" : "userHandle", "user.profile_image_url_https" : "imageURL"]
    }
    
    override class func primaryKey() -> String? {
        return "feedID"
    }
    
    override class func keyForJSONKey(key: String) -> String? {
        var newKey: String? = nil
        
        if key == "screen_name" {
            newKey = "userHandle"
        }
        else if key == "profile_image_url_https" {
            newKey = "imageURL"
        }
        else if key == "id_str" {
            newKey = "feedID"
        }
        
        return newKey
    }

}
