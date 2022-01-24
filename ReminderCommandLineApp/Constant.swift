//
//  Constant.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 05/01/22.
//

import Foundation

extension TimeInterval: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)!
    }
}

struct Constant: Codable {
    
    static let DB_FOLDER = ".ReminderAppDatabase"
    
    var TASK_SOUND_PATH = "/Users/arun-pt4306/Downloads/alert_sound.wav"
    
    var REMINDER_SOUND_PATH = "/Users/arun-pt4306/Downloads/sound.wav"
    
    enum TimeIntervals: TimeInterval, CaseIterable, Codable {
        case oneHour = 3600
        case halfHour = 1800
        case fifteenMinutes = 900
        case tenMinutes = 600
        case fiveMinutes = 300
    }
    
    var REMINDER_TITLE = "Reminder"
    
    var REMINDER_DESCRIPTION = "Your description goes here..."
    
    var REMINDER_REPEAT_PATTERN: RepeatPattern = .never
    
    var REMINDER_EVENT_TIME: TimeIntervals = .oneHour
    
    var REMINDER_RING_TIME_INTERVALS: Set<TimeInterval> = Set([Constant.TimeIntervals.halfHour.rawValue])
    
    var NOTES_TITLE = "Note"
    
    var NOTES_DESCRIPTION = "Your description goes here..."
    
    var NOTIFICATION_SNOOZE_TIME = Constant.TimeIntervals.tenMinutes.rawValue
    
    var TASK_DEADLINE: Date? = nil
    
    private init() {
        
    }
    
    static func updateFromDB() {
        let databaseFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent(Constant.DB_FOLDER)
        
        do {
            try FileManager.default.createDirectory(at: databaseFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            Printer.printError("Failed to create directory while connecting to defaults database")
            Printer.printError(error)
            return
        }
        
        let url = databaseFolder.appendingPathComponent("defaults.json")
        if let data = try? Data(contentsOf: url) {
            Printer.printToConsole("Saved defaults file found")
            if let constant = try? JSONDecoder().decode(Self.self, from: data) {
                Constant.shared = constant
                Printer.printToConsole("Saved defaults decoded")
            } else {
                Printer.printError("Cannot decode the defaults file from database")
                return
            }
        } else {
            do {
                try JSONEncoder().encode(Constant.shared).write(to: url)
            } catch let error {
                Printer.printError("Cannot encode defaults to a file")
                Printer.printError(error)
                return
            }
            Printer.printToConsole("New defaults file created")
        }
    }
    
    private static func sync() {
        let databaseFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent(Constant.DB_FOLDER)
        
        do {
            try FileManager.default.createDirectory(at: databaseFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            Printer.printError("Failed to create directory while connecting to defaults database")
            Printer.printError(error)
            return
        }
        
        let url = databaseFolder.appendingPathComponent("defaults.json")
        do {
            try JSONEncoder().encode(Constant.shared).write(to: url)
        } catch let error {
            Printer.printError("Cannot encode defaults to a file")
            Printer.printError(error)
            return
        }
    }
    
    static var shared = Constant() {
        didSet {
            Constant.sync()
        }
    }
}
