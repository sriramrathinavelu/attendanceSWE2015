//
//  SelectClassTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/2/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import DBAlertController

class ManualAttendanceTableViewController: UITableViewController {
    
    let cellIdentifier = "classCell"
    
    var courses:[Course] = coursesData // load fake data for courses
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  courses.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ClassCell
        
        let course = courses[indexPath.row] as Course

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
            svc.selectedCourse = courses[path.row]
            
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
