//
//  CommonRegex.swift
//  Shared (Helper)
//
//  Created by Tanner on 9/11/21.
//

import Foundation


/// Holds common regular expressions.
struct CommonRegex {
    
    /// A regular expression for email addresses
    static let email = "[A-Z0-9a-z.-_]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,3}"
    
    /// A regular expression for url web addresses
    static let url = buildUrlRegex()
    
    /// A regular expression for an empty string
    static let empty = "^$"
    
    /**
     Builds the url web address regular expression.
     
     - Returns: A string representing the url web address regular expression.
     */
    private static func buildUrlRegex() -> String {
        let head = "^(((http|https)://)?([w]{3}\\.)?)"  // make the http and www. portions optional
        let body = "(\\w|-)+(?<![w]{3})"  // req at least one word char and use a negative lookbehind to ensure that 'www' isn't repeated
        let tail = "\\.[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        return head+body+tail
    }
}
