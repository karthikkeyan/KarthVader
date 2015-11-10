//
//  KarthVader.swift
//  Components
//
//  Created by Karthik Keyan on 10/30/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

struct KarthVaderConfiguration {
    
    var sqlFileName: String?
    
    var dataModelName: String?
    
    var migration: Bool = true
    
    static func defaultConfiguration() -> KarthVaderConfiguration {
        var manager = KarthVaderConfiguration()
        manager.sqlFileName = "DataBase.sqlite"
        
        return manager
    }
    
}

class KarthVader {
    
    // Static properties
    
    private static var managerObject: KarthVader?
    
    private static var configuration: KarthVaderConfiguration = KarthVaderConfiguration.defaultConfiguration()
    
    
    // Private properties
    
    private var backgroundContext: NSManagedObjectContext?
    
    
    // Public properties
    
    var persistantStoreCoordinator: NSPersistentStoreCoordinator?
    
    var mainContext: NSManagedObjectContext?
    
    
    // MARK: - Class Methods
    
    class func setConfiguration(configuration: KarthVaderConfiguration) {
        self.configuration = configuration
    }
    
    class func manager() -> KarthVader {
        if managerObject == nil {
            managerObject = KarthVader()
            managerObject?.setup()
        }
        
        return managerObject!
    }
    
    
    // MARK: - Private Methods
    
    private func setup() {
        if let dataModelName = KarthVader.configuration.dataModelName, let pathURL = NSBundle.mainBundle().URLForResource(dataModelName, withExtension: "momd") {
            if let objectModel = NSManagedObjectModel(contentsOfURL: pathURL) {
                persistantStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
                
                let options = [
                    NSMigratePersistentStoresAutomaticallyOption    :   KarthVader.configuration.migration,
                    NSInferMappingModelAutomaticallyOption          :   true
                ]
                
                // If there is no sqlite file to store, we will store objects in memory
                if let fileName = KarthVader.configuration.sqlFileName {
                    let pathComponent = [ NSHomeDirectory(), "Documents", fileName + ".sqlite" ]
                    
                    let pathString = NSString.pathWithComponents(pathComponent)
                    
                    let fileURL = NSURL(fileURLWithPath: pathString)
                    
                    try! persistantStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: fileURL, options: options)
                }
                else {
                    try! persistantStoreCoordinator?.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: options)
                }
                
                backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
                backgroundContext?.persistentStoreCoordinator = persistantStoreCoordinator
                
                mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
                mainContext?.parentContext = backgroundContext
            }
        }
    }
    
    
    // MARK: - Public Methods
    
    class func writeContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        if let parentContext = KarthVader.manager().mainContext {
            context.parentContext = parentContext
        }
        else if let parentContext = KarthVader.manager().backgroundContext {
            context.parentContext = parentContext
        }
        else {
            context.persistentStoreCoordinator = KarthVader.manager().persistantStoreCoordinator
        }
        
        return context
    }
    
}
