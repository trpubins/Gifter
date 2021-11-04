//
//  GiftingMatrix.swift
//  Shared (Model)
//
//  Created by Tanner on 10/27/21.
//

import Foundation


/**
 An enum for describing the eligibility of a gifter as a potential recipient.

 Enumerations include: .Yes = `1` & .No = `0`
 */
enum Eligible: Int {
    case Yes = 1
    case No = 0
}

/// Manages a matrix to facilitate matching gifters in a gift exchange.
struct GiftingMatrix {
    
    
    // MARK: Properties
    
    /// The 2-dimensional (g x g) gifting matrix where g represents the number of gifters
    var matrix: Matrix<Int>
    
    /// The gift exchange that requires matching
    var giftExchange: GiftExchange
    
    
    // MARK: Initializer
    
    /**
     Initializes a gifting matrix with a gift exchange.
     
     - Parameters:
        - giftExchange: The gift exchange that requires matching
     */
    init(giftExchange: GiftExchange) {
        let nGifters = giftExchange.gifters.count
        // matrix is initialized with all eligible recipients
        self.matrix = Matrix(rows: nGifters, columns: nGifters, defaultValue: Eligible.Yes.rawValue)
        self.giftExchange = giftExchange
    }
    
    
    // MARK: Object Methods
    
    /**
     Attempts to match the gifters in the gift exchange.
     
     - Returns: `true` if matches were successfully made for all gifters in the gift exchange, `false` otherwise.
     */
    mutating func match() -> Bool {
        let gifters = self.giftExchange.gifters
        
        // set up an id array for quick search operations
        var idArr: [UUID] = []
        for gifter in gifters {
            idArr.append(gifter.id)
        }
        
        // write ineligible recipients into the matrix
        for i in 0..<matrix.rows {
            let gifter = gifters[i]
            for j in 0..<matrix.columns {
                // a gifter cannot gift themselves or anyone on their restricted list
                if gifter.id == idArr[j] || gifter.restrictedIds.contains(idArr[j]) {
                    matrix[i, j] = Eligible.No.rawValue
                }
            }
        }
        
        // counter
        var n = 0
        // matrix rows (representing gifters) that have already been matched to a recipient
        var rowsMatched: [Int] = []
        
        // assign gifters using the gifting matrix
        while n < gifters.count {
            // identify the gifter with the least eligible recipients
            let row = matrix.rowWithMinSum(rowExceptions: rowsMatched)
            
            let potentialRecipientIdcs: [Int] = matrix[row].findIndices({ $0 == Eligible.Yes.rawValue })
            guard let recipientIdx = potentialRecipientIdcs.randomElement() else {
                // at least one gifter could not be matched
                return false
            }
            
            // assign the recipient to the gifter
            let gifter = gifters[row]
            gifter.recipientId = idArr[recipientIdx]
            rowsMatched.append(row)
            
            // reset the email status of the gifter following match
            gifter.resetEmailState()
            
            // sort rows (gifters) matched in descending order to create a stack
            var sortedRowsMatched = rowsMatched.sorted(by: { $0 > $1 })
            var rowMatched = sortedRowsMatched.popLast()
            
            // clear the recipient from all other gifters in the gifting matrix
            for i in 0..<matrix.rows {
                // look to see if row representing a gifter has already been matched
                if i == rowMatched {
                    rowMatched = sortedRowsMatched.popLast()
                    continue
                }
                // make the recipient ineligible for gifters who have not yet matched
                else {
                    matrix[i, recipientIdx] = Eligible.No.rawValue
                }
            }
            n += 1  // increment the counter
        }
        
        // all gifters successfully matched
        return true
    }
    
}
