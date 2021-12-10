//
//  Printer.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 10/12/21.
//

import Foundation
struct Printer<Element> {
    private init() {}
    static func printToConsole(_ element: Element) {
        print(element)
    }
}
