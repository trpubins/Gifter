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
        
        // set up an id array and eligibility array for quick search operations
        /// An array of gifter ids found in the gift exchange being matched. Array indices are synonomous with the gift matrix rows, which have a one-to-one mapping to gifters.
        var idArr: [UUID] = []
        /// An array of elements describing the eligibility of the gifters. Array indices are synonomous with the gift matrix rows, which have a one-to-one mapping to gifters.
        var eligibilityArr: [Eligible] = []
        for gifter in gifters {
            idArr.append(gifter.id)
            eligibilityArr.append(Eligible.Yes)
        }
        
        // write ineligible recipients into the matrix
        for i in 0..<matrix.rows {
            
            let gifter = gifters[i]
            // clear each gifter recipient
            gifter.recipientId = nil
            
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
            
            // if random element can be found, then recipient has been identified
            if let recipientIdx = potentialRecipientIdcs.randomElement() {
                // recipient has been identified so mark as ineligible
                eligibilityArr[recipientIdx] = Eligible.No
                
                // assign the recipient to the gifter
                let gifter = gifters[row]
                gifter.recipientId = idArr[recipientIdx]
                rowsMatched.append(row)
                matrix[row, recipientIdx] = gifters.count
                
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
            }
            // a gifter could not be matched so attempt to reshuffle gifters
            else {
                // retrieve the gifter who could not match
                let gifterUnmatched = gifters[row]
                
                // attempt a reshuffle
                var rowsWithMaxSum = matrix.rowsSortedByMaxSum()
                
                // loop through all the rows in the stack while the unmatched gifter has no recipient
                while !rowsWithMaxSum.isEmpty && gifterUnmatched.recipientId == nil {
                    /// The row with the max sum (gifter with most eligible recipients)
                    let rMax = rowsWithMaxSum.pop()!
                    let gifterMax = gifters[rMax]
                    
                    // the gifter at 'rMax' needs to have at least one other eligible potential recipient to keep trying
                    if matrix.sumColumns(at: rMax) <= gifters.count {
                        return false
                    }
                    
                    // confirm that gifter at 'rMax' isn't gifting someone that gifter at 'row' is restricted from gifting
                    if gifterMax.recipientId == gifterUnmatched.id || gifterUnmatched.restrictedIds.contains(gifterMax.recipientId!)  {
                        // reshuffling with this gifter won't work, move on to next
                        continue
                    }
                    
                    // see if there is a different eligible recipeint that we can switch this gifter to
                    let otherEligibleIdcs = matrix[rMax].findIndices({ $0 == Eligible.Yes.rawValue })
                    for otherIdx in otherEligibleIdcs {
                        // see if the other potential recipients are still eligible (have not been matched as a recipient)
                        if eligibilityArr[otherIdx] == Eligible.Yes {
                            // the other potential recipient is valid so reassign recipients
                            gifterUnmatched.recipientId = gifterMax.recipientId
                            rowsMatched.append(row)
                            if let recipientIdx = matrix[rMax].find({ $0 == gifters.count }) {
                                matrix[rMax, recipientIdx] = 0
                                matrix[row, recipientIdx] = gifters.count
                            }
                            
                            gifterMax.recipientId = idArr[otherIdx]
                            matrix[rMax, otherIdx] = gifters.count
                            
                            // reset the email status of the gifters following shuffle
                            gifterUnmatched.resetEmailState()
                            gifterMax.resetEmailState()
                            break
                        }
                    }
                }
                
                // matching has failed if the unmatched gifter is still unmatched
                if gifterUnmatched.recipientId == nil {
                    return false
                }
                
            }
            n += 1  // increment the counter
        }
        // all gifters successfully matched
        return true
    }
    
    /**
     Retrieves the state of the gifting matrix.
     
     - Returns: The state of the matrix as a string.
     */
    func getState() -> String {
        var str = ""
        let gifters = giftExchange.gifters
        
        for i in 0..<matrix.rows {
            let gifter = gifters[i]
            str += "\(gifter.name): "
            for j in 0..<matrix.columns {
                str += "\(matrix[i, j]) "
            }
            str += "\n"
        }
        
        return str
    }
    
}
