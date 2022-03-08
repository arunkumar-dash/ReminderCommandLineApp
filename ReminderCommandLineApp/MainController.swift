//
//  MainController.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 07/01/22.
//

import Foundation
class MainController {
    init() {
        login()
        NotificationManager.startBackgroundAction()
        Constant.updateFromDB()
        NotificationManager.updateFromDB()
        
        /// connecting for retrieving saved notifications
        
        ReminderDB.connect()
        NotesDB.connect()
        TaskDB.connect()
    }

    private func reminderController() {
        let controller = ReminderController()
        outerLoop:
        while true {
            Printer.printToConsole("Select: \n1. add \n2. retrieve \n3. update \n4. delete \n5. change preferences \n6. exit \n7. no action \n")
            let response = Input.getInteger(range: 1...8)
            switch response {
            case 1:
                controller.add()
            case 2:
                let id = Input.getInteger(range: 1..., name: "id")
                if let reminder = controller.get(reminderID: Int32(id)) {
                    if let id = reminder.id {
                        Reminder.viewReminder(id: id)
                    } else {
                        Printer.printError("Reminder id not found while trying to view.")
                    }
                } else {
                    Printer.printError("not found")
                }
            case 3:
                let id = Input.getInteger(range: 1..., name: "id")
                controller.edit(reminderID: Int32(id), reminder: controller.createReminder())
            case 4:
                let id = Input.getInteger(range: 1..., name: "id")
                controller.delete(reminderID: Int32(id))
            case 5:
                controller.changePreferences()
            case 6:
                break outerLoop
            case 7:
                break
            case 8:
                print(ReminderDB.getAllRows())
            default:
                Printer.printError("invalid case --unexpected")
            }
        }
    }

    private func notesController() {
        let controller = NotesController()
        outerLoop:
        while true {
            Printer.printToConsole("Select: \n1. add \n2. retrieve \n3. update \n4. delete \n5. change preferences \n6. convert to reminder \n7. exit\n")
            let response = Input.getInteger(range: 1...7)
            switch response {
            case 1:
                controller.add()
            case 2:
                let id = Input.getInteger(range: 1..., name: "id")
                if let notes = controller.get(notesID: Int32(id)) {
                    if let id = notes.id {
                        Notes.viewNotes(id: id)
                    } else {
                        Printer.printError("Notes id not found while trying to view.")
                    }
                } else {
                    Printer.printError("not found")
                }
            case 3:
                let id = Input.getInteger(range: 1..., name: "id")
                controller.edit(notesID: Int32(id), notes: controller.createNotes())
            case 4:
                let id = Input.getInteger(range: 1..., name: "id")
                controller.delete(notesID: Int32(id))
            case 5:
                controller.changePreferences()
            case 6:
                let id = Input.getInteger(range: 1..., name: "id")
                controller.convertToReminder(ReminderController(), id: Int32(id))
            case 7:
                break outerLoop
            default:
                Printer.printError("invalid case")
            }
        }
    }
    
    private func taskController() {
        let controller = TaskController()
    outerLoop:
        while true {
            Printer.printToConsole("Select: \n1. add \n2. retrieve \n3. update \n4. delete \n5. change preferences \n6. convert to reminder \n7. exit \n")
            let response = Input.getInteger(range: 1...7)
            switch response {
            case 1:
                controller.add()
            case 2:
                let id = Input.getInteger(range: 1..., name: "id")
                if let task = controller.get(taskID: Int32(id)) {
                    if let id = task.id {
                        Task.viewTask(id: id)
                    } else {
                        Printer.printError("Task id not found while trying to view.")
                    }
                } else {
                    Printer.printError("not found")
                }
            case 3:
                let id = Input.getInteger(range: 1..., name: "id")
                controller.edit(taskID: Int32(id), task: controller.createTask())
            case 4:
                let id = Input.getInteger(range: 1..., name: "id")
                controller.delete(taskID: Int32(id))
            case 5:
                controller.changePreferences()
            case 6:
                let id = Input.getInteger(range: 1..., name: "id")
                controller.convertToReminder(ReminderController(), id: Int32(id))
            case 7:
                break outerLoop
            default:
                Printer.printError("invalid case")
            }
        }
    }
    
    func run() {
    outerLoop:
        while true {
            Printer.printToConsole("Select: \n1. reminder \n2. notes \n3. task \n4. exit\n")
            let response = Input.getInteger(range: 1...4)
            switch response {
            case 1:
                reminderController()
            case 2:
                notesController()
            case 3:
                taskController()
            case 4:
                break outerLoop
            default:
                break
            }
        }
    }
    
    func login() {
        let credentialsDatabase = CredentialsDB()
        enum Login: String, CaseIterable {
            case login
            case signUp
        }
        // ask login/sign-up
        let response = Input.getEnumResponse(type: Login.self)
        // if sign-up : signUp()
        if response == .signUp {
            signUp()
        } else {
            // else :
            //  get username until it exists in database
            var username = Input.getResponse(string: "Username")
            var password = credentialsDatabase.getPassword(username:  username)
            while true {
                if password == nil {
                    if Input.getBooleanResponse(string: "Sign-up") {
                        signUp()
                        return
                    }
                    Printer.printError("Username does not exists in database")
                    username = Input.getResponse(string: "Username")
                    password = credentialsDatabase.getPassword(username:  username)
                } else {
                    //  get password until it matches with username
                    let passwordInput = Input.getResponse(string: "Password")
                    if passwordInput != password {
                        Printer.printError("Password did not match")
                    } else {
                        break
                    }
                }
            }
            CurrentUser.username = username
            Printer.printToConsole("Logged In")
            //  assign username to CurrentUser.username
        }
        
    }
    
    func signUp() {
        let credentialsDatabase = CredentialsDB()
        // get username until it is not present in database
        var username = Input.getResponse(string: "Username")
        var passwordFromDB = credentialsDatabase.getPassword(username:  username)
        while passwordFromDB != nil {
            Printer.printError("Username already exists")
            username = Input.getResponse(string: "Username")
            passwordFromDB = credentialsDatabase.getPassword(username:  username)
        }
        let password = Input.getResponse(string: "Password")
        // add to db
        while credentialsDatabase.insert(username: username, password: password) == false {
            Printer.printToConsole("Failed to add username to db")
            Printer.printToConsole("Retrying...")
            sleep(1)
        }
        CurrentUser.username = username
        Printer.printToConsole("Logged In")
        //  assign username to CurrentUser.username
    }
}
