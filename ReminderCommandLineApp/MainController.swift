//
//  MainController.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 07/01/22.
//

import Foundation
class MainController {
    init() {
        NotificationManager.startBackgroundAction()
        Constant.updateFromDB()
        NotificationManager.updateFromDB()
        ReminderDB.connect()
        NotesDB.connect()
        TaskDB.connect()
    }

    private func reminderController() {
        let controller = ReminderController()
        outerLoop:
        while true {
            Printer.printToConsole("Select: \n1. add \n2. retrieve \n3. update \n4. delete \n5. change preferences \n6. exit \n7. no action \n")
            let response = Input.getInteger(range: 1...7)
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
}
