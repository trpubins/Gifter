//
//  Array+Extensions.swift
//  Shared (Helper)
//
//  Created by Tanner on 10/27/21.
//

import Foundation


extension Array {
    
    /**
     Finds the first index where an array element matches the specified criteria.
     
     - Parameters:
        - criteriaMatches: A boolean expression for the array elements to be compared
     
     - Returns: The first index if at least one element matches the criteria, or `nil` if no elements match the criteria.
     */
    func find(_ criteriaMatches: (Element) -> Bool) -> Int? {
        for (idx, element) in self.enumerated() {
            if criteriaMatches(element) {
                return idx
            }
        }
        return nil
    }
    
    /**
     Finds all the indices where array elements match the specified criteria.
     
     - Parameters:
        - criteriaMatches: A boolean expression for the array elements to be compared
     
     - Returns: An array of indices representing each element that matches the criteria, or an empty array if no elements match the criteria.
     */
    func findIndices(_ criteriaMatches: (Element) -> Bool) -> [Int] {
        var array: [Int] = []
        for (idx, element) in self.enumerated() {
            if criteriaMatches(element) {
                array.append(idx)
            }
        }
        return array
    }
    
}
