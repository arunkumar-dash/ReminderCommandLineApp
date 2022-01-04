//
//  Database.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 14/12/21.
//

import Foundation

/// Used to perform operations with Database, Types conforming to this protocol can be used for database operations
protocol Database {
    
    // Object is optional assuming the connection made to database can fail and the object can be nil
    static var databaseArray: Array<Data?>? { get set }
    static var idGenerator: ElementID { get set }
    static var name: String { get set }
    
    
    associatedtype ElementID: Comparable
    associatedtype ElementObject: Codable
    /// Creates an entry in the database and returns the generated ID and the result of the operation(Sucess/ Failure)
    static func create(element: ElementObject) -> (ElementID, Bool)
    /// Returns the element present at that id
    static func retrieve(id: ElementID) async -> ElementObject?
    /// Updates the database with the given ID
    static func update(id: ElementID, element: ElementObject) async -> Bool
    /// Deletes the element present at that id
    static func delete(id: ElementID) async -> Bool
}

enum EncodingFormat {
    case json
}

enum CodingError: Error {
    case invalidEncodingFormat
    case invalidObject
    case invalidData
    case invalidDecodingFormat
}

extension Encodable {
    
    func encode(as type: EncodingFormat) throws -> Data {
        if type == .json {
            do {
                let data = try JSONEncoder().encode(self)
                return data
            } catch EncodingError.invalidValue(_, let context) {
                Printer.printError(context.debugDescription)
                throw CodingError.invalidObject
            }
        } else {
            throw CodingError.invalidEncodingFormat
        }
    }
}

extension Decodable {
    
    func decode(_ data: Data, from type: EncodingFormat) throws -> Self {
        do {
            let object = try JSONDecoder().decode(Self.self, from: data)
            return object
        } catch DecodingError.dataCorrupted(let context) {
            Printer.printError(context.debugDescription)
            throw CodingError.invalidData
        }
    }
}

extension Data {
    func decode<Type: Decodable>(_ type: Type.Type, format: EncodingFormat) throws -> Type {
        if format == .json {
            do {
                let object = try JSONDecoder().decode(type, from: self)
                return object
            } catch DecodingError.dataCorrupted(let context) {
                Printer.printError(context.debugDescription)
                throw CodingError.invalidData
            }
        } else {
            throw CodingError.invalidDecodingFormat
        }
    }
}

extension Database where ElementID == Int {
    // Connect db
    static func connect() -> Bool {
        if let _ = Self.databaseArray {
            return true
        }
        Self.databaseArray = []
        // return false if any error in connnection
        return true
    }
    // Creates entry in table
    static func create(element: ElementObject) -> (ElementID, Bool) {
        // create a row in table and return success/failure, along with generated row's id
        var success: Bool
        if Self.databaseArray != nil {
            if let data = try? element.encode(as: .json) {
                Self.databaseArray?.append(data)
                sleep(1)
            }
            success = true
            Self.idGenerator = Self.databaseArray!.count
        } else {
            Printer.printError("failure in inserting data to database - no connection made yet!")
            success = false
        }
        return (Self.idGenerator, success)
    }
    static func retrieve(id: ElementID) -> ElementObject? {
        // retrieve a row from table if found, else return nil
        if Self.databaseArray != nil {
            if Self.databaseArray!.count >= id {
                do {
                    if let data = Self.databaseArray![id - 1] {
                        let object = try data.decode(ElementObject.self, format: .json)
                        sleep(1)
                        return object
                    } else {
                        return nil
                    }
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
    static func update(id: ElementID, element: ElementObject) -> Bool {
        // update a row in table and return success/failure
        var success: Bool
        if Self.databaseArray != nil {
            if Self.databaseArray!.count >= id {
                do {
                    let data = try element.encode(as: .json)
                    Self.databaseArray?[id - 1] = data
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
    static func delete(id: ElementID) -> Bool {
        // delete a row in table and return success/failure
        var success: Bool
        if Self.databaseArray != nil {
            if Self.databaseArray!.count >= id {
                Self.databaseArray?[id - 1] = nil
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

class ReminderDB: Database {
    
    typealias ElementID = Int
    typealias ElementObject = Reminder
    // Object is optional assuming the connection made to database can fail and the object can be nil
    static var databaseArray: Array<Data?>? = nil
    static var idGenerator = 0
    
    static var name: String = "Reminder"
}

class NotesDB: Database {
    
    typealias ElementID = Int
    typealias ElementObject = Notes
    
    static var databaseArray: Array<Data?>? = nil
    static var idGenerator = 0
    
    static var name: String = "Notes"
}
