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
            inputString = string! + "(Y/N)"
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
    /// - Returns: A case of the `Enum` type from user input
    static func getEnumResponse<Enum: CaseIterable>(type: Enum.Type) -> Enum {
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
}
