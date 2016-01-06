//
//  TakeManualAttendanceTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/2/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftyJSON

class TakeManualAttendanceTableViewController: UITableViewController {
    
    var selectedCourse: Course?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var studentEmail: UITextField!
    
    let requester = RequestHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentCourse = selectedCourse!
        
        title = currentCourse.getCourseKey()
        
        let message = "Taking attendance for \(currentCourse.getCourseKey())."

        Utils.alert("Manual Attendance", message: message)
        
        // dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    @IBAction func addAttendancePressed(sender: AnyObject) {
        
        Utils.beginHUD(withText: "Adding attendance...")
        
        let email = studentEmail.text!
        let courseKey = selectedCourse!.getCourseKey()
        
        requester.updateManualAttendance(email, courseKey: courseKey, dateTime: NSDate().stringFromDate(datePicker.date, format: Config.dateFormatInServer), failureCallback: { (response) -> Void in
            
            Utils.endHUD(false)
            
            }) { (response) -> Void in
            
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    switch res.statusCode {
                    case 201:
                        Utils.alert("Manual Attendance", message: json.stringValue)
                        Utils.endHUD()
                    default:
                        Utils.alert("Manual Attendance Error", message: "\(json.stringValue) \nCode \(res.statusCode)")
                        Utils.endHUD(false)
                    }
                    
                }
        }
    }
    
    
    func hideKeyboard(){
        self.view.endEditing(true)
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
