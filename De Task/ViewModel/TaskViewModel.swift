//
//  TaskViewModel.swift
//  De Task
//
//  Created by I Gede Bagus Wirawan on 05/07/22.
//

import Foundation
import CoreData
import CloudKit

class TaskViewModel {
    
    let persistentContainer: NSPersistentContainer
    static let shared : TaskViewModel = TaskViewModel()
    
    init(){
        persistentContainer = NSPersistentCloudKitContainer(name: "SimpleToDoModel")
        
        persistentContainer.loadPersistentStores { description, error in
            
            //description.cloudKitContainerOptions?.databaseScope = .public
            if let error = error {
                fatalError("Unsolved error: \(error)")
                
            }
        }
        
        //CloudKit
//        guard let description = persistentContainer.persistentStoreDescriptions.first else {
//             print("Can't set description")
//             fatalError("Error")
//         }
//
//        description.cloudKitContainerOptions?.databaseScope = .public
        
        //description.cloudKitContainerOptions.
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
    } //init
    
    
    
} //class
