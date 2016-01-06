//
//  SelectClassTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/2/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit

class ManualAttendanceTableViewController: UITableViewController {
    
    let cellIdentifier = "classCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return  CourseManager.sharedInstance.courseData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ClassCell
        let course = CourseManager.sharedInstance.courseData[indexPath.row] as Course

        cell.course = course

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "takeManualAttendance"
        {
            
            // destination
            let svc = segue.destinationViewController as! TakeManualAttendanceTableViewController
            
            // get selected row path
            let path = self.tableView.indexPathForSelectedRow!
            
            // set destination course
            svc.selectedCourse = CourseManager.sharedInstance.courseData[path.row]
            
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
    
    
    //    var backViewController : UIViewController? {
    //
    //        var stack = self.navigationController!.viewControllers as Array
    //
    //        for (var i = stack.count-1 ; i > 0; --i) {
    //            if (stack[i] as UIViewController == self) {
    //                return stack[i-1]
    //            }
    //
    //        }
    //        return nil
    //    }
}
