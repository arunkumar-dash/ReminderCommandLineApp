//
//  Input.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 13/12/21.
//

import Foundation

struct Input {
    private init() {}
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
    static func getEnumResponse<Enum: CaseIterable>(of enum: Enum) -> Enum {
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
