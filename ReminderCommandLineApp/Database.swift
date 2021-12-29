//
//  Database.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 14/12/21.
//

import Foundation
/// Used to perform operations with Database, Types conforming to this protocol can be used for database operations
protocol Database {
    associatedtype ElementObject: Codable
    associatedtype ElementID: Comparable
    /// Creates an entry in the database and returns the generated ID and the result of the operation(Sucess/ Failure)
    func create(element: ElementObject) -> (ElementID, Bool)
    /// Returns the element present at that id
    func retrieve(id: ElementID) -> Reminder?
    /// Updates the database with the given ID
    func update(id: ElementID, element: ElementObject) -> Bool
    /// Deletes the element present at that id
    func delete(id: ElementID) -> Bool
}
class ReminderDB: Database {
    typealias ElementID = Int
    typealias ElementObject = Reminder
    private var databaseArray: Array<Reminder?>?
    private var idGenerator = 0
    init() {
        // connect db
        databaseArray = []
    }
    // Creates entry in table
    func create(element: Reminder) -> (Int, Bool) {
        // create a row in reminder table and return success/failure, along with generated row's id
        var success: Bool
        if databaseArray != nil {
            databaseArray?.append(element)
            success = true
            idGenerator = databaseArray!.count
        } else {
            Printer.printToConsole("failure in inserting data to database - no connection made yet!")
            success = false
        }
        return (idGenerator, success)
    }
    func retrieve(id: Int) -> Reminder? {
        // retrieve a row from reminder table if found, else return nil
        if databaseArray != nil {
            if databaseArray!.count >= id {
                return databaseArray?[id - 1]
            } else {
                Printer.printToConsole("failure in retrieving data from database - id not created yet")
                return nil
            }
        } else {
            Printer.printToConsole("failure in retrieving data from database - no connection made yet!")
            return nil
        }
    }
    func update(id: Int, element: Reminder) -> Bool {
        // update a row in reminder table and return success/failure
        var success: Bool
        if databaseArray != nil {
            if databaseArray!.count >= id {
                databaseArray?[id - 1] = element
                success = true
            } else {
                Printer.printToConsole("failure in updating data from database - id not created yet")
                success = false
            }
        } else {
            Printer.printToConsole("failure in updating data from database - no connection made yet!")
            success = false
        }
        return success
    }
    // Deletes entry in table
    func delete(id: Int) -> Bool {
        // delete a row in reminder table and return success/failure
        var success: Bool
        if databaseArray != nil {
            if databaseArray!.count >= id {
                databaseArray?[id - 1] = nil
                success = true
            } else {
                Printer.printToConsole("failure in deleting data from database - id not created yet")
                success = false
            }
        } else {
            Printer.printToConsole("failure in deleting data from database - no connection made yet!")
            success = false
        }
        return success
    }
}
