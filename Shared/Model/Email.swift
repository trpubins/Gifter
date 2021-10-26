//
//  Emails.swift
//  Shared (Model)
//
//  Created by Tanner on 10/24/21.
//

import Foundation

/**
 An enumeration for describing the state of an Email.
 
 Enumerations include: .Unsent, .Sent, & .Delivered
 */
enum EmailState: String, Codable {
    case Unsent
    case Sent
    case Delivered
}

/// A class to represent a gifter's email.
public class Email: NSObject, NSSecureCoding {
    
    
    // MARK: Properties
    
    /// Required to conform to NSSecureCoding
    public static var supportsSecureCoding = true
    
    /// The email address
    var address: String
    
    /// The state of the email
    var state: EmailState
    
    
    // MARK: Initializer
    
    /**
     Initializes an email object.
     
     - Parameters:
        - address: The email address - by default, an empty string
        - state: The state of the email - by default, .Unsent
     */
    init(address: String = "", state: EmailState = .Unsent) {
        self.address = address
        self.state = state
    }
    
    
    // MARK: NSCoding
    
    /**
     Encodes the class properties into binary form that can be persisted to CoreData model.
     
     - Parameters:
        - coder: The object that enables data encoding
     */
    public func encode(with coder: NSCoder) {
        // encode the email address
        coder.encode(self.address, forKey: "address")
        
        // encode the email state using the enum raw value (string)
        coder.encode(self.state.rawValue, forKey: "state")
    }
    
    /**
     Initializes the class by decoding the class properties from the CoreData model into Swift objects.
     
     - Parameters:
        - coder: The object that enables data decoding
     */
    public required convenience init?(coder: NSCoder) {
        // decode the email address as a string
        let addressDecoded = coder.decodeObject(forKey: "address") as! String
        
        // decode the email state enum into its raw value (string)
        let stateRawDecoded = coder.decodeObject(forKey: "state") as! String

        // initialize the data based on what comes from the decoded state enum
        if let stateDecoded = EmailState(rawValue: stateRawDecoded) {
            self.init(address: addressDecoded, state: stateDecoded)
        } else {
            self.init(address: addressDecoded)
        }
    }
    
}
