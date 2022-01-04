//
//  Defaults.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 10/12/21.
//

import Foundation

/// Conforming to this protocol will convert
protocol Defaults {
    
}

extension Defaults {
    /// Returns the `defaultValue` if the `mainValue` is `nil`, else returns `mainValue`
    ///
    /// - Parameters:
    ///     - mainvalue: The mainValue which is considered if it is not nil
    ///     - defaultValue: The value which should be considered if the `mainValue` is nil
    static func setValue<Element>(mainValue: Element?, defaultValue: Element) -> Element {
        if let mainValue = mainValue {
            return mainValue
        }
        else {
            return defaultValue
        }
    }
}

/// Returns the default values of the `Reminder` parameters
class ReminderDefaults: Defaults {
    
    static var currentDate: Date = Date.now
    
    /// Default title for Reminder
    static var title: String = "Reminder-\(Date.now.description(with: Locale.current))"
    
    /// Default description for Reminder
    static var description: String = "Your description goes here..."
    
    /// Default time when the Reminder rings
    /// Default time set here is one hour(3600 seconds) after the time when Reminder was added
    static var eventTime: Date {
        Self.currentDate + Double(3600)
    }
    
    /// Default ringing sound of the Reminder
    static var sound = "/Users/arun-pt4306/Downloads/sound.wav"
    
    /// Pattern when the Reminder repeats
    /// Default pattern is no repetitions
    static var repeatTiming: RepeatPattern = .never
    
    /// Set of `TimeInterval`s when the Reminder should ring before the `eventTime`
    /// By default the reminder rings 30 minutes before the `eventTime`
    static var ringTimeList = Set([Double(1800)])
//    let reminderView = ReminderView(self)
    
    static func setDefault(title: String) {
        Self.title = title
    }
    
    static func setDefault(description: String) {
        Self.description = description
    }
    
    static func setDefault(repeatTiming: RepeatPattern) {
        Self.repeatTiming = repeatTiming
    }
    
    static func setDefault(ringTimeList: Set<TimeInterval>) {
        Self.ringTimeList = ringTimeList
    }
    
}

class NotesDefaults: Defaults {
    
    static var currentDate: Date = Date.now
    
    static var title: String = "Note-\(Date.now.description(with: Locale.current))"
    
    static var description: String = "Your description goes here..."
    
    static func setDefault(title: String) {
        Self.title = title
    }
    
    static func setDefault(description: String) {
        Self.description = description
    }
    
    static func setValue(title: String?) -> String {
        if let title = title {
            return title
        } else {
            return Self.title
        }
    }
    
    static func setValue(description: String?) -> String {
        if let description = description {
            return description
        } else {
            return Self.description
        }
    }
    
    static func setValue(addedTime: Date?) -> Date {
        if let addedTime = addedTime {
            return addedTime
        } else {
            return Self.currentDate
        }
    }
}

class NotificationDefaults: Defaults {
    // snooze 10 minutes
    static var snoozeTime: TimeInterval = Double(600)
    
    static func setDefault(snoozeTime: TimeInterval) {
        Self.snoozeTime = snoozeTime
    }
}
