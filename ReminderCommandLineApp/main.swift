//
//  main.swift
//  ReminderCommandLineApp
//
//  Created by Arun Kumar on 08/12/21.
//

import Foundation

print("Hello, World!")

// ADD REPEAT PATTERN ALSO IN NOTIFICATIONS.PUSH, NOTIFICATIONS.POP AS A PATTERN(LOGIC), NOT AS INDIVIDUAL INPUTS


NotificationManager.startBackgroundAction()
var controller = ReminderController()
outerLoop:
while true {
    print("Select: \n1. add \n2. retrieve \n3. update \n4. delete \n5. change preferences \n6. exit\n")
    let response = readLine()!
    switch Int(response)! {
    case 1:
        controller.add()
    case 2:
        print("enter id:")
        let id = readLine()!
        if let integerId = Int(id) {
            if let reminder = controller.get(reminderID: integerId) {
                print(reminder.title)
                print(reminder.description)
                print(Player.searchAndPlay(fileName: reminder.sound))
            } else {
                print("not found")
            }
        } else {
            print("error in input")
        }
    case 3:
        print("enter id:")
        let id = readLine()!
        if let integerId = Int(id) {
            let title = "NewTitle"
            controller.edit(reminderID: integerId, reminder: Reminder(addedTime: Date.now, title: title))
        } else {
            print("error in input")
        }
    case 4:
        print("enter id:")
        let id = readLine()!
        if let integerId = Int(id) {
            controller.delete(reminderID: integerId)
        } else {
            print("error in input")
        }
    case 5:
        controller.changePreferences()
    case 6:
        break outerLoop
    default:
        print("invalid case")
    }
}

//let filePath = Bundle.main.path(forResource: "sound", ofType: "wav", inDirectory: "ReminderCommandLineApp")
//print(Player.searchAndPlay(fileName: filePath ?? "/Users/arun-pt4306/Downloads/sound.wav"))
//sleep(2)

