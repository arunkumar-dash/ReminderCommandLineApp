//
//  Database.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 14/12/21.
//

import Foundation
import SQLite3

/// Errors to handle SQLite3 error codes
enum SQLiteError: Error {
    case connectionError(message: String)
    case preparationError(message: String)
    case stepError(message: String)
    case bindError(message: String)
}
/// A wrapper over the SQLite3 framework
class SQLite {
    /// The C pointer which is used to perform all database operations
    private let dbPointer: OpaquePointer?
    private static let noErrorMessage = "No error message provided from sqlite."
    /// Initialiser is private because the user should instantiate only using static functions
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    deinit {
        /// Clearing the memory referenced by the pointer to avoid memory leaks
        sqlite3_close(dbPointer)
    }
    /// Connects the database to the file with extension .sqlite and returns an SQLite instance
    /// - Parameter path: The absolute path of the file with .sqlite extension
    /// - Returns: An SQLite instance initiated with the database
    static func connect(path: String) throws -> SQLite {
        var db: OpaquePointer?
        /// Opening the connection to database, `SQLITE_OK` is a success code
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLite(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    /// Closing the database incase of failure
                    sqlite3_close(db)
                }
            }
            /// Handling errors
            if let errorPointer = sqlite3_errmsg(db) {
                let errorMessage = String(cString: errorPointer)
                throw SQLiteError.connectionError(message: errorMessage)
            } else {
                throw SQLiteError.connectionError(message: Self.noErrorMessage)
            }
        }
    }
    /// A property to hold the most recent error message
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
    /// Prepares the SQL command and returns the pointer to the compiled command
    /// - Parameter sql: The SQL command as a `String`
    /// - Returns: An `OpaquePointer` which references the compiled SQL statement
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.preparationError(message: errorMessage)
        }
        return statement
    }
}

extension SQLite {
    /// Creates a table
    /// - Parameter createStatement: The SQL command to create the table
    /// - Throws:
    ///  - stepError: Incase there causes error in executing the prepared SQL command
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

/// Used to perform operations with Database, Types conforming to this protocol can be used for database operations
protocol Database {
    
    /// The database object to access the database
    static var database: SQLite? { get set }
    /// Generates ID to insert data into the database
    static var idGenerator: ElementID { get set }
    /// The name of the database
    static var name: String { get set }
    
    
    associatedtype ElementID: Comparable
    associatedtype ElementObject: Codable
    /// Creates an entry in the database and returns the generated ID and the result of the operation(Sucess/ Failure)
    static func create(element: ElementObject) -> (ElementID, Bool)
    /// Returns the element present at that id
    static func retrieve(id: ElementID) async -> ElementObject?
    /// Updates the database at the given ID with the given Object
    static func update(id: ElementID, element: ElementObject) async -> Bool
    /// Deletes the element present at that id
    static func delete(id: ElementID) async -> Bool
}
/// The formats available to be encoded
enum EncodingFormat {
    case json
}
/// Errors which can be thrown while Encoding/Decoding
enum CodingError: Error {
    case invalidEncodingFormat
    case invalidObject
    case invalidData
    case invalidDecodingFormat
}

extension Encodable {
    /// Encodes the type with respect to the Encoding format
    /// - Parameter type: The type to which the object should be encoded
    /// - Returns: The encoded `Data`
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

extension Data {
    /// Decodes the `Data` from the `format` specified to the `type` specified in parameters
    /// - Parameter type: The `Type` to which the `Data` should be decoded
    /// - Returns: The instance of the type specified in parameters
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
    /// The SQL create command for the specific table
    static var createStatement: String {
        """
        CREATE TABLE \(name)(
        id INT PRIMARY KEY NOT NULL,
        base64_encoded_json_string VARCHAR(255)
        );
        """
    }
    /// The SQL insert command for the specific table
    static var insertStatement: String {
        """
        INSERT INTO \(name)(id, base64_encoded_json_string)
        VALUES (?, ?);
        """
    }
    /// The SQL select command for the specific table
    static var selectStatement: String {
        """
        SELECT * FROM \(name) WHERE id = ?;
        """
    }
    
    /// Connects the database and creates the table for the specific type
    /// - Returns: A `Bool` value determining the success or failure
    static func connect() -> Bool {
        /// The path where the database file is to be located
        let DB_PATH = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("commandLineAppData.sqlite").relativePath
        do {
            /// Connecting to the SQLite file
            if database == nil {
                database = try SQLite.connect(path: DB_PATH ?? "")
            }
            if let database = database {
                /// Creating the table
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
    /// Creates entry in the table of the specific type
    /// - Parameter element: The instance to be inserted
    /// - Returns: A tuple consisting of the `id` of the row inserted and a `Bool` to determine the result
    static func create(element: ElementObject) -> (ElementID, Bool) {
        do {
            idGenerator += 1
            var result = true
            if let database = database {
                let insertSql = try database.prepareStatement(sql: insertStatement)
                defer {
                    sqlite3_finalize(insertSql)
                }
                /// Object encoded as string
                let string = try element.encode(as: .json).base64EncodedString() as NSString
                /// Binding the `id` and the `data`
                guard sqlite3_bind_int(insertSql, 1, idGenerator) == SQLITE_OK &&
                        sqlite3_bind_text(insertSql, 2, string.utf8String, -1, nil) == SQLITE_OK
                else {
                    throw SQLiteError.bindError(message: database.errorMessage)
                }
                /// Executing the query
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
    /// Returns an object retrieved from the table at the `id` provided in parameter
    /// - Parameter id: The row id where the data is located
    /// - Returns: An optional object constructed with the data retrieved from the database
    static func retrieve(id: ElementID) -> ElementObject? {
        do {
            if let database = database {
                /// Preparing the query
                let selectSql = try database.prepareStatement(sql: selectStatement)
                defer {
                    sqlite3_finalize(selectSql)
                }
                /// Binding the `id` with the command
                guard sqlite3_bind_int(selectSql, 1, id) == SQLITE_OK else {
                    Printer.printError("Failure in binding id in SQL statement while retrieving from \(name) table")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                /// Executing the query
                guard sqlite3_step(selectSql) == SQLITE_ROW else {
                    Printer.printError("Failure in retrieving from \(name) table")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                /// Retrieving the data of the first row from the result
                guard let result = sqlite3_column_text(selectSql, 1) else {
                    Printer.printError("Failure in retrieving from \(name) table, no rows found")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                /// Converting result of cString to the object
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
    /// Updates the table at the `id` with the `element`
    /// - Parameters:
    ///  - id: The row `id` where the element is present in the database
    ///  - element: The object to be updated
    /// - Returns: A `Bool` determining the result of the update query
    static func update(id: ElementID, element: ElementObject) -> Bool {
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
    /// Deletes the data from the table present at the `id` passed in parameter
    /// - Parameter id: The row id of the table
    /// - Returns: A `Bool` representing the result of the operation
    static func delete(id: ElementID) -> Bool {
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
