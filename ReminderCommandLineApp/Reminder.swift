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
    var description: String { get }
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
    var description: String
    var addedTime: Date
    var eventTime: Date
    var sound: String
    var repeatTiming: RepeatPattern
    var ringTimeList: Set<TimeInterval>
    init(addedTime: Date, title: String? = nil, description: String? = nil, eventTime: Date? = nil,
         sound: String? = nil, repeatTiming: RepeatPattern? = nil, ringTimeList: Set<TimeInterval>? = nil) {
        self.addedTime = addedTime
        let defaults = ReminderDefaults(addedTime: addedTime)
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

extension Date {
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

struct ReminderView<ReminderCollection: Collection> where ReminderCollection.Element: ReminderProtocol{
    let sortedReminders: [(ReminderCollection.Element, Date)]
    let currentDate = Date.now
    let currentDateReminderIndex: Int
    init(reminders: ReminderCollection) {
        sortedReminders = reminders.sorted(by: { $0.eventTime < $1.eventTime }).map{ ($0, $0.eventTime) }
        /// Perform binary search to find the nearest index of the current date
        func searchDateInSortedReminders(_ sortedReminders: [(ReminderCollection.Element, Date)], currentDate: Date = Date.now) -> Int {
            var left = 0
            var right = sortedReminders.count - 1
            
            while left <= right {
                let middle = left + (right - left) / 2
                if sortedReminders[middle].1 < currentDate {
                    left = middle + 1
                } else if sortedReminders[middle].1 > currentDate {
                    right = middle - 1
                } else {
                    return middle
                }
            }
            return right
        }
        self.currentDateReminderIndex = searchDateInSortedReminders(sortedReminders)
    }
    func dayView() {
        Printer.printLine()
        let index = currentDateReminderIndex
        let reminder = sortedReminders[index].0
        Printer.printToConsole(reminder.title)
        Printer.printToConsole(reminder.description)
        Printer.printToConsole(reminder.eventTime)
        Printer.printToConsole(reminder.sound)
        Printer.printLine()
        // Code to traverse between previous and next days
    }
    func weekView() {
        let index = currentDateReminderIndex
        var left = index
        var right = index
        let start = 0
        let end = sortedReminders.count - 1
        while (left >= start) && sortedReminders[left].1.get(.month) == sortedReminders[index].1.get(.month) {
            left -= 1
        }
        while (right <= end) && sortedReminders[right].1.get(.month) == sortedReminders[index].1.get(.month) {
            right += 1
        }
        for reminderTuple in sortedReminders[left...right] {
            let reminder = reminderTuple.0
            Printer.printLine()
            Printer.printToConsole(reminder.title)
            Printer.printToConsole(reminder.description)
            Printer.printToConsole(reminder.eventTime)
            Printer.printLine()
        }
    }
    func monthView() {
        
    }
}
