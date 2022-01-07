//
//  Printer.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 10/12/21.
//

import Foundation
struct Printer {
    private init() {}
    static func printToConsole<Element>(_ element: Element) {
        print(element)
    }
    static func printLine() {
        print(String(repeating: "-", count: 15))
    }
    static func printBlankLine() {
        print("")
    }
    static func printError<PrintingType: StringProtocol>(_ error: PrintingType) {
        let errorStatement = "\tERROR: " + error
        Printer.printToConsole(errorStatement)
    }
    static func printError<PrintingType: Error>(_ error: PrintingType) {
        let errorStatement = "\tERROR: " + error.localizedDescription
        Printer.printToConsole(errorStatement)
    }
}
