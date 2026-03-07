//
//  Date+EXT.swift
//  AIChat
//
//  Created by Aman on 07/03/26.
//
import Foundation

extension Date {
    func addTimeInterval(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        let dayInterval = TimeInterval(days * 24 * 60 * 60)
        let hourInterval = TimeInterval(hours * 60 * 60)
        let minuteInterval = TimeInterval(minutes * 60)
        let totalInterval = dayInterval + hourInterval + minuteInterval
        
        return addingTimeInterval(TimeInterval(totalInterval))
    }
}
