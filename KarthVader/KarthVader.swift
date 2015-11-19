//
//  KarthVader.swift
//  Components
//
//  Created by Karthik Keyan on 10/30/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import CoreData

// MARK: - KarthVaderConfiguration

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


// MARK: - KarthVader

class KarthVader {
    
    // Static properties
    
    private static var managerObject: KarthVader?
    
    static var configuration: KarthVaderConfiguration = KarthVaderConfiguration.defaultConfiguration()
    
    
    // Private properties
    
    private var backgroundContext: NSManagedObjectContext?
    
    
    // Public properties
    
    var persistantStoreCoordinator: NSPersistentStoreCoordinator?
    
    var mainContext: NSManagedObjectContext?
    
    
    // MARK: - Class Methods
    
    class func sharedInstance() -> KarthVader {
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
        
        if let parentContext = KarthVader.sharedInstance().mainContext {
            context.parentContext = parentContext
        }
        else if let parentContext = KarthVader.sharedInstance().backgroundContext {
            context.parentContext = parentContext
        }
        else {
            context.persistentStoreCoordinator = KarthVader.sharedInstance().persistantStoreCoordinator
        }
        
        return context
    }
    
    class func transaction(closure: (context: NSManagedObjectContext) -> ()) {
        closure(context: KarthVader.writeContext())
    }
    
    class func transactionMain(closure: (context: NSManagedObjectContext) -> ()) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            closure(context: KarthVader.sharedInstance().mainContext!)
        }
    }
    
}



// MARK: - NSManagedObject

extension NSManagedObject {
    
    public class var entityName: String {
        let fullClassName = NSStringFromClass(self)
        
        let classComponent = fullClassName.componentsSeparatedByString(".")
        
        let className = classComponent.last
        
        return className!
    }
    
}


// MARK: - NSManagedObjectContext

private let fetchBatchSize = 20

extension NSManagedObjectContext {
    
    func commit(wait wait: Bool = false, completion: (() -> ())? = nil) {
        let colsure = {
            try! self.save()
            
            if let parent = self.parentContext {
                parent.commit(wait: wait, completion: completion)
            }
            else {
                if let completion = completion {
                    completion()
                }
            }
        }
        
        if wait {
            self.performBlockAndWait(colsure)
        }
        else {
            self.performBlock(colsure)
        }
    }
    
}
