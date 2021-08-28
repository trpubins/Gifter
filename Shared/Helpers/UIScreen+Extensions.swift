//
//  UIScreen+Extensions.swift
//  UIScreen+Extensions
//
//  Created by Tanner on 8/28/21.
//

import SwiftUI


// an extension to support getting different screen dimensions
extension UIScreen {
    
    
    // MARK: Static Instance Members
    
    /// The width of the screen
    static let screenWidth = UIScreen.main.bounds.size.width
    
    /// The height of the screen
    static let screenHeight = UIScreen.main.bounds.size.height
    
    /// The size of the screen
    static let screenSize = UIScreen.main.bounds.size
}
