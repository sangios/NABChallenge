//
//  DateExtension.swift
//  Home_App
//
//  Created by MacbookPro on 4/27/18.
//  Copyright © 2018 HOMA. All rights reserved.
//

import Foundation

extension Date {
    func startOfDate(timezone: TimeZone = TimeZone.current) -> Date {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = timezone
        return calendar.startOfDay(for: self)
    }
    
    func startSecondsOfDate(timezone: TimeZone = TimeZone.current) -> Double {
        return self.startOfDate(timezone: timezone).timeIntervalSince1970
    }
}
