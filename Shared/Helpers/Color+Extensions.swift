//
//  Color+Extensions.swift
//  Shared (Helper)
//
//  Created by Tanner on 10/26/21.
//

import SwiftUI


extension Color {
    /// The application accent color
    static let Accent: Color = Color(UIColor.Accent)
    
    /// Simulates a disabled UI component
    static let Disabled: Color = Color(.systemGray4)  // systemGray4 is equivalent to the disabled gray
}

extension UIColor {
    /// The application accent color
    static let Accent: UIColor = UIColor(named: "AccentColor")!
}
