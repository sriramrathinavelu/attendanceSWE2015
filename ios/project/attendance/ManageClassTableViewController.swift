//
//  ManageClassTableViewController.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/17/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftyJSON

class ManageClassTableViewController: UITableViewController {
    
    let cellIdentifier = "classCell"
    let requester = RequestHelper()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - actions
    @IBAction func addNewPressed(sender: AnyObject) {
        
        if CourseManager.sharedInstance.courseData.count >= 4 {
            Utils.alert("Classes", message: "You have \(CourseManager.sharedInstance.courseData.count) classes now")
        } else {
            // self.performSegueWithIdentifier("addCourse", sender: self)
        }
        
        self.performSegueWithIdentifier("addCourse", sender: self)
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if CourseManager.sharedInstance.courseData.isEmpty {
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
        
        return CourseManager.sharedInstance.courseData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ClassCell
        
        let course = CourseManager.sharedInstance.courseData[indexPath.row] as Course
        
        cell.course = course
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "viewClassDetail" {

            // destination
            let svc = segue.destinationViewController as! ClassDetailTableViewController
            // get selected row path
            let path = self.tableView.indexPathForSelectedRow!
            // set destination course
            svc.selectedCourse = CourseManager.sharedInstance.courseData[path.row]
        }
        
        if segue.identifier == "takeManualAttendanceFromButton" {
            
            // destination
            let svc = segue.destinationViewController as! TakeManualAttendanceTableViewController
            
            let indexPath = sender!
            svc.selectedCourse = CourseManager.sharedInstance.courseData[indexPath.row]

        }
    }
    
    @IBAction func unwindToManageCourse(segue: UIStoryboardSegue) {
        
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        /*

        if editingStyle == .Delete {
        
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
        */
        
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in
            
            // Delete the row from the data source
            let message = "Do you want to delete this course?"
            
            Utils.alert("Warning", message: message, okAction: nil, cancelAction: "Cancel", deleteAction: "Delete") { (action) -> Void in
                
                self.tableView.beginUpdates()
                CourseManager.sharedInstance.courseData.removeAtIndex(indexPath.row)
                // TODO: send delete request to the server
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                self.tableView.endUpdates()
                // self.reloadData()
            }
        }
        
        let attendance = UITableViewRowAction(style: .Normal, title: "Attendance") { action, index in
            
            self.performSegueWithIdentifier("takeManualAttendanceFromButton", sender: indexPath)
            
        }
        attendance.backgroundColor = UIColor.lightGrayColor()
        
//        if let image = UIImage(named: "report.png"){
//            more.backgroundColor = UIColor(patternImage: image)
//        }
       
        let report = UITableViewRowAction(style: .Normal, title: "Report") { action, index in
            
            tableView.setEditing(false, animated: true)
            
            let courseKey = CourseManager.sharedInstance.courseData[indexPath.row].getCourseKey()
            
            Utils.beginHUD()
            
            guard let email = self.userDefaults.stringForKey(UDKeys.uname) else {
                log.warning("User email is empty, user info updating aborted.")
                return
            }
            
            self.requester.getUserReport(courseKey, email: email, failureCallback: { (response) -> Void in
                
                    Utils.alert("Unable to connect", message: "")
                
                }, successCallback: { (response) -> Void in
                    
                    if let res = response.response {
                        
                        let json = JSON(data: response.data!)
                        
                        switch res.statusCode {
                        case 201:
                            Utils.endHUD()
                            Utils.alert("Get report", message: json.description)
                        default:
                            Utils.alert("Get report Error", message: "\(json.stringValue) \nCode \(res.statusCode)")
                            Utils.endHUD(false)
                        }
                        
                    }
            })
        }
        report.backgroundColor = UIColor.orangeColor()
        
        return [delete, report, attendance]
    }
    
    func reloadData() {
        updateCourseList()
        tableView.reloadData()
    }
    
    func updateCourseList() {
        
        guard let email = self.userDefaults.stringForKey(UDKeys.uname) else {
            log.warning("User email is empty, user info updating aborted.")
            return
        }
        
        if let token = UserManager.sharedInstance.info.token {
            
            self.requester.getUserAllCourses(.Professor, token: token, email: email) { (response) -> Void in
                
                let json = JSON(data: response.data!)
                
                switch response.response!.statusCode {
                case 200:
                    
                    let courses = json.arrayValue.map({ $0 })
                    
                    log.info("all course data \(courses)")
                    
                    CourseManager.sharedInstance.courseData = courses.map({ Course.JSONtoCourse($0) })
                    
                    self.tableView.reloadData()
                    
                default:
                    log.warning("Code \(response.response!.statusCode) not handled.")
                }
            }
        } else {
            log.error("Token not set, abort get all courses")
        }
    }
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}
