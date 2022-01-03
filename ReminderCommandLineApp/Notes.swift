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
}

struct Notes: NotesProtocol {
    
    private var MAX_LENGTH = 20
    
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
    
    init(title: String, description: String) {
        self.description = description
        self.title = title
    }
}
