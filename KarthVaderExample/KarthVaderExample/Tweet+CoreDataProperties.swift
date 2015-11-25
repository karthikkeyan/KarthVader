//
//  Tweet+CoreDataProperties.swift
//  KarthVaderExample
//
//  Created by Karthik Keyan on 11/13/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tweet {

    @NSManaged var text: String?
    @NSManaged var userHandle: String?
    @NSManaged var imageURL: String?
    @NSManaged var feedID: String?

}
