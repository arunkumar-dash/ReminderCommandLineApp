//
//  CredentialsDB.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 03/03/22.
//

import Foundation
import SQLite3

class CredentialsDB {
    static var database: SQLite?
    
    init() {
        while connect() == false {
            Printer.printToConsole("Reconnecting to DB...")
            sleep(1)
        }
    }
    
    
    private var createStatement: String {
        """
        CREATE TABLE Credentials(
        username VARCHAR PRIMARY KEY NOT NULL,
        password VARCHAR NOT NULL
        );
        """
    }
    
    private var insertStatement: String {
        """
        INSERT INTO Credentials(username, password)
        VALUES (?, ?);
        """
    }
    
    private var selectStatement: String {
        """
        SELECT password FROM Credentials WHERE username = ?;
        """
    }
    
    private var updateStatement: String {
        """
        UPDATE ? SET password = ?
        WHERE username = ?;
        """
    }
    
    private var deleteStatement: String {
        """
        DELETE FROM Credentials
        WHERE username = ?;
        """
    }
    
    private func connect() -> Bool {
        var result = true
        let databaseFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent(Constant.DB_FOLDER)
        
        do {
            try FileManager.default.createDirectory(at: databaseFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            Printer.printError("Failed to create directory while connecting to database")
            Printer.printError(error)
            return false
        }
        let DB_PATH = databaseFolder.appendingPathComponent("Credentials.sqlite").relativePath

        do {
            /// Connecting to the SQLite file
            if Self.database == nil {
                Self.database = try SQLite.connect(path: DB_PATH)
            }
            
            if let database = Self.database {
                /// Creating the table
                try database.createTable(createStatement: createStatement)
                Printer.printToConsole("Credentials table created successfully")
                return result
            } else {
                Printer.printError("No database connected -- unexpected error")
                result = false
                return result
            }
        } catch SQLiteError.tableCreationFailure(message: _) {
            Printer.printToConsole("Table already exists")
            return result
        } catch SQLiteError.connectionError(message: let error) {
            Printer.printError("SQL connection failed")
            Printer.printError(error)
            result = false
            return result
        } catch SQLiteError.stepError(message: let error) {
            Printer.printError("Credentials table creation failed")
            Printer.printError(error)
            result = false
            return result
        } catch SQLiteError.bindError(message: let error) {
            Printer.printError("Bind error while creating database")
            Printer.printError(error)
            result = false
            return result
        } catch SQLiteError.preparationError(message: let error) {
            Printer.printError("Preparation error while creating database")
            Printer.printError(error)
            result = false
            return result
        } catch let error {
            Printer.printError("Unexpected error occured while initiating database")
            Printer.printError(error)
            result = false
            return result
        }
    }
    
    func insert(username: String, password: String) -> Bool {
        var result = true
        do {
            if let database = Self.database {
                let insertSql = try database.prepareStatement(sql: insertStatement)
                defer {
                    sqlite3_finalize(insertSql)
                }
                
                
                let usernameString = username as NSString
                guard let encodedPassword = password.data(using: .utf8)?.base64EncodedString() else {
                    Printer.printError("Error in encoding to base64")
                    return false
                }
                let passwordString = encodedPassword as NSString
                
                guard sqlite3_bind_text(insertSql, 1, usernameString.utf8String, -1, nil) == SQLITE_OK &&
                        sqlite3_bind_text(insertSql, 2, passwordString.utf8String, -1, nil) == SQLITE_OK
                else {
                    throw SQLiteError.bindError(message: database.errorMessage)
                }
                /// Executing the query
                guard sqlite3_step(insertSql) == SQLITE_DONE else {
                    throw SQLiteError.stepError(message: database.errorMessage)
                }
                
                Printer.printToConsole("Successfully inserted row.")
                return result
            } else {
                Printer.printError("No database connection")
                result = false
                return result
            }
        } catch SQLiteError.stepError(message: let error) {
            Printer.printError("Cannot create entry in Credentials table")
            Printer.printError(error)
            return false
        } catch SQLiteError.bindError(message: let error) {
            Printer.printError("Cannot create entry in Credentials table")
            Printer.printError(error)
            return result
        } catch SQLiteError.preparationError(message: let error) {
            Printer.printError("Cannot create entry in Credentials table")
            Printer.printError(error)
            return false
        } catch let error {
            Printer.printError("Cannot create entry in Credentials table")
            Printer.printError(error)
            return false
        }
    }
    
    func getPassword(username: String) -> String? {
        do {
            if let database = Self.database {
                /// Preparing the query
                let selectSql = try database.prepareStatement(sql: selectStatement)
                defer {
                    sqlite3_finalize(selectSql)
                }
                
                let usernameString = username as NSString
                guard sqlite3_bind_text(selectSql, 1, usernameString.utf8String, -1, nil) == SQLITE_OK else {
                    Printer.printError("Failure in binding id in SQL statement while retrieving from Credentials table")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                /// Executing the query
                guard sqlite3_step(selectSql) == SQLITE_ROW else {
                    Printer.printError("Failure in retrieving from Credentials table")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                /// Retrieving the data of the first row from the result
                guard let result = sqlite3_column_text(selectSql, 0) else {
                    Printer.printError("Failure in retrieving from Credentials table, no rows found")
                    Printer.printError(database.errorMessage)
                    return nil
                }
                /// Converting result of cString to the object after decoding from base64
                let encodedPassword = String(cString: result)
                Printer.printToConsole("Successfully retrieved row.")
                guard let data = Data(base64Encoded: encodedPassword) else {
                    Printer.printError("Error in decoding from base64")
                    return nil
                }
                guard let password = String(data: data, encoding: .utf8) else {
                    Printer.printError("Error in decoding from base64")
                    return nil
                }
                return password
            } else {
                Printer.printError("No database connection")
                return nil
            }
        } catch let error {
            Printer.printError("Error while retrieving row from Credentials table")
            Printer.printError(error)
            return nil
        }
    }
    
    func update(password: String, for username: String) -> Bool {
        do {
            if let database = Self.database {
                let updateSql = try database.prepareStatement(sql: updateStatement)
                defer {
                    sqlite3_finalize(updateSql)
                }
                
                let usernameString = username as NSString
                guard let encodedPassword = password.data(using: .utf8)?.base64EncodedString() else {
                    Printer.printError("Error in encoding to base64")
                    return false
                }
                let passwordString = encodedPassword as NSString
                
                guard sqlite3_bind_text(updateSql, 1, usernameString.utf8String, -1, nil) == SQLITE_OK &&
                        sqlite3_bind_text(updateSql, 2, passwordString.utf8String, -1, nil) == SQLITE_OK
                else {
                    throw SQLiteError.bindError(message: database.errorMessage)
                }
                
                guard sqlite3_step(updateSql) == SQLITE_DONE else {
                    throw SQLiteError.stepError(message: database.errorMessage)
                }
                Printer.printToConsole("Successfully updated row.")
                return true
            } else {
                Printer.printError("No database connection")
                return false
            }
        } catch SQLiteError.stepError(message: let error) {
            Printer.printError("Failed to update a row in Credentials table")
            Printer.printError(error)
            return false
        } catch let error {
            Printer.printError("Failed to update a row in Credentials table")
            Printer.printError(error)
            return false
        }
    }
    
    func delete(username: String) -> Bool {
        do {
            if let database = Self.database {
                let deleteSql = try database.prepareStatement(sql: deleteStatement)
                defer {
                    sqlite3_finalize(deleteSql)
                }
                
                let usernameString = username as NSString
                
                guard sqlite3_bind_text(deleteSql, 1, usernameString.utf8String, -1, nil) == SQLITE_OK
                else {
                    throw SQLiteError.bindError(message: database.errorMessage)
                }
                
                guard sqlite3_step(deleteSql) == SQLITE_DONE else {
                    throw SQLiteError.stepError(message: database.errorMessage)
                }
                Printer.printToConsole("Successfully deleted row.")
                return true
            } else {
                Printer.printError("No database connection")
                return false
            }
        } catch SQLiteError.stepError(message: let error) {
            Printer.printError("Failed to delete a row in Credentials table")
            Printer.printError(error)
            return false
        } catch let error {
            Printer.printError("Failed to delete a row in Credentials table")
            Printer.printError(error)
            return false
        }
    }
}
