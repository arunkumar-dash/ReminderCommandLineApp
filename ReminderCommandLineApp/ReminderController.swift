//
//  ReminderController.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 13/12/21.
//

import Foundation

struct ReminderController {
    let reminderDB: ReminderDB
    init() {
        reminderDB = ReminderDB()
    }
    private func createReminder(title: String? = nil, description: String? = nil, eventTime: Date?,
                                sound: String? = nil, repeatTiming: RepeatPattern? = nil, ringTimeList: Set<TimeInterval>? = nil) -> Reminder {
        return Reminder(addedTime: Date.now, title: title, description: description, eventTime: eventTime, sound: sound, repeatTiming: repeatTiming, ringTimeList: ringTimeList)
    }
    /// Returns an optional string by getting availability of input from user
    ///
    /// e.g., getOptionalValue(name: "title") gets the title? from the user
    /// - Parameter name: The name of the value to be obtained from user
    /// - Returns: An optional string based on the availability of the value
    private func getOptionalValue(name: String) -> String? {
        guard Input.getBooleanResponse(string: "Is \(name) available?") else {
            return nil
        }
        let value = Input.getResponse(string: "reminder \(name)")
        return value
    }
    private func getInteger<AnyRange: RangeExpression>(range: AnyRange, name string: String? = nil) -> Int where AnyRange.Bound == Int{
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
    private func getDate(day: Int, month: Int, year: Int, hour: Int, minute: Int, second: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = TimeZone(abbreviation: "IST")
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second

        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)
    }
    private func getOptionalDate(name: String?) -> Date? {
        guard Input.getBooleanResponse(string: "Date") else {
            return nil
        }
        let year = getInteger(range: 1970...2199, name: "year")
        let month = getInteger(range: 1...12, name: "month")
        let monthsWith31Days = [1, 3, 5, 7, 8, 10, 12]
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
        let date = getDate(day: day, month: month, year: year, hour: hour, minute: minute, second: second)
        return date!
    }
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
                let enumCase = Input.getEnumResponse(of: WeekDay.monday)
                weekDaySet.insert(enumCase)
            } while Input.getBooleanResponse(string: "Do you want to enter another Week Day?")
            return RepeatPattern.custom(weekDaySet)
        default:
            Printer.printToConsole("Invalid case")
        }
        return nil
    }
    private func isValidRingTime(ringTime: TimeInterval) -> Bool {
        return true
    }
    private func getRingTimeList() -> Set<TimeInterval> {
        var ringTimeList: Set<TimeInterval> = []
        repeat {
            let ringTime = TimeInterval(getInteger(range: 1...,
                                      name: "Enter number of minutes before which the reminder should give alert: ") * 60)
            if isValidRingTime(ringTime: ringTime) {
                ringTimeList.insert(Double(ringTime))
            } else {
                Printer.printToConsole("Invalid input(Input doesn't lie within the range Time.now < input < eventTime")
            }
        } while Input.getBooleanResponse(string: "Do you want to enter another input? ")
        return ringTimeList
    }
    private func getDetails() -> Reminder {
        let title = getOptionalValue(name: "Title")
        let description = getOptionalValue(name: "Description")
        let eventTime = getOptionalDate(name: "Event Time")
        let sound = getOptionalValue(name: "Sound")
        let repeatTiming = getRepeatPattern()
        let ringTimeList = getRingTimeList()
        return createReminder(title: title, description: description, eventTime: eventTime,
                              sound: sound, repeatTiming: repeatTiming, ringTimeList: ringTimeList)
    }
    func add() {
        let reminder = getDetails()
        if reminderDB.create(reminder: reminder) {
            Printer.printToConsole("Successfully created reminder database")
        } else {
            Printer.printToConsole("Failure in creating database")
        }
    }
    func delete(reminderID: Int) {
//        return reminderDB.delete(reminderID)
    }
}

