//
//  Notes.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 03/01/22.
//

import Foundation

protocol NotesProtocol: Identifiable {
    
    var title: String { get set }
    
    var description: String { get set }
    
    var addedTime: Date { get set }
    
    var id: NotesDB.ElementID? { get set }
}

struct Notes: NotesProtocol, Codable {
    
    private var MAX_LENGTH = 50
    
    private var _title: String?
    
    var title: String {
        get {
            return _title ?? ""
        }
        set {
            if newValue.count > MAX_LENGTH {
                _title = String(newValue[..<newValue.index(newValue.startIndex, offsetBy: MAX_LENGTH)])
            } else {
                _title = newValue
            }
        }
    }
    
    var description: String
    
    var addedTime: Date
    
    var id: NotesDB.ElementID?
    
    init(title: String?, description: String?, addedTime: Date?) {
        self.addedTime = NotesDefaults.setValue(addedTime: addedTime)
        self.description = NotesDefaults.setValue(description: description)
        self.title = NotesDefaults.setValue(title: title)
    }
}

// View
extension Notes {
    static func viewNotes(id: NotesDB.ElementID) {
        guard let notes = NotesDB.retrieve(id: id) else {
            Printer.printError("Failed to retrieve notes from database. Received a nil value.")
            return
        }
        Printer.printLine()
        Printer.printToConsole("Notes")
        Printer.printLine()
        Printer.printToConsole("Title: \(notes.title)")
        Printer.printToConsole("Description: \(notes.description)")
        Printer.printToConsole("Creation date: \(notes.addedTime.description(with: .current))")
        Printer.printLine()
    }
}

protocol NotesViewProtocol {
    func orderByTime()
    func orderByName()
}
