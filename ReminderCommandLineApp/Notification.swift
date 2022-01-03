//
//  NotificationManager.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 29/12/21.
//

import Foundation

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
    
    func toDateWrapper() -> DateWrapper {
        return DateWrapper(self)
    }
}

class NotificationManager {
    
    enum NotificationManagerError: Error {
        case pushFailure
        case notificationAlreadyExists
        case notificationDoesNotExist
    }
    
    private static var notifications: [DateWrapper: NotificationProtocol] = [:]
    
    static func push(notification: NotificationProtocol) throws {
        if notifications[notification.time.toDateWrapper()] != nil {
            throw NotificationManagerError.notificationAlreadyExists
        }
        notifications[notification.time.toDateWrapper()] = notification
    }
    
    static func pop(notification: NotificationProtocol) throws {
        if let _ = notifications[notification.time.toDateWrapper()] {
            notifications[notification.time.toDateWrapper()] = nil
        } else {
            throw NotificationManagerError.notificationDoesNotExist
        }
    }
    
    static func push(reminder: ReminderProtocol) throws {
        for date in reminder.ringDates {
            let reminderNotification = ReminderNotification(subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: date)
            try NotificationManager.push(notification: reminderNotification)
        }
        let reminderNotification = ReminderNotification(subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: reminder.eventTime)
        try NotificationManager.push(notification: reminderNotification)
    }
    
    static func pop(reminder: ReminderProtocol) throws {
        for date in reminder.ringDates {
            let reminderNotification = ReminderNotification(subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: date)
            try NotificationManager.pop(notification: reminderNotification)
        }
        let reminderNotification = ReminderNotification(subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: reminder.eventTime)
        do {
            try NotificationManager.pop(notification: reminderNotification)
        } catch NotificationManagerError.notificationDoesNotExist {
            Printer.printError("Notification wasn't added to the Notifications directory earlier")
        }
    }
    
    static private func notify(notification: NotificationProtocol) -> Bool {
        
        var success = true
        success = success && Player.searchAndPlay(fileName: notification.sound)
        Printer.printLine()
        Printer.printLine()
        Printer.printToConsole(notification.title)
        Printer.printLine()
        Printer.printToConsole(notification.subtitle)
        Printer.printLine()
        Printer.printToConsole(notification.body)
        Printer.printLine()
        Printer.printLine()
        do {
            try NotificationManager.pop(notification: notification)
        } catch let error {
            Printer.printError("Error in deleting notification after notifying")
            Printer.printError(error)
        }
        return success
    }
    
    static func startBackgroundAction() {
        
        DispatchQueue.global().async {
            while true {
                if let notification = notifications[Date.now.toDateWrapper()] {
                    if NotificationManager.notify(notification: notification) == false {
                        Printer.printError("Failed to notify! \ntitle: \(notification.title) \nsubtitle: \(notification.subtitle)")
                    }
                }
                sleep(1)
            }
        }
    }
}

protocol NotificationProtocol {
    var title: String { get set }
    var subtitle: String { get set }
    var body: String { get set }
    var sound: String { get set }
    var time: Date { get set }
}

struct ReminderNotification: NotificationProtocol {
    var title: String = "Reminder"
    var subtitle: String
    var body: String
    var sound: String
    var time: Date
}
