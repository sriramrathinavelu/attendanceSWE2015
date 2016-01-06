//
//  Sample-data.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/24/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import Foundation
import Alamofire

public class CourseManager {
    static let sharedInstance = CourseManager()
    
    var courseData = [Course]()
    
    var studentCourseData = [Course]()
    
    var allCourses = [String:String]()
    
    var classrooms = [Classroom]()
    
    private init() {} //This prevents others from using the default '()' initializer for this class.
}

class UserManager {
    static let sharedInstance = UserManager()

    var info = User()

    var toRegister = User()

    private init() {}
}


/*

{
    "course_name"       :   "Course2",
    "course_code"       :   "500",
    "course_section"    :   "2",
    "class_room"        :   "room2",
    "duration_start"    :   "2015-09-15T00:00:00",
    "duration_end"      :   "2016-01-04T00:00:00",
    "time_start"        :   "2015-01-01T20:00:00",
    "time_end"          :   "2015-01-01T22:00:00",
    "trimester"         :   "Fall 2015",
    "professor"         :   "professor@itu.edu",
    "day_of_week"       :   "0",
}

{
    "class_room": "r1",
    "course_code": "5",
    "course_key": "5-5",
    "course_name": "course3",
    "course_section": "5",
    "duration_end": "2015-01-04T00:00:00",
    "duration_start": "2015-09-15T00:00:00",
    "professor": "mahi@itu.edu",
    "specific_dates": [
        "2015-09-15T00:00:00",
        "2015-09-15T00:00:00",
        "2015-09-16T00:00:00"
    ],
    "time_end": "2015-01-01T22:00:00",
    "time_start": "2015-01-01T20:00:00",
    "trimester": "Fall 2016"
}
*/