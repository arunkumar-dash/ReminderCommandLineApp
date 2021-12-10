//
//  Defaults.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 10/12/21.
//

import Foundation

protocol Defaults {
}

extension Defaults {
    func setValue<Element>(mainValue: Element?, defaultValue: Element) -> Element {
        if mainValue == nil {
            return defaultValue
        }
        else {
            return mainValue!
        }
    }
}

class ReminderDefaults: Defaults {
    var title: String
    var description: String?
    var eventTime: Date
    var sound: String
    var repeatTiming: RepeatPattern
    var ringTimeList: Set<TimeInterval>
//    let reminderView = ReminderView(self)
    init(reminder: ReminderProtocol) {
        /// Default title for Reminder
        title = "Reminder-\(reminder.addedTime.description(with: Locale.current))"
        
        /// Default description for Reminnder
        description = "Your description goes here..."
        
        /// Default time when the Reminder rings
        /// Default time set here is one hour(3600 seconds) after the time when Reminder was added
        eventTime = reminder.addedTime + 3600
        
        /// Default ringing sound of the Reminder
        sound = "Beethoven - Symphony No. 5"
        
        /// Pattern when the Reminder repeats
        /// Default pattern is no repetitions
        repeatTiming = .never
        
        /// Set of `TimeInterval`s when the Reminder should ring before the `eventTime`
        /// By default the reminder rings 30 minutes before the `eventTime`
        ringTimeList = Set([1800])
    }
    
}
