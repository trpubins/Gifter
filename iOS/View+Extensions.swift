//
//  View+Extensions.swift
//  iOS (Helper)
//  https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
//  https://forums.swift.org/t/conditionally-apply-modifier-in-swiftui/32815/3
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
    
    /**
     Modifies a View in such a way that it permits other modifiers on condition.
     
     - Parameters:
        - conditional: A conditional statement for determining if another modifier shall be applied to the View
        - content: The additional modifier(s) to apply to this View if the condition evaluates to `true`
     
     - Returns: The View modified if the conditional evaluated to `true`, otherwise just returns the View that this function was applied.
     */
    func `ifTrue`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            return AnyView(content(self))
        } else {
            return AnyView(self)
        }
    }
    
}
#endif
