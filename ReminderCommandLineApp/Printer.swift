//
//  Printer.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 10/12/21.
//

import Foundation
/// Interface to print output
struct Printer {
    private init() {}
    /// Prints directly to console
    static func printToConsole<Element>(_ element: Element) {
        print(element)
    }
    /// Prints a hyphenated line
    static func printLine() {
        print(String(repeating: "-", count: 15))
    }
    /// Prints a blank line
    static func printBlankLine() {
        print("")
    }
    /// Prints the string indicating an Error
    static func printError<PrintingType: StringProtocol>(_ error: PrintingType) {
        let errorStatement = "\tERROR: " + error
        Printer.printToConsole(errorStatement)
    }
    /// Prints an `Error`'s description
    static func printError<PrintingType: Error>(_ error: PrintingType) {
        let errorStatement = "\tERROR: " + error.localizedDescription
        Printer.printToConsole(errorStatement)
    }
}
