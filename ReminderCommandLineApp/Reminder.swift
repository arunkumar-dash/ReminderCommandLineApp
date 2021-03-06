//
//  Reminder.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 09/12/21.
//

import Foundation


/// Type that returns a day of the week
enum WeekDay: CaseIterable, Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

/// Pattern to repeat the `Reminder`
enum RepeatPattern: CaseIterable, Codable {
    
    /// temporary case
    case everyMinute
    
    /// Repeats every day
    case everyDay
    /// Repeats every week
    case everyWeek
    /// Repeats every month
    case everyMonth
    /// Repeats every year
    case everyYear
    /// Repeats never
    case never
}

/// Types that conform to `ReminderProtocol` are Reminders
protocol ReminderProtocol: Identifiable {
    /// Title of the Reminder
    var title: String { get }
    /// Description of the Reminder
    var description: String { get }
    /// The date and time when Reminder was added
    var addedTime: Date { get }
    /// The date and time of the Event
    var eventTime: Date { get }
    /// The sound when Reminder rings
    var sound: String { get }
    /// The frequency to repeat the Reminder
    var repeatTiming: RepeatPattern { get }
    /// The set of `TimeInterval`s the reminder should ring before the `eventTime`
    var ringTimeIntervals: Set<TimeInterval> { get }
    /// The set of `Date`s the reminder should ring before the `eventTime`
    var ringDates: Set<Date> { get }
    // creating this property for notification syncing purpose
    var id: ReminderDB.ElementID? { get set }
    
//    let reminderView = ReminderView(self)
}
/// Returns a `Reminder` instance
struct Reminder: ReminderProtocol, Codable {
    
//    let reminderView = ReminderView(self)
    /// The title of the Reminder
    var title: String
    /// The description of the Reminder
    var description: String
    /// The time when Reminder was added
    var addedTime: Date
    /// The time when the Reminder should ring
    var eventTime: Date
    /// The sound of the Reminder
    var sound: String
    /// The `RepeatPattern` of the Reminder
    var repeatTiming: RepeatPattern
    /// The set of `TimeInterval`s before the `eventTime` when the Reminder should ring
    var ringTimeIntervals: Set<TimeInterval>
    /// The set of `Date`s the reminder should ring before the `eventTime`
    var ringDates: Set<Date> {
        get {
            var set = Set<Date>([eventTime])
            for timeInterval in ringTimeIntervals {
                let totalTimeInterval = eventTime.timeIntervalSince(addedTime)
                let timeIntervalSinceAddedTime = totalTimeInterval - timeInterval
                let ringTime = Date(timeInterval: timeIntervalSinceAddedTime, since: addedTime)
                set.insert(ringTime)
            }
            return set
        }
    }
    // creating this property for notification syncing purpose
    var id: ReminderDB.ElementID? = nil
    
    init(addedTime: Date, title: String? = nil, description: String? = nil, eventTime: Date? = nil,
         sound: String? = nil, repeatTiming: RepeatPattern? = nil, ringTimeIntervals: Set<TimeInterval>? = nil) {
        self.addedTime = addedTime
        self.title = ReminderDefaults.setValue(title: title)
        self.description = ReminderDefaults.setValue(description: description)
        self.eventTime = ReminderDefaults.setValue(eventTime: eventTime)
        self.sound = ReminderDefaults.setValue(sound: sound)
        self.repeatTiming = ReminderDefaults.setValue(repeatTiming: repeatTiming)
        self.ringTimeIntervals = ReminderDefaults.setValue(ringTimeIntervals: ringTimeIntervals)
    }
    /// Prints the reminder in the console.
    /// - Parameter id: The `id` of the `Reminder` from database
    static func viewReminder(id: ReminderDB.ElementID) {
        guard let reminder = ReminderDB.retrieve(id: id) else {
            Printer.printError("Failed to retrieve reminder from database. Received a nil value.")
            return
        }
        Printer.printLine()
        Printer.printToConsole("Reminder")
        Printer.printLine()
        Printer.printToConsole("Title: \(reminder.title)")
        Printer.printToConsole("Description: \(reminder.description)")
        Printer.printToConsole("Date: \(reminder.eventTime.description(with: .current))")
        Printer.printToConsole("Repeat Pattern: \(reminder.repeatTiming)")
        Player.searchAndPlayAudio(fileName: reminder.sound)
        Printer.printLine()
    }
}

protocol ReminderViewProtocol {
    func dayView()
    func monthView()
    func weekView()
}

struct ReminderView<ReminderCollection: Collection> where ReminderCollection.Element: ReminderProtocol{
    var reminders: ReminderCollection
    init(reminders: ReminderCollection) {
        self.reminders = reminders
    }
    func dayView() {
        
    }
    func weekView() {
        
    }
    func monthView() {
        
    }
}
