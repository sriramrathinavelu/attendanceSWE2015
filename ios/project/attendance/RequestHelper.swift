//
//  RequestHelper.swift
//  attendance
//
//  Created by Yifeng on 11/30/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestHelper {
    
    enum RESTAction: String {
        case Login = "login"
        case Register = "register"
        case Professor = "professor"
        case Student = "student"
        case Classroom = "classrooms"
        case Course
//        case CourseWeekday = "weekdaycourse"
//        case CourseWeekend = "weekendcourse"
        case Voice = "voice"
    }
    
    let requestBase = "http://104.197.225.150:8000"
    
    /**
     Get Auth headers for updating actions
     
     - parameter: token string from logged in account
     - returns: request headers
     */
    func getAuthHeader(token: String) -> [String:String] {
        
        return [
            "Authorization": "Token \(token)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
    }

    /**
     Send a POST request
     - Parameters:
        - action: The action to perform (rest end point)
        - URL: URL for the request
        - parameters: data send with the request
        - headers: auth token, optional
        - failureCallback: callback function if request failed (request not getting through)
        - successCallback: callback function if request succeeded
     
     */
    func post(URL:String, parameters: [String: AnyObject]?, token:String? = nil, 
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
            
        var headers:[String:String] = [:]
        
        if let token = token {
            headers = self.getAuthHeader(token)
        }
    
        Alamofire.request(.POST, URL, parameters: parameters, headers: headers, encoding: .JSON)
            .responseJSON { res in
                debugPrint(res)
                
                let status = res.result
                
                switch status {
                    
                case .Success:  // Have a response
                    
                    successCallback(response: res)
                    
                case .Failure:
                    
                    if let failureCallback = failureCallback {
                    
                        failureCallback(response: res)

                    } else {
                        print("[POST] Request Failed but no callback found/")
                    }
                }
            }
    }
    
    /**
    Send a GET request
     
    - Parameters:
        - action: The action to perform (rest end point)
        - URL: URL for the request
        - token: auth token
        - failureCallback: callback function if request failed (request not getting through)
        - successCallback: callback function if request succeeded
    */
    func get(URL:String, token: String? = nil,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        
        var headers:[String:String] = [:]
        
        if let token = token {
            headers = self.getAuthHeader(token)
        }
        
        Alamofire.request(.GET, URL, headers: headers)
            .responseJSON { res in
                debugPrint(res)
                
                let status = res.result
                
                switch status {
                    
                case .Success:  // Have a response
                    
                    successCallback(response: res)
                    
                case .Failure:
                    
                    if let failureCallback = failureCallback {
                        
                        failureCallback(response: res)
                        
                    } else {
                        print("[GET] Request Failed but no callback found/")
                    }
                }
            }
    }
    
    
    // MARK: - User
    
    /**
    Login a user, get a token back
    
    */
    func loginUser(action: RESTAction, credentials: [String:String],
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        let URL = "\(self.requestBase)/\(action.rawValue)/"
    
        self.post(URL, parameters: credentials, token: nil, failureCallback: failureCallback, successCallback: successCallback)
    }
    
    /**
     Register a user
     
     -parameters:
        - action: The action to perform (rest end point)
        - credentials: email and password
        - failureCallback: callback function if request failed (request not getting through)
        - successCallback: callback function if request succeeded
     */
    func registerUser(action: RESTAction, credentials: [String:String],
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        
        let URL = "\(self.requestBase)/\(action.rawValue)/"
        
        self.post(URL, parameters: credentials, token: nil, failureCallback: failureCallback, successCallback: successCallback)
        
    }
    
    /**
     Send a POST request to update user info
     
     - parameters:
        - action: The action to perform (rest end point)
        - token: auth token for any updating actions
        - parameters: data send with the request
        - email: (optional) if not first time registration, use email to update partial information
        - failureCallback: callback function if request failed (request not getting through)
        - successCallback: callback function if request succeeded

     */
    func updateUser(action: RESTAction, token:String, parameters: [String: AnyObject]?, email: String? = nil,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        var URL = ""
        
        if let email = email {
            URL = "\(self.requestBase)/\(action.rawValue)/\(email)/"
        } else {
            URL = "\(self.requestBase)/\(action.rawValue)/"
        }
        
        print("parameters - updateUser > \(parameters)")
        
        self.post(URL, parameters: parameters, token: token, failureCallback: failureCallback, successCallback: successCallback)
            
    }
    
    func getUserData(action: RESTAction, token:String, email: String,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        
        let URL = "\(self.requestBase)/\(action.rawValue)/\(email)/";
        
        self.get(URL, token: token, failureCallback: failureCallback, successCallback: successCallback)
        
    }
    
    // MARK: - Student
    
    func getUserAllCourses(action: RESTAction, token:String, email: String,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        
        let URL = "\(self.requestBase)/\(action.rawValue)/\(email)/courses/";
        
        log.info("token \(token)")
        
        self.get(URL, token: token, failureCallback: failureCallback, successCallback: successCallback)
    }
    
    // MARK: - Course
    
    func getCourses(token: String,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        let URL = "\(self.requestBase)/courses/"
        
        self.get(URL, token: token, failureCallback: failureCallback, successCallback: successCallback)
    }
    
    func getCourseType(courseKey: String, token: String, successCallback: (response: Response<AnyObject, NSError>) -> Void) {
        
        let URL = "\(self.requestBase)/coursetype/\(courseKey)/"
        
        self.get(URL, token: token, failureCallback: { (response) -> Void in
            log.error("getCourseType: connection to the server failed")
            }, successCallback: successCallback)
    }
    
    func getCourseData(courseType: String, courseKey: String, token: String, successCallback: (response: Response<AnyObject, NSError>) -> Void) {
        
        var URL = ""
        
        switch courseType {
            
            case "weekend":
                
                URL = "\(self.requestBase)/weekendcourse/\(courseKey)/"
            
            case "weekday":
                
                URL = "\(self.requestBase)/weekdaycourse/\(courseKey)/"
            
        default:
            log.error("Wrong parameter courseType - aborted")
            return
        }
        
        self.get(URL, token: token, failureCallback: { (response) -> Void in
            log.error("getCourseData: connection to the server failed")
            }, successCallback: successCallback)
    }
    
    func getCourse(key: String, token: String,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        
        self.getCourseType(key, token: token) { (response) -> Void in
            
            if let res = response.response {
                
                let json = JSON(data: response.data!)
                
                switch res.statusCode {
                case 200:
                    
                    // TODO: change code style, snake_case & lowercase
                    let type = json["courseType"].stringValue.lowercaseString
                    
                    switch type {
                        case "weekend", "weekday":
                        
                            self.getCourseData(type, courseKey: key, token: token, successCallback: successCallback)
                        
                    default:
                        log.error("Wrong course type: \(type) returned from server - aborted")
                        return
                    }
                    
                default:
                    log.warning("Code \(res.statusCode) not handled")
                }
            }
        }
    }
    
    func updateCourse(action: RESTAction, token:String, isWeekend: Bool, courseData: [String: AnyObject],
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        var URL = ""
        
        if isWeekend {
            URL = "\(self.requestBase)/weekendcourse/"
        } else {
            URL = "\(self.requestBase)/weekdaycourse/"
        }
        
        debugPrint(courseData)
        debugPrint(URL)
        
        self.post(URL, parameters: courseData, token: token, failureCallback: failureCallback, successCallback: successCallback)
    }
    
    // MARK: - Classroom
    
    func getClassrooms(failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        let URL = "\(self.requestBase)/classrooms/"
        
        guard let token = UserManager.sharedInstance.info.token else {
            
            Utils.alert("Error", message: "No user token found, get-classrooms aborted")
            
            return
        }
        
        self.get(URL, token: token, failureCallback: failureCallback, successCallback: successCallback)
    }
    
    // MARK: - Voice
    
    func uploadVoiceSample(fileURL: NSURL, token: String, fileName: String,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
 
        let headers = self.getAuthHeader(token)
        
        let email = UserManager.sharedInstance.info.email
        
        let URL = "\(self.requestBase)/voice/\(email)/\(fileName)/"
        
        Alamofire.upload(.PUT, URL, headers: headers, file: fileURL)
            .progress({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                
                print(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
            
            }).responseJSON { res in
                
                debugPrint(res)
                
                let status = res.result
                
                switch status {
                    
                case .Success:  // Have a response
                    
                    successCallback(response: res)
                    
                case .Failure:
                    
                    if let failureCallback = failureCallback {
                        
                        failureCallback(response: res)
                        
                    } else {
                        print("[PUT] Upload Request Failed but no callback found/")
                    }
                }

            }
    }
    
    func authVoiceSample(fileURL: NSURL, token: String, courseKey: String, fileName: String,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        // from server { "score": "0.655231" }
        
        
        
        let headers = self.getAuthHeader(token)
        
        let email = UserManager.sharedInstance.info.email
        
        let URL = "\(self.requestBase)/attendance/\(email)/\(courseKey)/\(fileName)/"
        
        Alamofire.upload(.PUT, URL, headers: headers, file: fileURL)
            .progress({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                
                print(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
                
            }).responseJSON { res in
                
                debugPrint(res)
                
                let status = res.result
                
                switch status {
                    
                case .Success:  // Have a response
                    
                    successCallback(response: res)
                    
                case .Failure:
                    
                    if let failureCallback = failureCallback {
                        
                        failureCallback(response: res)
                        
                    } else {
                        print("[PUT] Upload Request Failed but no callback found/")
                    }
                }
                
        }
    }
    
    // MARK: - Manual Attendance
    func updateManualAttendance(email: String, courseKey: String, dateTime: String,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        guard let token = UserManager.sharedInstance.info.token else {
            Utils.alert("Update", message: "Token not set, abort updating attendance")
            return
        }
        
        let URL = "\(self.requestBase)/attendance/manual/"
        
        let params = [
            "email": email,
            "course_key": courseKey,
            "datetime": dateTime
        ]
        
        self.post(URL, parameters: params, token: token, failureCallback: failureCallback, successCallback: successCallback)

    }
    
    // MARK: - Report
    func getUserReport(courseKey: String, email: String,
        failureCallback: ((response: Response<AnyObject, NSError>) -> Void)? = nil,
        successCallback: (response: Response<AnyObject, NSError>) -> Void)
    {
        // result from server
            
        guard let token = UserManager.sharedInstance.info.token else {
            
            log.error("Token missing. Cannot make request.")
            return
        }
        
        let URL = "\(self.requestBase)/report/\(email)/\(courseKey)"
        
        self.get(URL, token: token, failureCallback: failureCallback, successCallback: successCallback)
        
    }
}




/*:
## status codes
- 400: Bad Request
- 401: Unauthorized Request
- 403: Forbidden Requests

- 200: Success
- 201: Created
- 202: Accepted


## Users

- /register/ 201 POST {email, pw} message
- /login/ 200 POST {email, pw} token

### Professor/Student

- /professor/<email>/ POST   {email,fn, ln} {email,fn, ln}
- /professor/<email>/ GET 200 nil {email,fn, ln}
- /professor/<email>/ POST 201 {email,(fn, ln)} {email,fn, ln}
- /professor/<email>/courses GET 200 [{course info},{}...]

- /student/<email_id>/ GET 200 nil {courses, email, fn, gender, ln}

## Classroom

- /classrooms/ GET 200 [ {code, room name}, {}...]


## Course
### weekday course

````
{
"class_room": "room2",
"course_code": "500",
"course_key": "500-2",
"course_name": "Course2",
"course_section": "2",
"day_of_week": 0,
"duration_end": "2016-01-04T00:00:00",
"duration_start": "2015-09-15T00:00:00",
"professor": "professor@itu.edu",
"time_end": "2015-01-01T22:00:00",
"time_start": "2015-01-01T20:00:00",
"trimester": "Fall 2015"
}
````

- /weekdaycourse/ POST 201 {course data} {course data}
- /weekdaycourse/<course_key>/ GET 200 nil {course data}

### weekend course

````
{
"class_room": "room1",
"course_code": "501",
"course_key": "501-1",
"course_name": "Course3",
"course_section": "1",
"duration_end": "2016-01-04T00:00:00Z",
"duration_start": "2015-09-15T00:00:00Z",
"professor": "professor@itu.edu",
"specific_dates": [
"2015-09-15T00:00:00Z",
"2015-10-03T00:00:00Z",
"2015-11-18T00:00:00Z"
],
"time_end": "2015-01-01T22:00:00Z",
"time_start": "2015-01-01T20:00:00Z",
"trimester": "Fall 2015"
}
````

- /weekendcourse/ POST 201 {course info} {course info}
- /weekendcourse/<course_key>/ GET 200 nil {course info}

## Voice

- /voice/<email_id>/<filename>/ PUT 202 fileOfVoice message
    - 406 file exists


*/
