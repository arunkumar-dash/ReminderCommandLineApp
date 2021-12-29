//
//  Player.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 28/12/21.
//

import Foundation
import AppKit

struct Player {
    static func search(fileName name: String) -> URL? {
        let url = URL(fileURLWithPath: name)
            if url.isFileURL {
                return url
            } else {
                return nil
            }
    }
    static func play(fileUrl url: URL) -> Bool {
        let player = NSSound(contentsOf: url, byReference: true)
        if let player = player {
            return player.play()
        } else {
            return false
        }
    }
    static func searchAndPlay(fileName name: String) -> Bool {
        if let url = Player.search(fileName: name) {
            return Player.play(fileUrl: url)
        } else {
            return false
        }
    }
}
