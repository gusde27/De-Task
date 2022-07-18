//
//  De_TaskApp.swift
//  De Task
//
//  Created by I Gede Bagus Wirawan on 05/07/22.
//

import SwiftUI

@main
struct De_TaskApp: App {
    
    //add core data for CRUD
    let persistentContainer = TaskViewModel.shared.persistentContainer
    
    var body: some Scene {
        WindowGroup {
            MainView().environment(\.managedObjectContext, persistentContainer.viewContext) //adding core data
        }
    }
}
