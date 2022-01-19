//
//  NotesController.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 03/01/22.
//

import Foundation
/// Controller of `Notes`
struct NotesController {
    
    init() {
        /// Initiating connection to database
        while connect() != true {
            sleep(3)
            Printer.printLoading("Trying to Connect database", forTime: 3)
        }
    }
    /// Returns a `Notes` instance
    /// - Parameters:
    ///  - title: The title of the Notes
    ///  - description: The description of the Notes
    ///  - addedTime: The `Date` when the notes was added
    /// - Returns: A `Notes` instance
    private func createNotesInstance(
        title: String? = nil, description: String? = nil, addedTime: Date?
    ) -> Notes {
        return Notes(title: title, description: description, addedTime: addedTime)
    }
    /// Creates a `Notes` instance and returns it
    /// - Returns: A `Notes` instance created from the user inputs
    func createNotes() -> Notes {
        while true {
            let addedTime = Date.now
            let title = Input.getOptionalResponse(name: "Title", for: "Notes")
            let description = Input.getOptionalResponse(name: "Description", for: "Notes")
            return createNotesInstance(title: title, description: description, addedTime: addedTime)
        }
    }
    /// Connects `Notes` database
    func connect() -> Bool {
        if NotesDB.connect() {
            Printer.printToConsole("Successfully connected notes database")
            return true
        } else {
            Printer.printError("Failure in connecting notes database")
            return false
        }
    }
    /// Adds the `Notes` instance to the database
    func add() {
        let notes = createNotes()
        let response = NotesDB.create(element: notes)
        if response.1 {
            Printer.printToConsole("Successfully created entry in notes database with ID = \(response.0)")
        } else {
            Printer.printError("Failure in creating entry in reminder database")
        }
    }
    /// Retrieves the `Notes` instance for the `id` passed in parameter
    ///
    /// - Parameter notesID: The row `id` of the database table
    /// - Returns: The `Notes` instance for that row `id`
    func get(notesID: NotesDB.ElementID) -> Notes? {
        return NotesDB.retrieve(id: Int32(notesID))
    }
    /// Updates the `Notes` present at the row`id` in the database table
    /// - Parameters:
    ///  - notesID: The row `id` of the data
    ///  - notes: The `Notes` instance to be replaced with
    func edit(notesID: NotesDB.ElementID, notes: Notes) {
        if NotesDB.update(id: Int32(notesID), element: notes) {
            Printer.printToConsole("Successfully updated to db")
        } else {
            Printer.printError("Updating notes db with id:\(notesID) unsuccessful")
        }
    }
    /// Deletes the data from the database at the row `id` passed in parameter
    /// - Parameter notesID: The `id` of the row to be deleted
    func delete(notesID: NotesDB.ElementID) {
        if NotesDB.delete(id: Int32(notesID)) {
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
    
    func convertToReminder(_ controller: ReminderController, id: NotesDB.ElementID) {
        let notes = self.get(notesID: id)
        if let notes = notes {
            controller.add(reminder: Reminder(addedTime: notes.addedTime, title: notes.title, description: notes.description, eventTime: nil, sound: nil, repeatTiming: nil, ringTimeIntervals: nil))
        }
    }
}
