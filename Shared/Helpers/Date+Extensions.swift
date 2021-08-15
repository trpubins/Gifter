//
//  Date+Extensions.swift
//  Shared (Helper)
//  https://stackoverflow.com/a/44009988
//
//  Created by Tanner on 8/8/21.
//

import Foundation

extension Date {
    
    // MARK: Static Properties
    
    /// The day before today
    static var yesterday: Date { return Date().dayBefore }
    
    /// The day after today
    static var tomorrow:  Date { return Date().dayAfter }
    
    
    // MARK: Object Properties
    
    /// The day before the Date itself
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    /// The day after the Date itself
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    /// The day of the week for the Date itself
    var dayOfWeek: String {
        let index = Calendar.current.component(.weekday, from: self)
        let dayOfWeekAbbrev = Calendar.current.weekdaySymbols[index - 1].prefix(3)  // the abbreviated form, first 3 characters representing the day of the week
        return String(dayOfWeekAbbrev)
    }
    
    /// Noontime of the Date itself
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    /// The month that the Date itself belongs
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    
    /// The year that the Date itself belongs
    var year: Int {
        return Calendar.current.component(.year,  from: self)
    }
    
    /// The number of days until the Date itself arrives.
    var daysUntil: Int {
        return Calendar(identifier: .gregorian).numberOfDaysBetween(Date(), and: self)
    }
    
    /// `true` if the Date is the last day of the month, `false` otherwise
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
}

extension Calendar {
    
    /**
     Returns the number of days between two dates.
     
     - Parameters:
        - from: The starting Date
        - to: The ending Date
     
     - Returns: The number of days between the provided Dates.
     */
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
    
}

