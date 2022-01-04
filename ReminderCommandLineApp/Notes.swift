//
//  Notes.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 03/01/22.
//

import Foundation

protocol NotesProtocol {
    
    var title: String { get set }
    
    var description: String { get set }
    
    var addedTime: Date { get set }
}

struct Notes: NotesProtocol, Codable {
    
    private var MAX_LENGTH = 40
    
    private var _title: String?
    
    var title: String {
        get {
            return _title ?? ""
        }
        set {
            if newValue.count > MAX_LENGTH {
                _title = String(newValue[..<newValue.index(newValue.startIndex, offsetBy: MAX_LENGTH)])
            }
        }
    }
    
    var description: String
    
    var addedTime: Date
    
    init(title: String?, description: String?, addedTime: Date?) {
        self.addedTime = NotesDefaults.setValue(addedTime: addedTime)
        self.description = NotesDefaults.setValue(description: description)
        
        self.title = NotesDefaults.setValue(title: title)
    }
}

// View
