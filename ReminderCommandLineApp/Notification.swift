//
//  NotificationManager.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 29/12/21.
//

import Foundation

/// A wrapper for the `Date` type
/// To make it hashable upto minute-level granularity
struct DateWrapper: Codable {
    
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
/// Errors for the NotificationManager
enum NotificationManagerError: Error {
    /// Failure while pushing a notification
    case pushFailure
    /// Failure when a duplicate `Notification` is found
    case notificationAlreadyExists
    /// Failure when `Notification` is not found
    case notificationDoesNotExist
}
/// Localized description for `NotificationManagerError`
extension NotificationManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .pushFailure:
            return "Push Failure"
        case .notificationAlreadyExists:
            return "Notification Already Exists"
        case .notificationDoesNotExist:
            return "Notification Doesn't Exist"
        }
    }
}

extension String {
    /// String trimmed upto `limit`
    /// - Parameter limit: Index upto which the string should be trimmed, it should lie within `0 < limit < count`
    /// - Returns: A substring limited by the parameter
    func trimmed(upto limit: Int) -> Substring {
        if limit <= 0 || limit >= count {
            return self[...]
        }
        if count <= limit {
            return self[...]
        } else {
            return self[..<index(self.startIndex, offsetBy: limit)]
        }
    }
}

/// Handles the `Notification`s
class NotificationManager {
    /// Semaphore to indicate the background action
    static var backgroundActionStarted = false
    /// Dictionary to store the notifications
    private static var notifications: [DateWrapper: NotificationProtocol] = [:] {
        didSet {
            NotificationManager.sync()
        }
    }
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
            /// ! - throws even when removing notification while updating reminder
            throw NotificationManagerError.notificationDoesNotExist
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
    /// Perform notification action response from user
    /// - Parameters:
    ///  - notificationOption: The `NotificationOption` selected by user
    ///  - notification: The `Notification` instance to be added to notification
    static func notificationAction(notificationOption: NotificationOption, notification: NotificationProtocol) {
        if notificationOption == .snooze {
            let snoozedTime = Date.now + NotificationDefaults.snoozeTime
            notifications[snoozedTime.toDateWrapper()] = notification
        } else if notificationOption == .view {
            notification.view()
        }
    }
    
    /// Displays the reminder and returns `Bool` based on the result of the operation
    /// - Parameter notification: The notification to be displayed
    /// - Returns: A `Bool` value based on the result of the operation
    static func displayReminder(notification: NotificationProtocol) -> Bool {
        let result = Player.searchAndPlayAudio(fileName: notification.sound)
        
        let NOTIFICATION_BODY_MAX_LIMIT = 30
        Printer.printLine()
        Printer.printToConsole("Notification - \(notification.title)")
        Printer.printLine()
        Printer.printToConsole("Subtitle: \(notification.subtitle)")
        Printer.printToConsole("Body: \(notification.body.trimmed(upto: NOTIFICATION_BODY_MAX_LIMIT))")
        Printer.printToConsole("Time: \(notification.time.description(with: .current))")
        Printer.printLine()
        
        /// Commenting notification action because of input clash
//        let notificationOption: NotificationOption = Input.getOptionalEnumResponse(type: NotificationOption.self, name: "Options") ?? .markAsDone
        
        let notificationOption: NotificationOption = .markAsDone
        
        /// Notification Action
        notificationAction(notificationOption: notificationOption, notification: notification)
        
        Printer.printLine()
        
        remove(notification: notification)
        
        return result
    }
    
    /// Continously checks for notifications to notify every 1 second
    static func startBackgroundAction() {
        let PAUSE_TIME: UInt32 = 1
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
                sleep(PAUSE_TIME)
            }
        }
    }
    
    static func updateFromDB() {
        let databaseFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent(Constant.DB_FOLDER)
        
        do {
            try FileManager.default.createDirectory(at: databaseFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            Printer.printError("Failed to create directory while connecting to notifications database")
            Printer.printError(error)
            return
        }
        
        let url = databaseFolder.appendingPathComponent("notifications.json")
        if let data = try? Data(contentsOf: url) {
            Printer.printToConsole("Saved notifications file found")
            if let notifications = try? JSONDecoder().decode([DateWrapper: Notification].self, from: data) {
                self.notifications = notifications
                Printer.printToConsole("Saved notifications decoded")
            } else {
                Printer.printError("Cannot decode the notifications file from database")
                return
            }
        } else {
            do {
                if let notifications = notifications as? [DateWrapper: Notification] {
                    try JSONEncoder().encode(notifications).write(to: url)
                } else {
                    Printer.printError("Failed to downcast Notification while encoding notifications to file")
                    return
                }
            } catch let error {
                Printer.printError("Cannot encode notifications to a file")
                Printer.printError(error)
                return
            }
            Printer.printToConsole("New notifications file created")
        }
    }
    
    static func sync() {
        let databaseFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent(Constant.DB_FOLDER)
        do {
            try FileManager.default.createDirectory(at: databaseFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            Printer.printError("Failed to create directory while connecting to notifications database")
            Printer.printError(error)
            return
        }
        
        let url = databaseFolder.appendingPathComponent("notifications.json")
        do {
            if let notifications = notifications as? [DateWrapper: Notification] {
                try JSONEncoder().encode(notifications).write(to: url)
            } else {
                Printer.printError("Failed to downcast Notification while encoding notifications to file")
                return
            }
        } catch let error {
            Printer.printError("Cannot encode notifications to a file")
            Printer.printError(error)
            return
        }
    }
}

//extension NotificationManager {
//    /// Pushes the reminder to the dictionary `notifications`
//    /// - Parameter reminder: The `Reminder` to be pushed
//    /// - Throws:
//    ///  - notificationAlreadyExists: When a duplicate `Notification` is found
//    static func push(reminder: ReminderProtocol) throws {
//        for date in reminder.ringDates {
//            if let id = reminder.id {
//                let reminderNotification = ReminderNotification(subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: date, addedTime: reminder.addedTime, id: id)
//                try NotificationManager.push(notification: reminderNotification)
//            } else {
//                Printer.printError("Reminder id not found while pushing notification for reminder: \(reminder.title)")
//            }
//        }
//    }
//    /// Pops the reminder from the dictionary `notifications`
//    /// - Parameter reminder: The `Reminder` to be popped
//    /// - Throws:
//    ///  - notificationDoesNotExist: When the notification is not found
//    static func pop(reminder: ReminderProtocol) throws {
//        do {
//            for date in reminder.ringDates {
//                if let id = reminder.id {
//                    let reminderNotification = ReminderNotification(subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: date, addedTime: reminder.addedTime, id: id)
//                    try NotificationManager.pop(notification: reminderNotification)
//                }
//            }
//        } catch NotificationManagerError.notificationDoesNotExist {
//            Printer.printError("Notification wasn't added to the Notifications directory earlier")
//        }
//    }
//    /// Adds next notification for the repeat pattern in the `Reminder`
//    static private func addNextReminderNotification(unit: Calendar.Component, count: Int, notification: ReminderNotification) {
//        if let date = Calendar.current.date(byAdding: unit, value: count, to: notification.time) {
//            var newNotification = notification
//            newNotification.time = date
//            notifications[date.toDateWrapper()] = newNotification
//        } else {
//            Printer.printError("Unable to add \(unit) to current date for next repeated reminder notification")
//        }
//    }
//}



extension NotificationManager {
    /// Pushes the reminder to the dictionary `notifications`
    /// - Parameter reminder: The `Reminder` to be pushed
    /// - Throws:
    ///  - notificationAlreadyExists: When a duplicate `Notification` is found
    static func push(reminder: ReminderProtocol) throws {
        for date in reminder.ringDates {
            if let id = reminder.id {
                let reminderNotification = Notification(id: id, title: "Reminder", subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: date, addedTime: reminder.addedTime)
                try NotificationManager.push(notification: reminderNotification)
            } else {
                Printer.printError("Reminder id not found while pushing notification for reminder: \(reminder.title)")
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
                    let reminderNotification = Notification(id: id, title: "Reminder", subtitle: reminder.title, body: reminder.description, sound: reminder.sound, time: date, addedTime: reminder.addedTime)
                    try NotificationManager.pop(notification: reminderNotification)
                }
            }
        } catch NotificationManagerError.notificationDoesNotExist {
            Printer.printError("Notification wasn't added to the Notifications directory earlier")
        }
    }
    /// Adds next notification for the repeat pattern in the `Reminder`
    static private func addNextNotification(unit: Calendar.Component, count: Int, notification: NotificationProtocol) {
        if let date = Calendar.current.date(byAdding: unit, value: count, to: notification.time) {
            var newNotification = notification
            newNotification.time = date
            notifications[date.toDateWrapper()] = newNotification
        } else {
            Printer.printError("Unable to add \(unit) to current date for next repeated reminder notification")
        }
    }
}
//
//extension NotificationManager {
//    /// Pushes the reminder to the dictionary `notifications`
//    /// - Parameter task: The `Task` to be pushed
//    /// - Throws:
//    ///  - notificationAlreadyExists: When a duplicate `Notification` is found
//    static func push(task: TaskProtocol) throws {
//        let taskDeadlineString = "Deadline: \(task.deadline.description(with: .current))"
//        let taskNotification = TaskNotification(subtitle: taskDeadlineString, body: task.taskDescription, sound: task.sound, time: task.deadline, addedTime: task.addedTime, id: task.id)
//        try NotificationManager.push(notification: taskNotification)
//    }
//    /// Pops the reminder from the dictionary `notifications`
//    /// - Parameter task: The `Task` to be popped
//    /// - Throws:
//    ///  - notificationDoesNotExist: When the notification is not found
//    static func pop(task: TaskProtocol) throws {
//        let taskDeadlineString = "Deadline: \(task.deadline.description(with: .current))"
//        let taskNotification = TaskNotification(subtitle: taskDeadlineString, body: task.taskDescription, sound: task.sound, time: task.deadline, addedTime: task.addedTime, id: task.id)
//        try NotificationManager.pop(notification: taskNotification)
//    }
//}



extension NotificationManager {
    /// Pushes the reminder to the dictionary `notifications`
    /// - Parameter task: The `Task` to be pushed
    /// - Throws:
    ///  - notificationAlreadyExists: When a duplicate `Notification` is found
    static func push(task: TaskProtocol) throws {
        let taskDeadlineString = "Deadline: \(task.deadline.description(with: .current))"
        let taskNotification = Notification(id: task.id, title: "Task", subtitle: taskDeadlineString, body: task.taskDescription, sound: task.sound, time: task.deadline, addedTime: task.addedTime)
        try NotificationManager.push(notification: taskNotification)
    }
    /// Pops the reminder from the dictionary `notifications`
    /// - Parameter task: The `Task` to be popped
    /// - Throws:
    ///  - notificationDoesNotExist: When the notification is not found
    static func pop(task: TaskProtocol) throws {
        let taskDeadlineString = "Deadline: \(task.deadline.description(with: .current))"
        let taskNotification = Notification(id: task.id, title: "Task", subtitle: taskDeadlineString, body: task.taskDescription, sound: task.sound, time: task.deadline, addedTime: task.addedTime)
        try NotificationManager.pop(notification: taskNotification)
    }
}



//extension NotificationManager {
//
//    /// Fires the notification
//    /// - Parameter notification: The `Notification` instance to be notified
//    /// - Returns: A `Bool` determining the result of the operation
//    static private func notify(notification: NotificationProtocol) -> Bool {
//        var success = true
//        /// Checks if the notification is a `ReminderNotification`
//        if let notification = notification as? ReminderNotification {
//            if let id = notification.id {
//                /// Checks if the `Reminder` is still present in database
//                if let reminder = ReminderDB.retrieve(id: id) {
//                    /// Checks if the reminder is not modified (if its modified, new notification is added while modifying)
//                    if notification.addedTime == reminder.addedTime {
//                        /// Adds the next reminder
//
//                        switch reminder.repeatTiming {
//
//                        /// Temporary case for testing
//                        case .everyMinute:
//                            addNextReminderNotification(unit: .minute, count: 1, notification: notification)
//
//                        case .everyDay:
//                            addNextReminderNotification(unit: .day, count: 1, notification: notification)
//                        case .everyWeek:
//                            addNextReminderNotification(unit: .day, count: 7, notification: notification)
//                        case .everyMonth:
//                            addNextReminderNotification(unit: .month, count: 1, notification: notification)
//                        case .everyYear:
//                            addNextReminderNotification(unit: .year, count: 1, notification: notification)
//                        default:
//                            break
//                        }
//                    } else {
//                        /// Reminder has been updated, hence not displaying the out-dated notification
//                        remove(notification: notification)
//                        return success
//                    }
//                } else {
//                    /// Reminder instance not available in db
//                    remove(notification: notification)
//                    return success
//                }
//            } else {
//                Printer.printError("No id found in notification while notifying")
//            }
//        /// Checks if the notification is a `TaskNotification`
//        } else if let notification = notification as? TaskNotification {
//            if let id = notification.id {
//                if let task = TaskDB.retrieve(id: id) {
//                    /// Checks if the `Task` is modified
//                    if task.addedTime != notification.addedTime {
//                        /// `Task` has been updated, hence not displaying the out-dated notification
//                        remove(notification: notification)
//                    }
//                } else {
//                    /// Task instance not available in db
//                    remove(notification: notification)
//                    return success
//                }
//            } else {
//                Printer.printError("No id found in notification while notifying")
//            }
//        }
//
//        success = success && displayReminder(notification: notification)
//        return success
//    }
//}
//


extension NotificationManager {
    
    /// Fires the notification
    /// - Parameter notification: The `Notification` instance to be notified
    /// - Returns: A `Bool` determining the result of the operation
    static private func notify(notification: NotificationProtocol) -> Bool {
        var success = true
        /// Checks if the notification is a `ReminderNotification`
        if notification.title == "Reminder" {
            if let id = notification.id {
                /// Checks if the `Reminder` is still present in database
                if let reminder = ReminderDB.retrieve(id: id) {
                    /// Checks if the reminder is not modified (if its modified, new notification is added while modifying)
                    if notification.addedTime == reminder.addedTime {
                        /// Adds the next reminder

                        switch reminder.repeatTiming {
                        
                        /// Temporary case for testing
                        case .everyMinute:
                            addNextNotification(unit: .minute, count: 1, notification: notification)
                        
                        case .everyDay:
                            addNextNotification(unit: .day, count: 1, notification: notification)
                        case .everyWeek:
                            addNextNotification(unit: .day, count: 7, notification: notification)
                        case .everyMonth:
                            addNextNotification(unit: .month, count: 1, notification: notification)
                        case .everyYear:
                            addNextNotification(unit: .year, count: 1, notification: notification)
                        default:
                            break
                        }
                    } else {
                        /// Reminder has been updated, hence not displaying the out-dated notification
                        remove(notification: notification)
                        return success
                    }
                } else {
                    /// Reminder instance not available in db
                    remove(notification: notification)
                    return success
                }
            } else {
                Printer.printError("No id found in notification while notifying")
            }
        /// Checks if the notification is a `TaskNotification`
        } else if notification.title == "Task" {
            if let id = notification.id {
                if let task = TaskDB.retrieve(id: id) {
                    /// Checks if the `Task` is modified
                    if task.addedTime != notification.addedTime {
                        /// `Task` has been updated, hence not displaying the out-dated notification
                        remove(notification: notification)
                    }
                } else {
                    /// Task instance not available in db
                    remove(notification: notification)
                    return success
                }
            } else {
                Printer.printError("No id found in notification while notifying")
            }
        }
        
        success = success && displayReminder(notification: notification)
        return success
    }
}

enum NotificationOption: CaseIterable, Codable {
    case markAsDone
    case snooze
    case view
}

protocol NotificationProtocol: Identifiable, Codable {
    var title: String { get set }
    var subtitle: String { get set }
    var body: String { get set }
    var sound: String { get set }
    var time: Date { get set }
    var options: Set<NotificationOption> { get }
    var addedTime: Date { get }
}

extension NotificationProtocol {
    /// adding default implementation as the property can be implemented optionally
    var options: Set<NotificationOption> {
        get {
            return Set<NotificationOption>(NotificationOption.allCases)
        }
    }
}

extension NotificationProtocol {
    /// Displays the object linked with the Notification
    func view() {
        if let id = self.id {
            Reminder.viewReminder(id: id)
        }
    }
}
/*

class NotificationProtocol: Identifiable, Codable {
    
    var id: Int32?
    var title: String
    var subtitle: String
    var body: String
    var sound: String
    var time: Date
    var options: Set<NotificationOption>
    
    init(title: String, subtitle: String, body: String, sound: String, time: Date, options: Set<NotificationOption> = Set<NotificationOption>(NotificationOption.allCases), id: Int32? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.sound = sound
        self.time = time
        self.options = options
        self.id = id
    }
    
    /// Displays the object linked with the Notification
    func view() {}
}

class ReminderNotification: NotificationProtocol {
    
    var addedTime: Date
    
    override init(title: String = "Reminder", subtitle: String, body: String, sound: String, time: Date, options: Set<NotificationOption> = Set<NotificationOption>(NotificationOption.allCases), id: ReminderDB.ElementID? = nil) {
        super.init(title: title, subtitle: subtitle, body: body, sound: sound, time: time, options: options, id: id)
    }
    
    convenience init(subtitle: String, body: String, sound: String, time: Date, addedTime: Date, options: Set<NotificationOption> = Set<NotificationOption>(NotificationOption.allCases), id: Int32? = nil) {
        self.addedTime = addedTime
        self.init(subtitle: subtitle, body: body, sound: sound, time: time, options: options, id: id)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    /// Displays the object linked with the Notification
    override func view() {
        if let id = self.id {
            Reminder.viewReminder(id: id)
        }
    }
}

class TaskNotification: NotificationProtocol {
    
    var addedTime: Date
    
    init(title: String = "Task", subtitle: String, body: String, sound: String, time: Date, addedTime: Date, options: Set<NotificationOption> = Set<NotificationOption>(NotificationOption.allCases), id: Int32? = nil) {
        self.addedTime = addedTime
        super.init(title: title, subtitle: subtitle, body: body, sound: sound, time: time, options: options, id: id)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    /// Displays the object linked with the Notification
    override func view() {
        if let id = self.id {
            Task.viewTask(id: id)
        }
    }
}

*/

struct Notification: NotificationProtocol {
    var id: Int32?
    
    var title: String
    var subtitle: String
    var body: String
    var sound: String
    var time: Date
    var addedTime: Date
}

/*
struct ReminderNotification: NotificationProtocol {
    var title: String = "Reminder"
    var subtitle: String
    var body: String
    var sound: String
    var time: Date
    /// Reminder added time
    var addedTime: Date
    var id: ReminderDB.ElementID?
}

struct TaskNotification: NotificationProtocol {
    var title: String = "Task"
    var subtitle: String
    var body: String
    var sound: String
    var time: Date
    /// Task added time
    var addedTime: Date
    var id: TaskDB.ElementID?
}
*/
