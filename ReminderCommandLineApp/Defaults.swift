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
    ///  - mainvalue: The mainValue which is considered if it is not nil
    ///  - defaultValue: The value which should be considered if the `mainValue` is nil
    static func setValue<Element>(mainValue: Element?, defaultValue: Element) -> Element {
        return mainValue ?? defaultValue
    }
}



/// Returns the default values of the `Reminder` parameters
class ReminderDefaults: Defaults {
    private init() {}
    
    private static var _title: String = "Reminder"
    
    /// Default title for Reminder
    static var title: String {
        get {
            "\(_title)-\(Date.now.description(with: Locale.current))"
        }
        set {
            _title = newValue
        }
    }
    
    /// Default description for Reminder
    static var description: String = "Your description goes here..."
    
    /// Default time when the Reminder rings
    /// Default time set here is one hour(3600 seconds) after the time when Reminder was added
    static var eventTime: Date {
        Date.now + Constant.oneHour
    }
    
    /// Default ringing sound of the Reminder
    static var sound = Constant.REMINDER_SOUND_PATH
    
    /// Pattern when the Reminder repeats
    /// Default pattern is no repetitions
    static var repeatTiming: RepeatPattern = .never
    
    /// Set of `TimeInterval`s when the Reminder should ring before the `eventTime`
    /// By default the reminder rings 30 minutes before the `eventTime`
    static var ringTimeIntervals = Set([Constant.halfHour])
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
    
    static func setDefault(ringTimeIntervals: Set<TimeInterval>) {
        Self.ringTimeIntervals = ringTimeIntervals
    }
    
    static func setValue(title: String?) -> String {
        return title ?? Self.title
    }
    
    static func setValue(description: String?) -> String {
        return description ?? Self.description
    }
    
    static func setValue(eventTime: Date?) -> Date {
        return eventTime ?? Self.eventTime
    }
    
    static func setValue(sound: String?) -> String {
        return sound ?? Self.sound
    }
    
    static func setValue(repeatTiming: RepeatPattern?) -> RepeatPattern {
        return repeatTiming ?? Self.repeatTiming
    }
    
    static func setValue(ringTimeIntervals: Set<TimeInterval>?) -> Set<TimeInterval> {
        return ringTimeIntervals ?? Self.ringTimeIntervals
    }
}

/// Stores the default values of `Notes`
class NotesDefaults: Defaults {
    
    private init() {}
    
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

/// Stores default values of `Notification`
class NotificationDefaults: Defaults {
    
    private init() {}
    // snooze 10 minutes
    static var snoozeTime: TimeInterval = Constant.tenMinutes
    
    static func setDefault(snoozeTime: TimeInterval) {
        Self.snoozeTime = snoozeTime
    }
}


class TaskDefaults: Defaults {
    
    private init() {}
    
    static private var _deadline: Date? = nil
    
    static var sound: String = Constant.TASK_SOUND_PATH
    
    static var deadline: Date {
        get {
            if let _deadline = _deadline {
                return _deadline
            } else {
                return Date.distantFuture
            }
        }
        set {
            _deadline = newValue
        }
    }
    
    static func setDefault(deadline: Date) {
        self.deadline = deadline
    }
    
    static func setDefault(sound: String) {
        self.sound = sound
    }
    
    static func setValue(deadline: Date?) -> Date {
        if let deadline = deadline {
            return deadline
        } else {
            return self.deadline
        }
    }
    
    static func setValue(sound: String?) -> String {
        if let sound = sound {
            return sound
        } else {
            return self.sound
        }
    }
}
