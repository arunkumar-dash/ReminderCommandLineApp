//
//  Player.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 28/12/21.
//

import Foundation
import AVFAudio

/// Plays media synchronously
struct Player {
    /// Initialiser is private so that the type cannot be instantiated
    private init() {}
    /// Returns a `URL` constructed from the file name, if the file is found in Bundle
    /// - Parameter name: The file's name (or) path (in case the file is not available in Bundle)
    /// - Returns: A `URL` constructed from the input
    static func searchAudio(fileName name: String) -> URL? {
        let url = URL(fileURLWithPath: name)
            if url.isFileURL {
                return url
            } else {
                return nil
            }
    }
    /// Plays the audio file in the `URL` passed in parameter, using `AVFAudioPlayer`
    /// This function plays the file synchronously
    /// - Parameter url: The `URL` of the audio file
    /// - Returns: A `Bool` value indicating if the audio was played successfully
    static func playAudio(fileUrl url: URL) -> Bool {
        let player = try? AVAudioPlayer(contentsOf: url)
        if let player = player {
            let result = player.play()
            /// Sleeping for the duration of the audio playback
            sleep(UInt32(ceil(player.duration)))
            return result
        } else {
            return false
        }
    }
    /// Constructs a`URL` from the file name, plays the audio file from the `URL` constructed
    /// - Parameter name: The file's name (or) path (in case the file is not available in Bundle)
    /// - Returns: A `Bool` value indicating if the audio was played successfully 
    static func searchAndPlayAudio(fileName name: String) -> Bool {
        if let url = Player.searchAudio(fileName: name) {
            return Player.playAudio(fileUrl: url)
        } else {
            return false
        }
    }
}
