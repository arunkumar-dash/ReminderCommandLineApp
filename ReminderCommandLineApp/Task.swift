//
//  Tasks.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 18/01/22.
//

import Foundation

protocol TaskProtocol: Identifiable {
    var taskDescription: String { get }
    var addedTime: Date { get }
    var deadline: Date { get }
    /// Sound is played when deadline is reached
    var sound: String { get }
    var id: TaskDB.ElementID? { get set }
}

struct Task: TaskProtocol, Codable {
    var taskDescription: String
    var addedTime: Date
    var deadline: Date
    var id: TaskDB.ElementID? = nil
    var sound: String
    
    init(addedTime: Date, task description: String, deadline: Date?, sound: String?) {
        self.addedTime = addedTime
        self.taskDescription = description
        self.deadline = TaskDefaults.setValue(deadline: deadline)
        self.sound = TaskDefaults.setValue(sound: sound)
    }
    
    static func viewTask(id: TaskDB.ElementID) {
        guard let task = TaskDB.retrieve(id: id) else {
            Printer.printError("Failed to retrieve task from database. Received a nil value.")
            return
        }
        Printer.printLine()
        Printer.printToConsole("Task")
        Printer.printLine()
        Printer.printToConsole("Description: \(task.taskDescription)")
        Printer.printToConsole("Deadline: \(task.deadline.description(with: .current))")
        Player.searchAndPlayAudio(fileName: task.sound)
        Printer.printLine()
    }
}


protocol TaskViewProtocol {
    func upcoming()
    func overdue()
    func completed()
}
