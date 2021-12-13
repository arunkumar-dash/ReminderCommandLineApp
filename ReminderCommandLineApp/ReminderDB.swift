//
//  ReminderDB.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 13/12/21.
//

import Foundation
struct ReminderDB {
    init() {
        // create db
    }
    // Creates entry in table
    func create(reminder: Reminder) -> Bool {
        // create a row in reminder table and return success/failure
        return true
    }
    // Deletes entry in table
    func delete(reminderID: Int) -> Bool {
        // delete a row in reminder table and return success/failure
        return true
    }
    func update(reminder: Reminder, reminderID: Int) -> Bool {
        // update a row in reminder table and return success/failure
        return true
    }
}
