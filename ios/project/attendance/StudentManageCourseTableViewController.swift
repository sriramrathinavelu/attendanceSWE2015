//
//  StudentManageCourseTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/16/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftyJSON

class StudentManageCourseTableViewController: UITableViewController {

    let cellIdentifier = "classCell"
    let requester = RequestHelper()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadData()
    }
    
    func reloadData() {
        updateCourseList()
    }
    
    func updateCourseList() {
        
        guard let email = self.userDefaults.stringForKey(UDKeys.uname) else {
            log.warning("User email is empty, user info updating aborted.")
            return
        }
        
        if let token = UserManager.sharedInstance.info.token {
        
            self.requester.getUserAllCourses(.Student, token: token, email: email) { (response) -> Void in
                
                let json = JSON(data: response.data!)
                
                switch response.response!.statusCode {
                case 200:
                    
                    let courses = json.arrayValue.map({ $0 })
                    
                    log.info("all course data \(courses)")
                    
                    CourseManager.sharedInstance.studentCourseData = courses.map({ Course.JSONtoCourse($0) })
                    
                    self.tableView.reloadData()
                    
                default:
                    log.warning("Code \(response.response!.statusCode) not handled.")
                }
            }
        } else {
            log.error("Token not set, abort get all courses")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if CourseManager.sharedInstance.studentCourseData.isEmpty {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            noDataLabel.text = "You have no course"
            noDataLabel.textColor = UIColor.blackColor()
            noDataLabel.textAlignment = NSTextAlignment.Center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
        } else {
            
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            
        }
        
        return 1

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return CourseManager.sharedInstance.studentCourseData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ClassCell

        let course = CourseManager.sharedInstance.studentCourseData[indexPath.row] as Course
        
        cell.course = course

        return cell
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            
//            
//            
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") {
            action, index in
            
            // Delete the row from the data source
            let message = "Do you want to delete this course?"
            
            Utils.alert("Warning", message: message, okAction: nil, cancelAction: "Cancel", deleteAction: "Delete") { (action) -> Void in
                
                Utils.beginHUD()
                self.tableView.beginUpdates()
                
                let currentCourses = CourseManager.sharedInstance.studentCourseData.map({ $0.getCourseKey() })
                
                let courseToDelete = CourseManager.sharedInstance.studentCourseData[indexPath.row]
                
                CourseManager.sharedInstance.studentCourseData.removeAtIndex(indexPath.row)
                
                guard let token = UserManager.sharedInstance.info.token else {
                    
                    log.error("Token not set. Unable to delete")
                    return
                }
                
                let email = UserManager.sharedInstance.info.email
                
                if email.isEmpty {
                    
                    log.error("Email not set. Unable to delete")
                    return
                }
                
                let newCourses = currentCourses.filter({ $0 != courseToDelete.getCourseKey() })
                
                var info = [String:AnyObject]()
                info["courses"] = newCourses
                
                self.requester.updateUser(.Student, token: token, parameters: info, email: email, failureCallback: { (response) -> Void in
                    log.error("addCourse student - failed to connect")
                    }, successCallback: { (response) -> Void in
                        
                    Utils.endHUD()
                    Utils.alert("Delete course", message: "Course deleted.")
                        
                })
                
                // TODO: send delete request to the server
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                self.tableView.endUpdates()
                // self.reloadData()
            }
        }
        
        let checkIn = UITableViewRowAction(style: .Normal, title: "Check In") { action, index in
            
            self.performSegueWithIdentifier("fromStudentManageToCheckIn", sender: indexPath)
            
        }
        checkIn.backgroundColor = UIColor.orangeColor()
        
        return [delete, checkIn]
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        
        if CourseManager.sharedInstance.studentCourseData.count >= 4 {
            Utils.alert("Classes", message: "You have \(CourseManager.sharedInstance.studentCourseData.count) classes now")
        } else {
            // self.performSegueWithIdentifier("studentAddCourse", sender: self)
        }
        
        self.performSegueWithIdentifier("studentAddCourse", sender: self)
    }
    
    @IBAction func unwindToStudentManageCourse(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "studentShowCourseDetail" {
            
            let svc = segue.destinationViewController as! ClassDetailTableViewController
            let path = self.tableView.indexPathForSelectedRow!
            svc.selectedCourse = CourseManager.sharedInstance.studentCourseData[path.row]
        }
        
        if segue.identifier == "fromStudentManageToCheckIn" {
            
            // destination
            let svc = segue.destinationViewController as! StudentCheckInViewController
            
            let indexPath = sender!
            svc.selectedCourse = CourseManager.sharedInstance.studentCourseData[indexPath.row]
        }
    }
    

}
