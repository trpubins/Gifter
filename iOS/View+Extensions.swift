//
//  View+Extensions.swift
//  iOS (Helper)
//  https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
//
//  Created by Tanner on 8/10/21.
//

import SwiftUI

// This extension is necessary to programmatically take away focus from a TextField in iOS 14 or iOS 13
// since there is no built-in method of doing this. iOS 15 makes this much easier with the focused() modifier.
#if canImport(UIKit)
extension View {
    
    /**
     Hides focus from the keyboard on iOS devices when called.
     */
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
#endif
