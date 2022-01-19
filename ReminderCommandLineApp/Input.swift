//
//  Input.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 13/12/21.
//

import Foundation

/// Used to get input from user
struct Input {
    private init() {}
    /// Returns a `String` response from user
    ///
    /// - Parameter string: Displayed to user before getting input
    /// - Returns: A `String` response from user
    static func getResponse(string: String? = nil) -> String {
        var response: String?
        while true {
            if string != nil {
                Printer.printToConsole("Enter \(string!): ")
            }
            response = readLine()
            if response == nil || response == "" {
                Printer.printToConsole("Invalid input!")
            } else {
                return response!
            }
        }
    }
    /// Returns a `Bool` response from user
    ///
    /// - Parameter string: Displayed to user before getting input
    /// - Returns: A `Bool` value indicating the response of the user
    static func getBooleanResponse(string: String? = nil) -> Bool {
        var inputString: String?
        if string == nil {
            inputString = "Y/N"
        } else {
            inputString = "Do you wish to enter " + string! + "?" + "(Y/N)"
        }
        while true {
            let response = Input.getResponse(string: inputString!)
            if response.lowercased() == "y" {
                return true
            } else if response.lowercased() == "n" {
                return false
            }
        }
    }
    /// Returns an `Enum` response from user input
    ///
    /// - Parameter type: The `enum` type to be iterated
    /// - Returns: A case of the `Enum` type from user input
    static func getEnumResponse<Enum: CaseIterable>(type: Enum.Type, name: String = "") -> Enum {
        Printer.printToConsole("Enter \(name): ")
        for (index, enumCase) in Enum.allCases.enumerated() {
            Printer.printToConsole("[\(index + 1)] \(enumCase)")
        }
        while true {
            if let caseIndex = Int(Input.getResponse(string: "response")) {
                for (index, enumCase) in Enum.allCases.enumerated() {
                    if caseIndex - 1 == index { return enumCase }
                }
                Printer.printToConsole("Invalid case")
            } else {
                Printer.printToConsole("Invalid input")
            }
        }
    }
    /// Returns an optional enum after getting availability of input from user
    /// - Parameters:
    ///  - type: The `Enum` type for which the input is obtained
    ///  - name: The name of the type in `String`
    /// - Returns: An optional enum value
    static func getOptionalEnumResponse<Enum: CaseIterable>(type: Enum.Type, name: String = "") -> Enum? {
        if getBooleanResponse(string: name) {
            return getEnumResponse(type: type, name: name)
        } else {
            return nil
        }
    }
    
    /// Returns an optional string by getting availability of input from user
    ///
    ///     getOptionalResponse(name: "title", for: "Reminder")
    ///     // gets the title? from the user
    ///
    /// - Parameters:
    ///   - name: The name of the value to be obtained from user
    ///   - objectName: The name of type for which we're getting input
    /// - Returns: An optional string based on the availability of the value
    static func getOptionalResponse(name: String, for objectName: String) -> String? {
        guard Input.getBooleanResponse(string: name) else {
            return nil
        }
        let value = Input.getResponse(string: "\(objectName) \(name)")
        return value
    }
    /// Returns an `Integer` obtained from the User, within a certain range
    ///
    /// - Parameters:
    ///  - range: The `Range` within which the `Integer` should lie within
    ///  - name: The name of the value which we are obtaining
    /// - Returns: The `Integer` obtained from the User
    static func getInteger<AnyRange: RangeExpression>(
        range: AnyRange, name string: String? = nil
    ) -> Int where AnyRange.Bound == Int {
        while true {
            var response: String = ""
            if let inputString = string {
                response = Self.getResponse(string: inputString)
            } else {
                response = Self.getResponse()
            }
            if let integer = Int(response), range.contains(integer) {
                return integer
            } else if let _ = Int(response) {
                Printer.printError("Input is not in range")
            } else {
                Printer.printError("Input cannot be interpreted as Int")
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
    private static func createDate(day: Int, month: Int, year: Int, hour: Int, minute: Int, second: Int) -> Date? {
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
    static func getDate(name: String? = nil) -> Date {
        let yearRange = 1970...2199
        let year = getInteger(range: yearRange, name: "year")
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
        let date = Self.createDate(day: day, month: month, year: year, hour: hour, minute: minute, second: second)!
        return date
    }
    /// Returns an optional `Date` object created from user inputs
    ///
    /// - Parameter name: a `String` to print while getting user input
    /// - Returns: A `Date` object created from user inputs
    static func getOptionalDate(name: String? = nil) -> Date? {
        guard Input.getBooleanResponse(string: "Date") else {
            return nil
        }
        return getDate(name: name)
    }
    /// Returns a `Bool` indicating whether the `ringTime` passed in argument lies between `addedTime` and `eventTime`
    ///
    /// - Parameters:
    ///  - ringTime: Number of seconds before the `evenTime` for which the `Reminder` should alert
    ///  - addedTime: The `Date` when the `Reminder` was added
    ///  - eventTime: The `Date` when  the `Reminder` is supposed to ring
    /// - Returns: A `Bool` indicating whether the `ringTime` is between `addedTime` and `eventTime`
    static func isValidRingTime(ringTime: TimeInterval, addedTime: Date, eventTime: Date?) -> Bool {
        let anHourInSeconds: TimeInterval = 3600
        let eventTime = eventTime ?? (addedTime + anHourInSeconds)
        let totalDateInterval = DateInterval(start: addedTime, end: eventTime)
        let totalTimeInterval = eventTime.timeIntervalSince(addedTime)
        return totalDateInterval.contains(Date(timeInterval: totalTimeInterval - ringTime, since: addedTime))
    }
    /// Returns a `Set` consisting of `TimeInterval`s  obtained from user
    ///
    /// - Parameters:
    ///  - addedTime: The `Date` when the `Reminder` was added
    ///  - eventTime: The `Date` when the `Reminder` should ring
    /// - Returns: A `Set`  of `TimeInterval`s when the `Reminder` should ring before the `eventTime`
    static func getRingTimeIntervals(addedTime: Date, eventTime: Date? = nil) -> Set<TimeInterval> {
        var ringTimeIntervals: Set<TimeInterval> = []
        guard Input.getBooleanResponse(string: "number of minutes before which the reminder should give alert") else {
            return ringTimeIntervals
        }
        repeat {
            let secondsInAMinute = 60
            let ringTime = TimeInterval(getInteger(range: 1..., name: "number of minutes before which the reminder should give alert") * secondsInAMinute)
            if isValidRingTime(ringTime: ringTime, addedTime: addedTime, eventTime: eventTime) {
                ringTimeIntervals.insert(Double(ringTime))
            } else {
                Printer.printToConsole("Invalid input(Input doesn't lie within the range Time.now < input < eventTime")
            }
        } while Input.getBooleanResponse(string: "another input")
        return ringTimeIntervals
    }
    /// Returns a eventTime obtained from the user after validating with addedTime
    /// - Parameter addedTime: The time the `Reminder` was added
    /// - Returns: The `Date` obtained from the user
    static func getEventTime(addedTime: Date) -> Date? {
        while let eventTime = getOptionalDate(name: "Event Time") {
            if eventTime <= addedTime {
                Printer.printError("Event Time invalid!")
            } else {
                return eventTime
            }
        }
        return nil
    }
}
