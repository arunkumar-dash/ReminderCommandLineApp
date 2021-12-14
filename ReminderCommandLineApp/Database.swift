//
//  Database.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 14/12/21.
//

import Foundation
protocol Database {
    associatedtype ElementObject: Codable
    associatedtype ElementID: Comparable
    func create(element: ElementObject) -> (ElementID, Bool)
    func update(id: ElementID, element: ElementObject) -> Bool
    func delete(id: ElementID) -> Bool
    func get(id: ElementID) -> Reminder?
}
struct ReminderDB: Database {
    typealias ElementID = Int
    typealias ElementObject = Reminder
    init() {
        // create db
    }
    // Creates entry in table
    func create(element: Reminder) -> (Int, Bool) {
        // create a row in reminder table and return success/failure, along with generated row's id
        return (1, true)
    }
    // Deletes entry in table
    func delete(id: Int) -> Bool {
        // delete a row in reminder table and return success/failure
        return true
    }
    func update(id: Int, element: Reminder) -> Bool {
        // update a row in reminder table and return success/failure
        return true
    }
    func get(id: Int) -> Reminder? {
        return nil
    }
}
