//
//  NotesController.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 03/01/22.
//

import Foundation

struct NotesController {
    
    private func createNotesInstance(
        title: String? = nil, description: String? = nil, addedTime: Date?
    ) -> Notes {
        return Notes(title: title, description: description, addedTime: addedTime)
    }
    
    private func createNotes() -> Notes {
        while true {
            let addedTime = Date.now
            let title = Input.getOptionalValue(name: "Title", for: "Notes")
            let description = Input.getOptionalValue(name: "Description", for: "Notes")
            return createNotesInstance(title: title, description: description, addedTime: addedTime)
        }
    }
    
    func add() {
        if NotesDB.connect() {
            Printer.printToConsole("Successfully created notes database")
        } else {
            Printer.printError("Failure in creating notes database")
            return
        }
        let notes = createNotes()
        let response = NotesDB.create(element: notes)
        if response.1 {
            Printer.printToConsole("Successfully created entry in notes database with ID = \(response.0)")
        } else {
            Printer.printError("Failure in creating entry in reminder database")
        }
    }
    
    func get(notesID: Int) -> Notes? {
        return NotesDB.retrieve(id: notesID)
    }
    
    func edit(notesID: Int, notes: Notes) {
        if NotesDB.update(id: notesID, element: notes) {
            Printer.printToConsole("Successfully updated to db")
        } else {
            Printer.printError("Updating notes db with id:\(notesID) unsuccessful")
        }
    }
    
    func delete(notesID: Int) {
        if NotesDB.delete(id: notesID) {
            Printer.printToConsole("Successfully deleted")
        } else {
            Printer.printError("Deleting Reminder from database unsuccessful")
        }
    }
    
    func changePreferences() {
    outerLoop:
        while true {
            Printer.printToConsole("Select: \n1. Set default title(\(NotesDefaults.title)) \n2. Set default description(\(NotesDefaults.description)) \n3. Exit \n")
            let integerInput = Input.getInteger(range: 1...3)
            switch integerInput {
            case 1:
                let title = Input.getResponse(string: "default title")
                NotesDefaults.setDefault(title: title)
            case 2:
                let description = Input.getResponse(string: "default description")
                NotesDefaults.setDefault(description: description)
            case 3:
                break outerLoop
            default:
                Printer.printError("Invalid input")
            }
        }
    }
}
