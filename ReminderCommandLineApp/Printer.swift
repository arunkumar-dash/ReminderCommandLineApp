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
}
