//
//  AppDelegate.swift
//  Arex
//
//  Created by Alexsander Akers on 2/9/15.
//  Copyright (c) 2015 Pandamonia. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data Stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "us.pandamonia.Arex" in the application's documents Application Support directory.
        let URLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return URLs.last as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Arex", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let URL = self.applicationDocumentsDirectory.URLByAppendingPathComponent(DatabaseFilename)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URL, options: nil, error: &error) == nil {
            coordinator = nil
            println("Unresolved error: \(Error.SavedDataInitializationFailure.toError(underlyingError: error))")
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        return self.persistentStoreCoordinator.map {
            let managedObjectContext = NSManagedObjectContext()
            managedObjectContext.persistentStoreCoordinator = $0
            return managedObjectContext
        }
    }()

    func saveContext () {
        if let context = self.managedObjectContext {
            var error: NSError? = nil
            if context.hasChanges && !context.save(&error) {
                NSLog("Unresolved error \(Error.SaveFailure.toError(underlyingError: error))")
            }
        }
    }

}
