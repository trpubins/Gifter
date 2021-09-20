//
//  WishList.swift
//  WishList
//
//  Created by Tanner on 9/14/21.
//

import Foundation


/// A structure for a gifter's wish list - conforms to Identifiable since we need to be able to uniquely identify each wish list in the UI form.
struct WishList: Identifiable {
    
    
    // MARK: Properties
    
    /// The id that uniquely identifies the wish list
    public let id: UUID
    
    /// The wish list url address
    public var url: String
    
    /// The wish list number - for keeping the order of the wish lists
    private var number: Int
    
    /// The total number of wish list instances
    private static var count = 0
    
    
    // MARK: Initializer
    
    /**
     Initializes the wish list data.
     
     - Parameters:
        - url: The wish list url address - by default, an empty string
     */
    init(with url: String = "") {
        self.id = UUID()
        self.url = url
        
        WishList.count += 1
        self.number = WishList.count
    }
    
}

extension WishList: Comparable {
    
    
    // MARK: - Conform to Comparable
    
    // equatability is based on the WishList's url
    public static func == (lhs: WishList, rhs: WishList) -> Bool {
        return lhs.url == rhs.url
    }
    
    // order is based on a WishList's number
    public static func < (lhs: WishList, rhs: WishList) -> Bool {
        return lhs.number < rhs.number
    }
    
}
