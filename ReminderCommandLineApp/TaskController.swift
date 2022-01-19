//
//  TasksController.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 18/01/22.
//

import Foundation


struct TaskController {
    init() {
        
        while connect() != true {
            sleep(3)
            Printer.printLoading("Trying to Connect database", forTime: 3)
        }
    }
    
    func createTask() -> Task {
        let taskDescription = Input.getResponse(string: "Task")
        let deadline = Input.getOptionalDate(name: "Deadline")
        let sound = Input.getOptionalResponse(name: "sound", for: "Task")
        let addedTime = Date.now
        return Task(addedTime: addedTime, task: taskDescription, deadline: deadline, sound: sound)
    }
    
    func connect() -> Bool {
        if TaskDB.connect() {
            Printer.printToConsole("Successfully connected task database")
            return true
        } else {
            Printer.printError("Failure in connecting task database")
            return false
        }
    }
    
    func add() {
        var task = createTask()
        let response = TaskDB.create(element: task)
        if response.result {
            Printer.printToConsole("Successfully created entry in task database with ID = \(response.id)")
            task.id = response.id
        } else {
            Printer.printError("Failure in creating database entry")
        }
        // add to notification
        do {
            try NotificationManager.push(task: task)
        } catch let error {
            Printer.printError(error)
        }
    }
    
    func get(taskID: TaskDB.ElementID) -> Task? {
        return TaskDB.retrieve(id: taskID)
    }
    
    func edit(taskID: TaskDB.ElementID, task: Task) {
        do {
            if let task = TaskDB.retrieve(id: taskID) {
                try NotificationManager.pop(task: task)
            } else {
                Printer.printError("Failure in retrieving from TaskDB")
                return
            }
        } catch let error {
            Printer.printError(error)
            return
        }
        var mutableTask = task
        mutableTask.id = taskID
        if TaskDB.update(id: taskID, element: mutableTask) {
            Printer.printToConsole("Successfully updated to db")
            do {
                try NotificationManager.push(task: mutableTask)
            } catch let error {
                Printer.printError("Error while updating task notification")
                Printer.printError(error)
            }
        } else {
            Printer.printError("Updating task db with id:\(taskID) unsuccessful")
            return
        }
    }
    
    func delete(taskID: TaskDB.ElementID) {
        do {
            if let task = TaskDB.retrieve(id: taskID) {
                try NotificationManager.pop(task: task)
            }
        } catch let error {
            Printer.printError(error)
        }
        if TaskDB.delete(id: taskID) {
            Printer.printToConsole("Successfully deleted")
        } else {
            Printer.printError("Deleting task from database unsuccessful")
        }
    }
    
    func changePreferences() {
    outerLoop:
        while true {
            Printer.printToConsole("Select: \n1. Set default deadline(\(TaskDefaults.deadline)) \n2. Exit \n")
            let integerInput = Input.getInteger(range: 1...2)
            switch integerInput {
            case 1:
                let deadline = Input.getDate()
                TaskDefaults.setDefault(deadline: deadline)
            case 2:
                break outerLoop
            default:
                Printer.printToConsole("Invalid case")
            }
        }
    }
    
    func convertToReminder(_ controller: ReminderController, id: TaskDB.ElementID) {
        let task = self.get(taskID: id)
        if let task = task {
            let taskString = "Task"
            controller.add(reminder: Reminder(addedTime: task.addedTime, title: taskString, description: task.taskDescription, eventTime: task.deadline, sound: task.sound, repeatTiming: nil, ringTimeIntervals: nil))
        }
    }
}
