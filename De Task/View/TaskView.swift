//
//  ContentView.swift
//  De Task
//
//  Created by I Gede Bagus Wirawan on 05/07/22.
//

import AuthenticationServices
import SwiftUI

//set enumaration
enum Priority: String, Identifiable, CaseIterable {
    
    var id: UUID {
        return UUID()
    }
    
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
}

//priority all cases
extension Priority {
    
    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
}

struct TaskView: View {
    
    //All Variable
    @State private var title: String = ""
    @State private var selectedPriority: Priority = .low
    
    //For keyboard
    @FocusState private var FormKeyboard : Bool
    @State private var showingAlert: Bool = false
    
    //For modalsheet
    @State private var showingSheet = false
    
    //Core data context
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allTask: FetchedResults<Task>
        
    var body: some View {
        
        //Navigation View
        NavigationView {
         
            VStack {
                
                Form {
                    
                    //Section Input Task
                    Section(header: Text("Add new task"), content: {
                        
                        //form enter title
                        TextField("Enter the title", text: $title)
                            .focused($FormKeyboard)
                        
                        //pick the priority
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(Priority.allCases) { priority in
                                Text(priority.title).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Button(action: {
                            SaveTask()
                        }, label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Save")
                            }
                        })
                        .padding(7.5)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .alert("Title cannot empty!", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
                        
                        
                    })
                    
                    Section(header: Text("All Task"), content: {
                        //result
                        List {
                            ForEach(allTask) { task in
                                HStack {
                                    Circle()
                                        .fill(styleForPriority(task.priority!))
                                        .frame(width: 15, height: 15)
                                    Spacer().frame(width: 20)
                                    Text(task.title ?? "")
                                    Spacer()
                                    Image(systemName: task.isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            updateTask(task)
                                        }
                                }
                            }.onDelete(perform: deleteTask)
                        }//.listStyle(InsetListStyle()) //List
                    })
                    
                } //Form
                
            } // Main VStack
            .navigationTitle("De Task")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    //button
                    Button(action: {
                        //add action
                        showingSheet.toggle()
                    }, label: {
                        Image("Gusde-Emot-BG")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    })
                    .sheet(isPresented: $showingSheet) {
                        SheetView()
                    }

                }
            } //Toolbar
            
        }
        //End of Navigation View
        
    } // View
    
    //All function
    private func SaveTask(){
        
        do {
            
            if title == "" {
                showingAlert = true
            } else {
                let task = Task(context: viewContext)
                task.title = title
                task.priority = selectedPriority.rawValue
                task.dateCreated = Date()
                
                try viewContext.save() //save
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
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
    
} //Struct Main

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        
        let persistentContainer = TaskViewModel.shared.persistentContainer
        
        TaskView().environment(\.managedObjectContext, persistentContainer.viewContext) //adding core data
    }
}

//Struct View
struct SheetView: View {
    //Enviroment
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var UserviewContext
    @FetchRequest(entity: UserCont.entity(), sortDescriptors: [NSSortDescriptor(key: "dataCreated", ascending: false)]) private var allUsers: FetchedResults<UserCont>

    
    //Appstore Storage
    @AppStorage("email") var email: String = ""
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("lastName") var lastName: String = ""
    @AppStorage("userId") var userId: String = ""


    var body: some View {
        
        NavigationView {
            
            VStack {
                
                if userId.isEmpty {
                    //New Stuff
                    SignInWithAppleButton(.continue) { request in
                        
                        //request
                        request.requestedScopes = [.email, .fullName]
                        
                    } onCompletion: { result in
                        
                        //result
                        switch result {
                            case .success(let auth):
                                switch auth.credential {
                                case let userCredential as ASAuthorizationAppleIDCredential:
                                    
                                    //user data
                                    let userId = userCredential.user
                                    
                                    let email = userCredential.email
                                    let firstName = userCredential.fullName?.givenName
                                    let lastName = userCredential.fullName?.familyName
                                    
                                    self.userId = userId
                                    self.email = email ?? ""
                                    self.firstName = firstName ?? ""
                                    self.lastName = lastName ?? ""
                                    
                                    //saveUsers
                                    SaveUsers()
                                    
                                    
                                default:
                                    break
                                }//credential
                            case .failure(let error):
                                print(error)
                        }
                        
                    } //SignIn
                    .signInWithAppleButtonStyle(
                        colorScheme == .dark ? .white : .black
                    )
                    .frame(height: 50)
                    .padding()
                    .cornerRadius(10)
                } //Condition
                else {
                    //Do Action
                    Image("Gusde-Emot")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    
                    Form {
                        
//                        ForEach(allUsers) { user in
//                            Text((user.firstName ?? "") + " " + (user.lastName ?? ""))
//                                .bold()
//                            Text(user.email)
//                        }
                        
                        Section {
                            Text(firstName + " " + lastName)
                                .bold()
                            Text(email)
                        }
                        
                        Section {
                            Button(action: {
                                //Do Action
                                deleteUsers()
                            }, label: {
                                Text("Sign Out")
                                    .foregroundColor(.red)
                            })
                        }
                        
                    
                    }
                    
                    Spacer()
                }
                
                
                
            } //VStack
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button("Done") {
                        dismiss()
                    }
                }
            } //Toolbar
            
        } //Navigationview
        

    } //BodyView
    
    //All function
    private func SaveUsers(){

        do {

            let users = UserCont(context: UserviewContext)

            users.userId = userId
            users.firstName = firstName
            users.lastName = lastName
            users.email = email
            users.dataCreated = Date()
            //users = userId

            try UserviewContext.save()
            print("Save Berhasil")
            

        } catch {
            print(error.localizedDescription)
        }

    }
    
    private func deleteUsers(){
        let users = UserCont(context: UserviewContext)
        UserviewContext.delete(users)
        
        do {
            try UserviewContext.save()
            print("Delete Berhasil")

        } catch {
            print(error.localizedDescription)
        }

    }
    //Function End
    
    
} //Struct ModalSheet
