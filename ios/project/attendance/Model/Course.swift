//
//  Course.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/24/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

//import Foundation
import UIKit
import SwiftyJSON

struct Course {
    var isWeekend: Bool = false
    var name: String = ""
    var code: String = ""
    var section: String = "1"
    var room: String = ""
    var durationStart: String = NSDate().stringFromDate(NSDate(), format: Config.dateFormatInServer)
    var durationEnd: String = NSDate().stringFromDate(NSDate(), format: Config.dateFormatInServer)
    var timeStart: String = NSDate().stringFromDate(NSDate(), format: Config.dateFormatInServer)
    var timeEnd: String = NSDate().stringFromDate(NSDate(), format: Config.dateFormatInServer)
    var trimester: String = "Spring 2016"
    var dayOfWeek: Int? = nil
    var selectedDates:[NSDate]? = nil
    var professor: String = ""
    var courseKey: String {
        get {
            return "\(code)-\(section)"
        }
        set {
            var parts = newValue.componentsSeparatedByString("-")
            code = parts[0]
            section = parts[1]
        }
    }
    
    init(){}

    init(isWeekend: Bool,
        name: String,
        code: String,
        section: String,
        room: String,
        durationStart: String,
        durationEnd: String,
        timeStart: String,
        timeEnd: String,
        trimester: String,
        professor: String)
    {
        self.name = name
        self.code = code
        self.isWeekend = isWeekend
        self.section = section
        self.room = room
        self.durationStart = durationStart
        self.durationEnd = durationEnd
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.trimester = trimester
        self.professor = professor
    }

    init(isWeekend: Bool,
        name: String,
        code: String,
        section: String,
        room: String,
        durationStart: String,
        durationEnd: String,
        timeStart: String,
        timeEnd: String,
        trimester: String,
        professor: String,
        dayOfWeek: Int)
    {
        self.init(
            isWeekend: isWeekend,
            name: name,
            code: code,
            section: section,
            room: room,
            durationStart: durationStart,
            durationEnd: durationEnd,
            timeStart: timeStart,
            timeEnd: timeEnd,
            trimester: trimester,
            professor: professor
        )

        self.dayOfWeek = dayOfWeek
    }

    init(isWeekend: Bool,
        name: String,
        code: String,
        section: String,
        room: String,
        durationStart: String,
        durationEnd: String,
        timeStart: String,
        timeEnd: String,
        trimester: String,
        professor: String,
        selectedDates: [NSDate])
    {
        self.init(
            isWeekend: isWeekend,
            name: name,
            code: code,
            section: section,
            room: room,
            durationStart: durationStart,
            durationEnd: durationEnd,
            timeStart: timeStart,
            timeEnd: timeEnd,
            trimester: trimester,
            professor: professor
        )

        self.selectedDates = selectedDates
    }

    func getCourseKey() -> String {

        return self.code + "-" + self.section

    }
    
    func getStringSelectedDates() -> [String] {

        let stringDates = self.selectedDates?.map({ date in
            NSDate().stringFromDate(date, format: Config.dateFormatInServer)
        })
        
        return stringDates ?? []
        
    }
    
    func toJSON() -> [String:AnyObject] {
        
        if self.isWeekend { // weekend course
            return [
                "class_room": self.room,
                "course_code": self.code,
                "course_key": self.getCourseKey(),
                "course_name": self.name,
                "course_section": self.section,
                "duration_end": self.durationEnd,
                "duration_start": self.durationStart,
                "professor": self.professor,
                "specific_dates": self.getStringSelectedDates(),
                "time_end": self.timeEnd,
                "time_start": self.timeStart,
                "trimester": self.trimester
            ]
        } else { // weekday course
            return [
                "class_room": self.room,
                "course_code": self.code,
                "course_key": self.getCourseKey(),
                "course_name": self.name,
                "course_section": self.section,
                "day_of_week": self.dayOfWeek!,
                "time_end": self.timeEnd,
                "time_start": self.timeStart,
                "duration_end": self.durationEnd,
                "duration_start": self.durationStart,
                "professor": self.professor,
                "trimester": self.trimester
             ]
        }
    }
    
    static func JSONtoCourse(json: JSON, isWeekend: Bool? = nil) -> Course {
        /* weekend
        "course_section" : "1",
        "time_start" : "2016-01-04T18:00:00",
        "duration_start" : "2015-12-01T00:00:00",
        "class_room" : "class-1",
        "trimester" : "Falls 2015",
        "course_key" : "800-1",
        "course_name" : "qtCourse-2",
        "specific_dates" : [
        "2015-12-05T00:00:00",
        "2015-12-17T00:00:00",
        "2015-12-19T00:00:00",
        "2015-12-20T00:00:00",
        "2016-01-02T00:00:00",
        "2016-01-03T00:00:00"
        ],
        "duration_end" : "2016-01-04T00:00:00",
        "time_end" : "2016-01-04T20:00:00",
        "professor" : "qtprof@itu.edu",
        "course_code" : "800"
        
        weekday
        
        "course_section" : "1",
        "day_of_week" : 3,
        "time_start" : "2016-01-04T18:00:00",
        "duration_start" : "2015-12-01T00:00:00",
        "class_room" : "class-1",
        "trimester" : "Falls 2015",
        "course_key" : "700-1",
        "course_name" : "qtCourse-1",
        "duration_end" : "2016-01-04T00:00:00",
        "time_end" : "2016-01-04T20:00:00",
        "professor" : "qtprof@itu.edu",
        "course_code" : "700"
        */
        
        var isWeekendFromJson = false
        
        let name = json["course_name"].stringValue
        let code = json["course_code"].stringValue
        let section = json["course_section"].stringValue
        let trimester = json["trimester"].stringValue
        let room = json["class_room"].stringValue
        let timeStart = json["time_start"].stringValue
        let timeEnd = json["time_end"].stringValue
        let durationStart = json["duration_start"].stringValue
        let durationEnd = json["duration_end"].stringValue
        let professor = json["professor"].stringValue
        let dayOfWeek = json["day_of_week"].int
        let selectedDates = json["specific_dates"].arrayValue
        
        var newCourse = Course(isWeekend: false, name: name, code: code, section: section, room: room, durationStart: durationStart, durationEnd: durationEnd, timeStart: timeStart, timeEnd: timeEnd, trimester: trimester, professor: professor)
        
        if let isWeekend = isWeekend {
            
            isWeekendFromJson = isWeekend
            
        }
        
        if let dayOfWeek = dayOfWeek where selectedDates.isEmpty {
            
            isWeekendFromJson = false
            newCourse.dayOfWeek = dayOfWeek
            
        } else if !selectedDates.isEmpty {
            
            isWeekendFromJson = true
            
            newCourse.selectedDates = selectedDates.map({ NSDate().dateFromString($0.stringValue, format: Config.dateFormatInServer) })
            
        } else {
            log.info("Day of week and Selected Dates are both empty. Cannot tell weekend or weekday. Default to false.")
        }
        
        newCourse.isWeekend = isWeekendFromJson
        
        return newCourse
    }
}