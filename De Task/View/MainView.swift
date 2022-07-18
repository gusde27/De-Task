//
//  MainView.swift
//  De Task
//
//  Created by I Gede Bagus Wirawan on 05/07/22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        
        TabView {
            TaskView()
                .tabItem{
                    Label("Task", systemImage: "checklist")
                }
            
            LoveView()
                .tabItem{
                    Label("Love", systemImage: "heart.fill")
                }
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
