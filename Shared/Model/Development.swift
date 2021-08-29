//
//  Development.swift
//  Gifter
//
//  Created by Tanner on 8/10/21.
//

import Foundation

/**
 Logs an Appear command to the console.
 
 - Parameters:
    - title: The title of the View that is appearing
 */
func logAppear(title: String) {
    let message = "\(title) Appears"
    logFilter(message)
}

/**
 Logs a Disappear command to the console.
 
 - Parameters:
    - title: The title of the View that is disappearing
 */
func logDisappear(title: String) {
    let message = "\(title) Disappears"
    logFilter(message)
}

/**
 Logs a message with extra text that can be easily filtered from other messages in the console window.
 
 - Parameters:
    - msg: The message content to display
    - filter: The text filter to use alongside the message content
 */
func logFilter(_ msg: String, filter: String = "GifterLog") {
    print("\(filter): \(msg)")
}
