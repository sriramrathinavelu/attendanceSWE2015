//
//  CalendarViewController.swift
//  attendance
//
//  Created by Yifeng on 12/10/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController,
    CalendarViewDelegate {
    
    @IBOutlet var placeholderView: UIView!
    
    let dateFormat = "MMM d, yyyy"
    
    var selectedDates: [NSDate]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // todays date.
        let date = NSDate()
        var selectedDates = self.selectedDates
        
        if selectedDates == nil {
            selectedDates = [date]
        }
        
        var displayDatesString = ""
        
        selectedDates!.forEach({ (date) -> () in
            displayDatesString += "\(date.stringFromDate(date, format: dateFormat))\n"
        })
        
        Utils.alert("Selected Dates", message: displayDatesString.substringToIndex(displayDatesString.endIndex.advancedBy(-1)))
        
        // create an instance of calendar view with
        // base date (Calendar shows 12 months range from current base date)
        // selected date (marked dated in the calendar)
        let calendarView = CalendarView.instance(date, selectedDates: selectedDates!)
        calendarView.delegate = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarView.allowMultipleSelections = true   //Allows selection of multiple dates. Defaults to false
        
        placeholderView.addSubview(calendarView)
        
        // Constraints for calendar view - Fill the parent view.
        placeholderView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        placeholderView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //REQUIRED: Will be called whether allowMultipleSelections is true or false.
    //Also will be called in cases of selection and deselection.
    // Will return the last SELECTED date available
    func didSelectDate(date: NSDate) {
        print("\(date.year)-\(date.month)-\(date.day)")
    }
    
    //OPTIONAL: Will return all selected dates. Useful when allowMultipleSelections is true
    
    func didChangeSelectedDates(dates: [NSDate]) {
        
        print("Selected Dates: {")
        dates.forEach { (date) -> () in
            print("\(date.year)-\(date.month)-\(date.day)")
        }
        print("}")
        
        
        // TODO: set calendar dates when changes are made
        self.selectedDates = dates
    }

    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        // navigate back
        self.performSegueWithIdentifier("unwindToAddCourse", sender: self)
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "unwindToAddCourse" {
            
            // TODO: pass the date to add course
            // destination
            let svc = segue.destinationViewController as! AddCourseTableViewController
            // set destination course
            var displayDatesString = ""
            if let selectedDates = self.selectedDates {
                selectedDates.forEach({ (date) -> () in
                    displayDatesString += "\(date.stringFromDate(date, format: dateFormat))/"
                })
                
                svc.selectedDatesTextField.text = displayDatesString.substringToIndex(displayDatesString.endIndex.advancedBy(-1))

            }
            svc.courseToAdd.selectedDates = self.selectedDates
        }
    }
    

}
