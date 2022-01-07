//
//  ReminderController.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 13/12/21.
//

import Foundation

/// Controller for handling operations of a Reminder
struct ReminderController {
    
    enum ReminderError: Error {
        case invalidEventTime
    }
    /// Returns a Reminder instance
    ///
    /// - Parameters:
    ///     - title: The title of the `Reminder`
    ///     - description: The description of the `Reminder`
    ///     - eventTime: The time when the `Reminder` should ring
    ///     - sound: The sound which the `Reminder` should ring
    ///     - repeatTiming: The repetitions of the `Reminder`
    ///     - ringTimeIntervals: The `Set` of `TimeInterval`s when the `Reminder` should ring before the `eventTime`
    /// - Returns: A `Reminder` object
    private func createReminderInstance(
        addedTime: Date, title: String? = nil, description: String? = nil, eventTime: Date?,
        sound: String? = nil, repeatTiming: RepeatPattern? = nil, ringTimeIntervals: Set<TimeInterval>? = nil
    ) throws -> Reminder {
        if let eventTime = eventTime {
            if eventTime < addedTime {
                throw ReminderError.invalidEventTime
            }
        }
        return Reminder(addedTime: addedTime, title: title, description: description, eventTime: eventTime,
                        sound: sound, repeatTiming: repeatTiming, ringTimeIntervals: ringTimeIntervals)
    }
    /// Returns a `Reminder` created from user inputs
    ///
    /// - Returns: A `Reminder` object
    private func createReminder() -> Reminder {
        while true {
            do {
                let addedTime = Date.now
                let title = Input.getOptionalValue(name: "Title", for: "Reminder")
                let description = Input.getOptionalValue(name: "Description", for: "Reminder")
                let eventTime = Input.getEventTime(addedTime: addedTime)
                let sound = Input.getOptionalValue(name: "Sound", for:
                                                    "Reminder")
                let repeatTiming = Input.getRepeatPattern()
                let ringTimeIntervals = Input.getRingTimeIntervals(addedTime: addedTime, eventTime: eventTime)
                return try createReminderInstance(addedTime: addedTime, title: title, description: description, eventTime: eventTime, sound: sound, repeatTiming: repeatTiming, ringTimeIntervals: ringTimeIntervals)
            } catch ReminderError.invalidEventTime {
                Printer.printError("Invalid date entered(Date should be in 24hr format)")
            } catch let error {
                Printer.printError(error)
            }
        }
    }
    /// Creates a `Reminder`
    func add() {
        if ReminderDB.connect() {
            Printer.printToConsole("Successfully created reminder database")
        } else {
            Printer.printError("Failure in creating reminder database")
            return
        }
        var reminder = createReminder()
        let response = ReminderDB.create(element: reminder)
        if response.1 {
            Printer.printToConsole("Successfully created entry in reminder database with ID = \(response.0)")
            reminder.id = Int(response.0)
        } else {
            Printer.printError("Failure in creating database entry")
        }
        // add to notification
        do {
            try NotificationManager.push(reminder: reminder)
        } catch let error {
            Printer.printError(error)
        }
    }
    /// Retrieves a `Reminder` for the given id
    ///
    /// - Parameters:
    ///     - reminderID: The id of the `Reminder` from Database
    func get(reminderID: Int32) -> Reminder? {
        return ReminderDB.retrieve(id: reminderID)
    }
    /// Updates a `Reminder` for the given id
    ///
    /// - Parameters:
    ///     - reminderID: The id of the `Reminder` from Database
    ///     - reminder: The new `Reminder` instance
    func edit(reminderID: Int32, reminder: Reminder) {
        // delete notification of old reminder
        do {
            if let reminder = ReminderDB.retrieve(id: reminderID) {
                do {
                    try NotificationManager.pop(reminder: reminder)
                } catch NotificationManager.NotificationManagerError.notificationDoesNotExist {
                    if reminder.eventTime >= Date.now {
                        throw NotificationManager.NotificationManagerError.notificationDoesNotExist
                    }
                }
            }
        } catch let error {
            Printer.printError(error)
        }
        // update db
        if ReminderDB.update(id: reminderID, element: reminder) {
            Printer.printToConsole("Successfully updated to db")
            // create notification of new reminder
            do {
                try NotificationManager.push(reminder: reminder)
            } catch let error {
                Printer.printError("Error while updating reminder notification")
                Printer.printError(error)
            }
        } else {
            Printer.printError("Updating reminder db with id:\(reminderID) unsuccessful")
        }
    }
    /// Deletes a `Reminder` with respect to the id from the Database
    ///
    /// - Parameter remidnerID: The id of the Reminder from database
    func delete(reminderID: Int32) {
        // delete notification
        do {
            if let reminder = ReminderDB.retrieve(id: reminderID) {
                do {
                    try NotificationManager.pop(reminder: reminder)
                } catch NotificationManager.NotificationManagerError.notificationDoesNotExist {
                    if reminder.eventTime >= Date.now {
                        throw NotificationManager.NotificationManagerError.notificationDoesNotExist
                    }
                }
            }
        } catch let error {
            Printer.printError(error)
        }
        if ReminderDB.delete(id: reminderID) {
            Printer.printToConsole("Successfully deleted")
        } else {
            Printer.printError("Deleting Reminder from database unsuccessful")
        }
    }
    
    func changePreferences() {
    outerLoop:
        while true {
            Printer.printToConsole("Select: \n1. Set default title(\(ReminderDefaults.title)) \n2. Set default description(\(ReminderDefaults.description)) \n3. Set default repeatTimings(\(ReminderDefaults.repeatTiming)) \n4. Set default ringTimeIntervals(\(ReminderDefaults.ringTimeIntervals)) \n5. Set default snooze time(\(NotificationDefaults.snoozeTime)) \n6. Exit \n")
            let integerInput = Input.getInteger(range: 1...5)
            switch integerInput {
            case 1:
                let title = Input.getResponse(string: "default title")
                ReminderDefaults.setDefault(title: title)
            case 2:
                let description = Input.getResponse(string: "default description")
                ReminderDefaults.setDefault(description: description)
            case 3:
                Printer.printToConsole("Select default repeat pattern: ")
                let repeatTiming: RepeatPattern = Input.getRepeatPattern()
                ReminderDefaults.setDefault(repeatTiming: repeatTiming)
            case 4:
                let ringTimeIntervals = Input.getRingTimeIntervals(addedTime: Date.distantFuture)
                ReminderDefaults.setDefault(ringTimeIntervals: ringTimeIntervals)
            case 5:
                let response = Input.getBooleanResponse(string: "if change snooze time to 5 minutes")
                if response {
                    NotificationDefaults.snoozeTime = Constant.fiveMinutes
                }
            case 6:
                break outerLoop
            default:
                Printer.printError("Invalid input")
            }
        }
    }
}
