//
//  NotificationManager.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 29/12/21.
//

import Foundation

/// A wrapper for the `Date` type
/// To make it hashable upto minute-level granularity
struct DateWrapper {
    
    var date: Date
    
    init(_ date: Date) {
        self.date = date
    }
}

extension DateWrapper: Hashable {
    static func == (lhs: DateWrapper, rhs: DateWrapper) -> Bool {
        return Calendar(identifier: .gregorian).compare(lhs.date, to: rhs.date, toGranularity: .minute) == .orderedSame
    }
}

extension Date {
    /// Returns a wrapper for the `Date`
    func toDateWrapper() -> DateWrapper {
        return DateWrapper(self)
    }
}
/// Handles the `Notification`s
class NotificationManager {
    /// Semaphore to indicate the background action
    static var backgroundActionStarted = false
    /// Errors for the NotificationManager
    enum NotificationManagerError: Error {
        /// Failure while pushing a notification
        case pushFailure
        /// Failure when a duplicate `Notification` is found
        case notificationAlreadyExists
        /// Failure when `Notification` is not found
        case notificationDoesNotExist
    }
    /// Dictionary to store the notifications
    private static var notifications: [DateWrapper: NotificationProtocol] = [:]
    /// Pushes the notification to the dictionary `notifications`
    /// - Parameter notification: The `Notification` to be pushed
    /// - Throws:
    ///  - notificationAlreadyExists: When a duplicate `Notification` is found
    static func push(notification: NotificationProtocol) throws {
        if notifications[notification.time.toDateWrapper()] != nil {
            throw NotificationManagerError.notificationAlreadyExists
        } else if notification.time > Date.now {
            notifications[notification.time.toDateWrapper()] = notification
        }
    }
    /// Pops the notification from the dictionary `notifications`
    /// - Parameter notification: The `Notification` to be popped
    /// - Throws:
    ///  - notificationDoesNotExist: When the notification is not found
    static func pop(notification: NotificationProtocol) throws {
        if let _ = notifications[notification.time.toDateWrapper()] {
            notifications[notification.time.toDateWrapper()] = nil
        } else {
            throw NotificationManagerError.notificationDoesNotExist
        }
    }
    /// Pushes the reminder to the dictionary `notifications`
    /// - Parameter reminder: The `Reminder` to be pushed
    /// - Throws:
    ///  - notificationAlreadyExists: When a duplicate `Notification` is found
    static func push(reminder: ReminderProtocol) throws {
        for date in reminder.ringDates {
            if let id = reminder.id {
                let reminderNotification = ReminderNotification(subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: date, id: id)
                try NotificationManager.push(notification: reminderNotification)
            }
        }
    }
    /// Pops the reminder from the dictionary `notifications`
    /// - Parameter reminder: The `Reminder` to be popped
    /// - Throws:
    ///  - notificationDoesNotExist: When the notification is not found
    static func pop(reminder: ReminderProtocol) throws {
        do {
            for date in reminder.ringDates {
                if let id = reminder.id {
                    let reminderNotification = ReminderNotification(subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: date, id: id)
                    try NotificationManager.pop(notification: reminderNotification)
                }
            }
        } catch NotificationManagerError.notificationDoesNotExist {
            Printer.printError("Notification wasn't added to the Notifications directory earlier")
        }
    }
    /// Adds next notification for the repeat pattern in the `Reminder`
    static private func addNextReminderNotification(unit: Calendar.Component, count: Int, notification: ReminderNotification) {
        if let date = Calendar.current.date(byAdding: unit, value: count, to: Date.now) {
            notifications[date.toDateWrapper()] = notification
        } else {
            Printer.printError("Unable to add \(unit) to current date for next repeated reminder notification")
        }
    }
    /// Removes the `Notification` and silences the error
    /// - Parameter notification: The notification instance to be removed
    static private func remove(notification: NotificationProtocol) {
        do {
            try NotificationManager.pop(notification: notification)
        } catch let error {
            Printer.printError("Error in deleting notification after notifying")
            Printer.printError(error)
        }
    }
    /// Fires the notification
    /// - Parameter notification: The `Notification` instance to be notified
    /// - Returns: A `Bool` determining the result of the operation
    static private func notify(notification: NotificationProtocol) -> Bool {
        var success = true
        /// Checks if the `Reminder` is still present in database
        if let notification = notification as? ReminderNotification {
            /// Adds the next reminder
            if let reminder = ReminderDB.retrieve(id: Int32(notification.id)) {
                switch reminder.repeatTiming {
                case .everyDay:
                    addNextReminderNotification(unit: .day, count: 1, notification: notification)
                case .everyWeek:
                    addNextReminderNotification(unit: .day, count: 7, notification: notification)
                case .everyMonth:
                    addNextReminderNotification(unit: .month, count: 1, notification: notification)
                case .everyYear:
                    addNextReminderNotification(unit: .year, count: 1, notification: notification)
                default:
                    break
                }
            } else {
                /// Reminder instance not available in db
                remove(notification: notification)
                return success
            }
        }
        /// Plays the notification sound
        success = success && Player.searchAndPlayAudio(fileName: notification.sound)
        Printer.printLine()
        Printer.printLine()
        Printer.printToConsole(notification.title)
        Printer.printLine()
        Printer.printToConsole(notification.subtitle)
        Printer.printLine()
        Printer.printToConsole(notification.body)
        
        Printer.printLine()
        Printer.printToConsole("Select options:")
        let notificationOption: NotificationOption = Input.getEnumResponse(type: NotificationOption.self)
        if notificationOption == .snooze {
            let snoozedTime = Date.now + NotificationDefaults.snoozeTime
            notifications[snoozedTime.toDateWrapper()] = notification
        }
        Printer.printLine()
        
        Printer.printLine()
        remove(notification: notification)
        return success
    }
    /// Continously checks for notifications to notify every 58 seconds
    static func startBackgroundAction() {
        if backgroundActionStarted {
            return
        }
        backgroundActionStarted = true
        
        DispatchQueue.global().async {
            while true {
                if let notification = notifications[Date.now.toDateWrapper()] {
                    if NotificationManager.notify(notification: notification) == false {
                        Printer.printError("Failed to notify! \ntitle: \(notification.title) \nsubtitle: \(notification.subtitle)")
                    }
                }
                sleep(58)
            }
        }
    }
}

enum NotificationOption: CaseIterable {
    case markAsDone
    case snooze
}

protocol NotificationProtocol {
    var title: String { get set }
    var subtitle: String { get set }
    var body: String { get set }
    var sound: String { get set }
    var time: Date { get set }
    var options: Set<NotificationOption> { get set }
}

extension NotificationProtocol {
    /// adding default implementation as the property can be implemented optionally
    var options: Set<NotificationOption> {
        get {
            return Set<NotificationOption>([.markAsDone, .snooze])
        }
        set {}
    }
}

struct ReminderNotification: NotificationProtocol {
    var title: String = "Reminder"
    var subtitle: String
    var body: String
    var sound: String
    var time: Date
    var id: Int
}
