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
    func setValue<Element>(mainValue: Element?, defaultValue: Element) -> Element {
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
    /// The default title of the Reminder
    var title: String
    /// The default description of the Reminder
    var description: String
    /// The default time when the Reminder should ring
    var eventTime: Date
    /// The default sound of the Reminder
    var sound: String
    /// The default `RepeatPattern` of the Reminder
    var repeatTiming: RepeatPattern
    /// The default ringTimeList of the Reminder, which is, an empty list
    var ringTimeList: Set<TimeInterval>
//    let reminderView = ReminderView(self)
    
    init(addedTime: Date) {
        /// Default title for Reminder
        title = "Reminder-\(addedTime.description(with: Locale.current))"
        
        /// Default description for Reminder
        description = "Your description goes here..."
        
        /// Default time when the Reminder rings
        /// Default time set here is one hour(3600 seconds) after the time when Reminder was added
        eventTime = addedTime + 3600

        /// Default ringing sound of the Reminder
        sound = "sound.wav"
        
        /// Pattern when the Reminder repeats
        /// Default pattern is no repetitions
        repeatTiming = .never
        
        /// Set of `TimeInterval`s when the Reminder should ring before the `eventTime`
        /// By default the reminder rings 30 minutes before the `eventTime`
        ringTimeList = Set([1800])
    }
    
}
