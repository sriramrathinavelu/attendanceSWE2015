//
//  StudentAddCourseViewController.swift
//  attendance
//
//  Created by Yifeng on 11/29/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import XCGLogger
import SwiftyJSON

class StudentAddCourseViewController: UIViewController,
    UIPickerViewDataSource,
    UIPickerViewDelegate {
    
    let requester = RequestHelper()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var courseList = ["Select a course" : "Your Course Name"]
    var coursesOptions = ["Select a course"]
    var selectedCourseIndex = 0
    
    
    @IBOutlet weak var coursePicker: UIPickerView!
    @IBOutlet weak var selectedCourse: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coursePicker.dataSource = self
        coursePicker.delegate = self
        coursePicker.selectRow(0, inComponent: 0, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        updateCourseList()
    }
    
    override func viewDidAppear(animated: Bool) {
    
    }
    
    func updateCourseList() {
        getAllCourses { () -> Void in
            
            self.coursesOptions = [String](self.courseList.keys)
            
            let allCourses = CourseManager.sharedInstance.allCourses.keys
            let currentCourses = CourseManager.sharedInstance.studentCourseData.map({ $0.getCourseKey() })
            
            let set1 = Set(allCourses), set2 = Set(currentCourses)
            
            self.coursesOptions = Array(set1.subtract(set2))

            if self.coursesOptions.count > 1 {
                self.coursesOptions = self.coursesOptions.filter({ $0 != "Select a course" })
            } else {
                self.selectedCourse.text = "Your course name"
            }
            
            self.coursesOptions = self.coursesOptions.sort()
            
            let selectedKey = self.coursesOptions[self.selectedCourseIndex]
            // text field
            if let courseName = self.courseList[selectedKey] {
                self.selectedCourse.text = courseName
            }
            
            self.coursePicker.reloadAllComponents()
        }
    }
    
    func getAllCourses(callback: () -> Void ) {
        
        guard let token = UserManager.sharedInstance.info.token else {
            log.error("Token not set, abort get all courses")
            return
        }
        
        requester.getCourses(token) { (response) -> Void in
            
            if let res = response.response {
                
                let json = JSON(data: response.data!)
                
                switch res.statusCode {
                case 200:
                    // json is an array
                    for ( _ , object) in json {
                        
                        self.courseList[object["key"].string!] = object["name"].string!
                    }
                    
                    CourseManager.sharedInstance.allCourses = self.courseList
                    log.info("All courses set")
                    
                    callback()

                default:
                    log.error("\(res.statusCode) not handled. - get courses")
                    
                    callback()
                    
                }
            }
        }
        // TODO: prepare course information after course added
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Picker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coursesOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coursesOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if courseList[coursesOptions[row]] != nil {
            selectedCourse.text = courseList[coursesOptions[row]]
        } else {
            selectedCourse.text = "Your course name"
        }
        
        selectedCourseIndex = row
        
    }

    
    @IBAction func addCourseButtonPressed(sender: AnyObject) {
        
        //        Utils.alert("Add course", message: "selected > \(coursesOptions[selectedCourseIndex])")
        
        // TODO: check if the course key exists
        // TODO: update the course key to the student account
        // TODO: fetch the course info and save it to -> CourseManager.sharedInstance.studentCourseData
        
        
        Utils.beginHUD()
        
        let allCourses = CourseManager.sharedInstance.allCourses.keys // [key:name]
        var currentCourses = CourseManager.sharedInstance.studentCourseData.map{ $0.getCourseKey() } // [key]
        let selectedKey = coursesOptions[selectedCourseIndex]
        
        if selectedKey == "Select a course" {
            Utils.endHUD(false)
            Utils.alert("Alert", message: "Please select a course")
            return
        }
        
        if currentCourses.indexOf({ $0 == selectedKey }) != nil {
            Utils.endHUD(false)
            Utils.alert("Cannot add course", message: "Course already in your list")
        } else {
            
            guard let token = UserManager.sharedInstance.info.token else {
                Utils.endHUD(false)
                log.error("Token not set, abort adding course")
                return
            }
            
            let email = UserManager.sharedInstance.info.email
            
            var info = [String:AnyObject]()
            
            log.info("old student courses: \(currentCourses)")
            
            currentCourses.append(selectedKey)
            
            info["courses"] = currentCourses
            
            log.info("new student courses: \(info)")
            
            self.requester.updateUser(.Student, token: token, parameters: info, email: email, failureCallback: { (response) -> Void in
                log.error("addCourse student - failed to connect")
                }) { (response) -> Void in
                    
                    let json = JSON(data: response.data!)
                    switch response.response!.statusCode {
                    case 201: // User updated
                        
                        let newCourses = json["courses"].arrayValue.map({ $0.stringValue })
                        
                        // get course data
                        self.requester.getCourse(selectedKey, token: token) { (response) -> Void in
                            
                            if let res = response.response {
                                
                                let json = JSON(data: response.data!)
                                
                                switch res.statusCode {
                                case 200:
                                    
                                    let course = Course.JSONtoCourse(json)
                                    
                                    log.info("Course >\n\(course)")
                                    
                                    CourseManager.sharedInstance.studentCourseData.append(course)
                                    currentCourses = newCourses
                                    
                                    // reload option list
                                    let set1 = Set(allCourses), set2 = Set(currentCourses)
                                    
                                    self.coursesOptions = Array(set1.subtract(set2))
                                    
                                    
                                    if self.coursesOptions.count > 1 {
                                        self.selectedCourse.text = self.courseList[selectedKey]
                                        self.coursesOptions = self.coursesOptions.filter({ $0 != "Select a course" })
                                    } else {
                                        self.selectedCourse.text = "Your course name"
                                    }
                                    
                                    self.coursePicker.reloadAllComponents()
                                    
                                    log.info("New courseOptions: \n\(self.coursesOptions)")
                                    Utils.endHUD()
                                default:
                                    Utils.endHUD(false)
                                    log.warning("Code \(res.statusCode) not handled")
                                    return
                                }
                            }
                        }
                        
                        
                    default:
                        Utils.endHUD(false)
                        print(response.response!.statusCode, "not handled. - addCourse student")
                    }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
