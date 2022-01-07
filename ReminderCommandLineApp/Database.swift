//
//  Database.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 14/12/21.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
    case connectionError(message: String)
    case preparationError(message: String)
    case stepError(message: String)
    case bindError(message: String)
}

class SQLite {
    private let dbPointer: OpaquePointer?
    private static let noErrorMessage = "No error message provided from sqlite."
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    deinit {
        sqlite3_close(dbPointer)
    }
    static func connect(path: String) throws -> SQLite {
        var db: OpaquePointer?
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLite(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let errorMessage = String(cString: errorPointer)
                throw SQLiteError.connectionError(message: errorMessage)
            } else {
                throw SQLiteError.connectionError(message: Self.noErrorMessage)
            }
        }
    }
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return Self.noErrorMessage
        }
    }
}

extension SQLite {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.preparationError(message: errorMessage)
        }
        return statement
    }
}

extension SQLite {
    func createTable(createStatement: String) throws {

        let createTableStatement = try prepareStatement(sql: createStatement)
        
        defer {
            sqlite3_finalize(createTableStatement)
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.stepError(message: errorMessage)
        }
    }
}













/*
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
            if id > 0 && Self.databaseArray!.count >= id {
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



*/













/// Used to perform operations with Database, Types conforming to this protocol can be used for database operations
protocol Database {
    
    // Object is optional assuming the connection made to database can fail and the object can be nil
    static var database: SQLite? { get set }
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

extension Database where ElementID == Int32 {
    
    static var createStatement: String {
        """
        CREATE TABLE \(name)(
        id INT PRIMARY KEY NOT NULL,
        base64_encoded_json_string VARCHAR(255)
        );
        """
    }
    
    static var insertStatement: String {
        """
        INSERT INTO \(name)(id, base64_encoded_json_string)
        VALUES (?, ?);
        """
    }
    
    static var selectStatement: String {
        """
        SELECT * FROM \(name) WHERE id = ?;
        """
    }
    
    // Connect db
    static func connect() -> Bool {
        // path
        let dbPath = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("commandLineAppData.sqlite").relativePath
        do {
            // connecting to file
            if database == nil {
                database = try SQLite.connect(path: dbPath ?? "")
            }
            if let database = database {
                // creating table
                try database.createTable(createStatement: createStatement)
                Printer.printToConsole("\(name) table created successfully")
                return true
            } else {
                Printer.printError("No database connected -- unexpected error")
                return false
            }
        } catch SQLiteError.connectionError(message: let error) {
            Printer.printError("SQL connection failed")
            Printer.printError(error)
            return false
        } catch SQLiteError.stepError(message: let error) {
            Printer.printError("\(name) table creation failed")
            Printer.printError(error)
            return false
        } catch let error {
            Printer.printError("Unexpected error occured while initiating database")
            Printer.printError(error)
            return false
        }
    }
    // Creates entry in table
    static func create(element: ElementObject) -> (ElementID, Bool) {
        // create a row in table and return success/failure, along with generated row's id
        do {
            idGenerator += 1
            var result = true
            if let database = database {
                let insertSql = try database.prepareStatement(sql: insertStatement)
                defer {
                    sqlite3_finalize(insertSql)
                }
                let string = try element.encode(as: .json).base64EncodedString() as NSString
                guard sqlite3_bind_int(insertSql, 1, idGenerator) == SQLITE_OK &&
                        sqlite3_bind_text(insertSql, 2, string.utf8String, -1, nil) == SQLITE_OK
                else {
                    throw SQLiteError.bindError(message: database.errorMessage)
                }
                guard sqlite3_step(insertSql) == SQLITE_DONE else {
                    throw SQLiteError.stepError(message: database.errorMessage)
                }
                Printer.printToConsole("Successfully inserted row.")
                return (idGenerator, result)
            } else {
                Printer.printError("No database connection")
                idGenerator -= 1
                result = false
                return (0, result)
            }
        } catch let error {
            Printer.printError(error)
            idGenerator -= 1
            return (0, false)
        }
        
    }
    
    static func retrieve(id: ElementID) -> ElementObject? {
        // retrieve a row from table if found, else return nil
        do {
            if let database = database {
                let selectSql = try database.prepareStatement(sql: selectStatement)
                defer {
                    sqlite3_finalize(selectSql)
                }
                guard sqlite3_bind_int(selectSql, 1, id) == SQLITE_OK else {
                    Printer.printError("Failure in binding id in SQL statement while retrieving from \(name) table")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                guard sqlite3_step(selectSql) == SQLITE_ROW else {
                    Printer.printError("Failure in retrieving from \(name) table")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                guard let result = sqlite3_column_text(selectSql, 1) else {
                    Printer.printError("Failure in retrieving from \(name) table, no rows found")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                let object = try Data(base64Encoded: String(cString: result))?.decode(ElementObject.self, format: .json)
                Printer.printToConsole("Successfully retrieved row.")
                return object
            } else {
                Printer.printError("No database connection")
                return nil
            }
        } catch let error {
            Printer.printError("Error while retrieving row from \(name) table")
            Printer.printError(error)
            return nil
        }
    }
    
    static func update(id: ElementID, element: ElementObject) -> Bool {
        // update a row in table and return success/failure
        do {
            let string = try element.encode(as: .json).base64EncodedString()
            
            var updateStatement: String {
                """
                UPDATE \(name) SET base64_encoded_json_string=\(string)
                WHERE id=\(id);
                """
            }
            if let database = database {
                let updateSql = try database.prepareStatement(sql: updateStatement)
                defer {
                    sqlite3_finalize(updateSql)
                }
                guard sqlite3_step(updateSql) == SQLITE_DONE else {
                    Printer.printError("Failure in updating \(name) table")
                    Printer.printError(database.errorMessage)
                    return false
                }
                Printer.printToConsole("Successfully updated row.")
                return true
            } else {
                Printer.printError("No database connection")
                return false
            }
            
        } catch let error {
            Printer.printError("Failed to update a row in \(name) table")
            Printer.printError(error)
            return false
        }
    }
    // Deletes entry in table
    static func delete(id: ElementID) -> Bool {
        // delete a row in table and return success/failure
        do {
            var deleteStatement: String {
                """
                DELETE FROM \(name)
                WHERE id=\(id);
                """
            }
            if let database = database {
                let deleteSql = try database.prepareStatement(sql: deleteStatement)
                defer {
                    sqlite3_finalize(deleteSql)
                }
                guard sqlite3_step(deleteSql) == SQLITE_DONE else {
                    Printer.printError("Failure in deleting from \(name) table")
                    Printer.printError(database.errorMessage)
                    return false
                }
                Printer.printToConsole("Successfully deleted row.")
                return true
            } else {
                Printer.printError("No database connection")
                return false
            }
            
        } catch let error {
            Printer.printError("Failed to delete a row in \(name) table")
            Printer.printError(error)
            return false
        }
    }
}

class ReminderDB: Database {

    typealias ElementID = Int32
    typealias ElementObject = Reminder
    // Object is optional assuming the connection made to database can fail and the object can be nil
    static var database: SQLite? = nil
    static var idGenerator: ElementID = 0
    
    static var name: String = "Reminder"
}

class NotesDB: Database {
    
    
    typealias ElementID = Int32
    typealias ElementObject = Notes
    
    static var database: SQLite? = nil
    static var idGenerator: ElementID = 0
    
    static var name: String = "Notes"
}
