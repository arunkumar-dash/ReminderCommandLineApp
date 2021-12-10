//
//  Reminder.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 09/12/21.
//

import Foundation


/// Type that returns a day of the week
enum WeekDay {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

/// Pattern to repeat the `Reminder`
enum RepeatPattern {
    /// Repeats every week
    case everyWeek
    /// Repeats every month
    case everyMonth
    /// Repeats every year
    case everyYear
    /// Repeats never
    case never
    /// Repeats every `WeekDay` in the `Set`
    case custom(Set<WeekDay>)
}

/// Types that conform to `ReminderProtocol` are Reminders
protocol ReminderProtocol {
    /// Time interval in seconds
    typealias TimeInterval = Double
    /// Title of the Reminder
    var title: String { get }
    /// Description of the Reminder
    var description: String? { get }
    /// The date and time when Reminder was added
    var addedTime: Date { get }
    /// The date and time of the Event
    var eventTime: Date { get }
    /// The sound when Reminder rings
    var sound: String { get }
    /// The frequency to repeat the Reminder
    var repeatTiming: RepeatPattern { get }
    /// The list of TimeIntervals the reminder should ring before the `eventTime`
    var ringTimeList: Set<TimeInterval> { get }
    
//    let reminderView = ReminderView(self)
}

struct Reminder: ReminderProtocol {
    
//    let reminderView = ReminderView(self)
    var title: String
    var description: String?
    var addedTime: Date
    var eventTime: Date
    var sound: String
    var repeatTiming: RepeatPattern
    var ringTimeList: Set<TimeInterval>
    init(addedTime: Date, title: String? = nil, description: String? = nil, eventTime: Date? = nil,
         sound: String? = nil, repeatTiming: RepeatPattern? = nil, ringTimeList: Set<TimeInterval>? = nil) {
        self.addedTime = addedTime
        let defaults = ReminderDefaults(reminder: self)
        self.title = defaults.setValue(mainValue: title, defaultValue: defaults.title)
        self.description = defaults.setValue(mainValue: description, defaultValue: defaults.description)
        self.eventTime = defaults.setValue(mainValue: eventTime, defaultValue: defaults.eventTime)
        self.sound = defaults.setValue(mainValue: sound, defaultValue: defaults.sound)
        self.repeatTiming = defaults.setValue(mainValue: repeatTiming, defaultValue: defaults.repeatTiming)
        self.ringTimeList = defaults.setValue(mainValue: ringTimeList, defaultValue: defaults.ringTimeList)
    }
    func view() {
        print("view reminder")
    }
    func edit() {
        print("edit reminder")
    }
}

protocol ReminderViewProtocol {
    func dayView()
    func monthView()
    func weekView()
}

struct ReminderView<ReminderCollection: Collection> where ReminderCollection.Element: ReminderProtocol{
    let sortedReminders: [ReminderCollection.Element]
    init(reminders: ReminderCollection) {
        sortedReminders = reminders.sorted(by: { $0.eventTime < $1.eventTime })
    }
    func dayView() {
        for reminder in sortedReminders {
            Printer.printToConsole(reminder.title)
            Printer.printToConsole(reminder.description ?? "-")
        }
    }
}
