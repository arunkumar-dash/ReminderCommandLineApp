//
//  Database.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 14/12/21.
//

import Foundation

/// Used to perform operations with Database, Types conforming to this protocol can be used for database operations
protocol Database {
    associatedtype ElementObject: Codable
    associatedtype ElementID: Comparable
    /// Creates an entry in the database and returns the generated ID and the result of the operation(Sucess/ Failure)
    func create(element: ElementObject) -> (ElementID, Bool)
    /// Returns the element present at that id
    func retrieve(id: ElementID) async -> Reminder?
    /// Updates the database with the given ID
    func update(id: ElementID, element: ElementObject) async -> Bool
    /// Deletes the element present at that id
    func delete(id: ElementID) async -> Bool
}
extension Reminder {
    
    enum EncodingFormat {
        case json
    }
    
    enum ReminderCodingError: Error {
        case invalidEncodingFormat
        case invalidReminderObject
        case invalidReminderData
        case invalidDecodingFormat
    }
    
    func encode(as type: EncodingFormat) throws -> Data {
        if type == .json {
            do {
                let data = try JSONEncoder().encode(self)
                return data
            } catch EncodingError.invalidValue(_, let context) {
                Printer.printError(context.debugDescription)
                throw ReminderCodingError.invalidReminderObject
            }
        } else {
            throw ReminderCodingError.invalidEncodingFormat
        }
    }
    
    func decode(_ data: Data, from type: EncodingFormat) throws -> Reminder {
        do {
            let reminder = try JSONDecoder().decode(Reminder.self, from: data)
            return reminder
        } catch DecodingError.dataCorrupted(let context) {
            Printer.printError(context.debugDescription)
            throw ReminderCodingError.invalidReminderData
        }
    }
}
extension Data {
    func decode<ReminderType: ReminderProtocol & Decodable>(_ type: ReminderType.Type, format: Reminder.EncodingFormat) throws -> ReminderType {
        if format == .json {
            do {
                let reminder = try JSONDecoder().decode(type, from: self)
                return reminder
            } catch DecodingError.dataCorrupted(let context) {
                Printer.printError(context.debugDescription)
                throw Reminder.ReminderCodingError.invalidReminderData
            }
        } else {
            throw Reminder.ReminderCodingError.invalidDecodingFormat
        }
    }
}
class ReminderDB: Database {
    typealias ElementID = Int
    typealias ElementObject = Reminder
    private var databaseArray: Array<Data?>?
    private var idGenerator = 0
    init() {
        // connect db
        databaseArray = []
    }
    // Creates entry in table
    func create(element: Reminder) -> (Int, Bool) {
        // create a row in reminder table and return success/failure, along with generated row's id
        var success: Bool
        if databaseArray != nil {
            if let data = try? element.encode(as: .json) {
                databaseArray?.append(data)
                sleep(1)
            }
            success = true
            idGenerator = databaseArray!.count
        } else {
            Printer.printError("failure in inserting data to database - no connection made yet!")
            success = false
        }
        return (idGenerator, success)
    }
    func retrieve(id: Int) -> Reminder? {
        // retrieve a row from reminder table if found, else return nil
        if databaseArray != nil {
            if databaseArray!.count >= id {
                do {
                    let reminder = try databaseArray![id - 1]!.decode(Reminder.self, format: .json)
                    sleep(1)
                    return reminder
                } catch let error {
                    Printer.printError(error)
                    return nil
                }
            } else {
                Printer.printError("failure in retrieving data from database - id not created yet")
                return nil
            }
        } else {
            Printer.printError("failure in retrieving data from database - no connection made yet!")
            return nil
        }
    }
    func update(id: Int, element: Reminder) -> Bool {
        // update a row in reminder table and return success/failure
        var success: Bool
        if databaseArray != nil {
            if databaseArray!.count >= id {
                do {
                    let data = try element.encode(as: .json)
                    databaseArray?[id - 1] = data
                    sleep(1)
                    success = true
                } catch let error {
                    Printer.printError(error)
                    success = false
                }
            } else {
                Printer.printError("failure in updating data from database - id not created yet")
                success = false
            }
        } else {
            Printer.printError("failure in updating data from database - no connection made yet!")
            success = false
        }
        return success
    }
    // Deletes entry in table
    func delete(id: Int) -> Bool {
        // delete a row in reminder table and return success/failure
        var success: Bool
        if databaseArray != nil {
            if databaseArray!.count >= id {
                databaseArray?[id - 1] = nil
                success = true
                sleep(1)
            } else {
                Printer.printError("failure in deleting data from database - id not created yet")
                success = false
            }
        } else {
            Printer.printError("failure in deleting data from database - no connection made yet!")
            success = false
        }
        return success
    }
}
