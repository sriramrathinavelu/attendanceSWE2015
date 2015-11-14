//
//  Course.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/24/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

//import Foundation
import UIKit

struct Course {
//    var dateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second, .Weekday] , fromDate: NSDate())
    
    var name: String
    var isWeekend: Bool = false
    var code: String
    var section: Int? = 1
    var room: String
    var durationStart: NSDate? = NSDate()
    var durationEnd: NSDate? = NSDate()
    var timeStart: NSDate? = NSDate()
    var timeEnd: NSDate? = NSDate()
    var dayOfWeek: String? = "Sunday"
    var trimester: String? = "Spring 2016"
    var professor: String? // email of professor
    
    init(
        name: String,
        isWeekend: Bool,
        code: String,
        room: String)
    {
        self.name = name
        self.code = code
        self.isWeekend = isWeekend
//        self.section = section
        self.room = room
//        self.durationStart = durationStart
//        self.durationEnd = durationEnd
//        self.timeStart = timingStart
//        self.timeEnd = timingEnd
//        self.dayOfWeek = dayOfWeek
//        self.trimester = trimester
    }
    
    func getCourseCode() -> String {
        
        return self.code + " " + String(self.section!)
        
    }
}