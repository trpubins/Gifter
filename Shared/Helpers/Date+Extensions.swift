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
    
    /// Noontime of the Date itself
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    /// The month that the Date itself belongs
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    
    /// `true` if the Date is the last day of the month, `false` otherwise
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
}
