//
//  ClassDetailViewController.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/17/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit

class ClassDetailViewController: UIViewController {
    
    @IBOutlet weak var courseNameLabel: UILabel!
    
    @IBOutlet weak var courseCodeLabel: UILabel!
    
    @IBOutlet weak var courseSectionLabel: UILabel!
    
    @IBOutlet weak var classRoomLabel: UILabel!
    
    @IBOutlet weak var durationStartLabel: UILabel!
    
    @IBOutlet weak var durationEndLabel: UILabel!
    
    @IBOutlet weak var timingStartLabel: UILabel!
    
    @IBOutlet weak var timingEndLabel: UILabel!
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    
    @IBOutlet weak var trimesterLabel: UILabel!
    
    var selectedCourse: Course?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print("ClassDetailViewController prints selectedCourse: \(selectedCourse)")
        
        self.title = selectedCourse!.getCourseCode()
        
        displayCourseDetails(selectedCourse!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayCourseDetails(course: Course) {
        
        
        
        self.courseNameLabel.text = course.name
            
        self.courseCodeLabel.text = course.code
            
        self.courseSectionLabel.text = String(course.section!)
            
        self.classRoomLabel.text = course.room

        self.durationStartLabel.text = NSDate().stringFromDate(course.durationStart!, format: "MMM d, yyyy")
        
        self.durationEndLabel.text = NSDate().stringFromDate(course.durationEnd!, format: "MMM d, yyyy")
        
        self.timingStartLabel.text = NSDate().stringFromDate(course.timeStart!, format: "H:mm a")
        
        self.timingEndLabel.text = NSDate().stringFromDate(course.timeEnd!, format: "H:mm a")
        
        self.dayOfWeekLabel.text = course.dayOfWeek
            
        self.trimesterLabel.text = course.trimester
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
