//
//  LoveView.swift
//  De Task
//
//  Created by I Gede Bagus Wirawan on 05/07/22.
//

import SwiftUI


struct LoveView: View {
    
    //Core data context
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allTask: FetchedResults<Task>
        
    var body: some View {
        
        NavigationView {
            
            VStack {
                Form {
                    
                    Section(header: Text("Love Task"), content: {
                        //result
                        List {
                            ForEach(allTask) { task in
                                
                                if task.isFavorite {
                                    
                                    HStack {
                                        Circle()
                                            .fill(styleForPriority(task.priority!))
                                            .frame(width: 15, height: 15)
                                        Spacer().frame(width: 20)
                                        Text(task.title ?? "")
                                        Spacer()
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .onTapGesture {
                                                updateTask(task)
                                            }
                                    }
                                    
                                }
                                
                            }.onDelete(perform: deleteTask)
                        }//List
                        
                        
                    })
                    
                } //Form
            } //VStack
            .navigationTitle("Love")
            
        } //NavigationView
        
    } // Body View
    
    //All function
    
    private func styleForPriority(_ value: String) -> Color {
        let priority = Priority(rawValue: value)
        
        switch priority {
        case .low:
            return Color.green
        case .medium:
            return Color.orange
        case .high:
            return Color.red
        default:
            return Color.black
        }
        
    }
    
    private func updateTask(_ task: Task) {
        
        task.isFavorite = !task.isFavorite
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func deleteTask(at offsets: IndexSet){
        offsets.forEach { index in
            let task = allTask[index]
            viewContext.delete(task)
            
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    //End of All Function
    
    
} // Struct

struct LoveView_Previews: PreviewProvider {
    static var previews: some View {
        LoveView()
    }
}
