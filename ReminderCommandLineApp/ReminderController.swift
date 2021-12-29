//
//  ReminderController.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 13/12/21.
//

import Foundation

/// Controller for handling operations of a Reminder
struct ReminderController {
    /// Property to handle database operations with Reminder
    let reminderDB: ReminderDB
    init() {
        reminderDB = ReminderDB()
    }
    /// Returns a Reminder instance
    ///
    /// - Parameters:
    ///     - title: The title of the `Reminder`
    ///     - description: The description of the `Reminder`
    ///     - eventTime: The time when the `Reminder` should ring
    ///     - sound: The sound which the `Reminder` should ring
    ///     - repeatTiming: The repetitions of the `Reminder`
    ///     - ringTimeList: The `Set` of `TimeInterval`s when the `Reminder` should ring before the `eventTime`
    /// - Returns: A `Reminder` object
    private func createReminderInstance(addedTime: Date, title: String? = nil, description: String? = nil, eventTime: Date?,
                                sound: String? = nil, repeatTiming: RepeatPattern? = nil, ringTimeList: Set<TimeInterval>? = nil) -> Reminder {
        return Reminder(addedTime: addedTime, title: title, description: description, eventTime: eventTime,
                        sound: sound, repeatTiming: repeatTiming, ringTimeList: ringTimeList)
    }
    /// Returns an optional string by getting availability of input from user
    ///
    ///     getOptionalValue(name: "title")
    ///     // gets the title? from the user
    ///
    /// - Parameter name: The name of the value to be obtained from user
    /// - Returns: An optional string based on the availability of the value
    private func getOptionalValue(name: String) -> String? {
        guard Input.getBooleanResponse(string: "Is \(name) available?") else {
            return nil
        }
        let value = Input.getResponse(string: "reminder \(name)")
        return value
    }
    /// Returns an `Integer` obtained from the User, within a certain range
    ///
    /// - Parameters:
    ///     - range: The `Range` within which the `Integer` should lie within
    ///     - name: The name of the value which we are obtaining
    /// - Returns: The `Integer` obtained from the User
    private func getInteger<AnyRange: RangeExpression>(range: AnyRange, name string: String? = nil) -> Int where AnyRange.Bound == Int {
        while true {
            var response: String = ""
            if let inputString = string {
                response = Input.getResponse(string: inputString)
            } else {
                response = Input.getResponse()
            }
            if let integer = Int(response), range.contains(integer) {
                return integer
            } else if let _ = Int(response) {
                Printer.printToConsole("Input is not in range")
            } else {
                Printer.printToConsole("Input cannot be interpreted as Int")
            }
        }
    }
    /// Returns a `Date` using the parameters
    ///
    /// - Parameters:
    ///     - day: The date component of a `Date`
    ///     - month: The month component of a `Date`
    ///     - year: The year component of a `Date`
    ///     - hour: The hour component of a `Date`
    ///     - minute: The minute component of a `Date`
    ///     - second: The second component of a `Date`
    /// - Returns: The `Date` instance created from using the arguments
    private func createDate(day: Int, month: Int, year: Int, hour: Int, minute: Int, second: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = TimeZone(abbreviation: "IST")
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        /// Creating calendar to create date
        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)
    }
    /// Returns a `Date` object created from user inputs
    ///
    /// - Parameter name: a `String` to print while getting user input
    /// - Returns: A `Date` object created from user inputs
    private func getOptionalDate(name: String?) -> Date? {
        guard Input.getBooleanResponse(string: "Date") else {
            return nil
        }
        let year = getInteger(range: 1970...2199, name: "year")
        let month = getInteger(range: 1...12, name: "month")
        /// An `Array` containing of months which have 31 days
        let monthsWith31Days = [1, 3, 5, 7, 8, 10, 12]
        /// An `Array` containing of months which have 30 days
        let monthsWith30Days = [4, 6, 9, 11]
        var day = 0
        if monthsWith31Days.contains(month) {
            day = getInteger(range: 1...31, name: "day")
        } else if monthsWith30Days.contains(month) {
            day = getInteger(range: 1...30, name: "day")
        } else if (year % 400 == 0) || ((year % 4 == 0) && (year % 100 != 0)) {
            day = getInteger(range: 1...29, name: "day")
        } else {
            day = getInteger(range: 1...28, name: "day")
        }
        let hour = getInteger(range: 0...23, name: "hour")
        let minute = getInteger(range: 0...59, name: "minute")
        let second = getInteger(range: 0...59, name: "second")
        let date = createDate(day: day, month: month, year: year, hour: hour, minute: minute, second: second)!
        return date
    }
    /// Returns a `RepeatPattern` object created from user inputs
    ///
    /// - Returns: A `RepeatPattern` object created from user inputs
    private func getRepeatPattern() -> RepeatPattern? {
        Printer.printToConsole("Enter Repeat pattern:")
        Printer.printToConsole("[1]\(RepeatPattern.never)")
        Printer.printToConsole("[2]\(RepeatPattern.everyWeek)")
        Printer.printToConsole("[3]\(RepeatPattern.everyMonth)")
        Printer.printToConsole("[4]\(RepeatPattern.everyYear)")
        Printer.printToConsole("[5] Custom")
        switch (getInteger(range: 1...5)) {
        case 1:
            return RepeatPattern.never
        case 2:
            return RepeatPattern.everyWeek
        case 3:
            return RepeatPattern.everyMonth
        case 4:
            return RepeatPattern.everyYear
        case 5:
            var weekDaySet: Set<WeekDay> = []
            repeat {
                let day = Input.getEnumResponse(type: WeekDay.self)
                weekDaySet.insert(day)
            } while Input.getBooleanResponse(string: "Do you want to enter another Week Day?")
            return RepeatPattern.custom(weekDaySet)
        default:
            Printer.printToConsole("Invalid case")
        }
        return nil
    }
    /// Returns a `Bool` indicating whether the `ringTime` passed in argument lies between `addedTime` and `eventTime`
    ///
    /// - Parameters:
    ///     - ringTime: Number of seconds before the `evenTime` for which the `Reminder` should alert
    ///     - addedTime: The `Date` when the `Reminder` was added
    ///     - eventTime: The `Date` when  the `Reminder` is supposed to ring
    /// - Returns: A `Bool` indicating whether the `ringTime` is between `addedTime` and `eventTime`
    private func isValidRingTime(ringTime: TimeInterval, addedTime: Date, eventTime: Date?) -> Bool {
        let eventTime = eventTime ?? (addedTime + 3600)
        let totalDateInterval = DateInterval(start: addedTime, end: eventTime)
        let totalTimeInterval = eventTime.timeIntervalSince(addedTime)
        return totalDateInterval.contains(Date(timeInterval: totalTimeInterval - ringTime, since: addedTime))
    }
    /// Returns a `Set` consisting of `TimeInterval`s  obtained from user
    ///
    /// - Parameters:
    ///     - addedTime: The `Date` when the `Reminder` was added
    ///     - eventTime: The `Date` when the `Reminder` should ring
    /// - Returns: A `Set`  of `TimeInterval`s when the `Reminder` should ring before the `eventTime`
    private func getRingTimeList(addedTime: Date, eventTime: Date?) -> Set<TimeInterval> {
        var ringTimeList: Set<TimeInterval> = []
        repeat {
            let ringTime = TimeInterval(getInteger(range: 1...,
                                      name: "number of minutes before which the reminder should give alert") * 60)
            if isValidRingTime(ringTime: ringTime, addedTime: addedTime, eventTime: eventTime) {
                ringTimeList.insert(Double(ringTime))
            } else {
                Printer.printToConsole("Invalid input(Input doesn't lie within the range Time.now < input < eventTime")
            }
        } while Input.getBooleanResponse(string: "Do you want to enter another input? ")
        return ringTimeList
    }
    /// Returns a `Reminder` created from user inputs
    ///
    /// - Returns: A `Reminder` object
    private func createReminder() -> Reminder {
        let addedTime = Date.now
        let title = getOptionalValue(name: "Title")
        let description = getOptionalValue(name: "Description")
        let eventTime = getOptionalDate(name: "Event Time")
        let sound = getOptionalValue(name: "Sound")
        let repeatTiming = getRepeatPattern()
        let ringTimeList = getRingTimeList(addedTime: addedTime, eventTime: eventTime)
        return createReminderInstance(addedTime: addedTime, title: title, description: description, eventTime: eventTime,
                              sound: sound, repeatTiming: repeatTiming, ringTimeList: ringTimeList)
    }
    /// Creates a `Reminder`
    func add() {
        let reminder = createReminder()
        let response = reminderDB.create(element: reminder)
        if response.1 {
            Printer.printToConsole("Successfully created reminder database with ID = \(response.0)")
        } else {
            Printer.printToConsole("Failure in creating database")
        }
    }
    /// Retrieves a `Reminder` for the given id
    ///
    /// - Parameters:
    ///     - reminderID: The id of the `Reminder` from Database
    func get(reminderID: Int) -> Reminder? {
        return reminderDB.retrieve(id: reminderID)
    }
    /// Updates a `Reminder` for the given id
    ///
    /// - Parameters:
    ///     - reminderID: The id of the `Reminder` from Database
    ///     - reminder: The new `Reminder` instance
    func edit(reminderID: Int, reminder: Reminder) {
        if reminderDB.update(id: reminderID, element: reminder) {
            Printer.printToConsole("Successfully updated")
        } else {
            Printer.printToConsole("Error in updating reminder with id:\(reminderID)")
        }
    }
    /// Deletes a `Reminder` with respect to the id from the Database
    ///
    /// - Parameter remidnerID: The id of the Reminder from database
    func delete(reminderID: Int) {
        if reminderDB.delete(id: reminderID) {
            Printer.printToConsole("Successfully deleted")
        } else {
            Printer.printToConsole("Error in deleting Reminder from database")
        }
    }
}
