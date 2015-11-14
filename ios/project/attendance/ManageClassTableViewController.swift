//
//  ManageClassTableViewController.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/17/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import DBAlertController

class ManageClassTableViewController: UITableViewController {
    
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
        
        return courses.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ClassCell
        
        let course = courses[indexPath.row] as Course
        
        cell.course = course
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        self.performSegueWithIdentifier("viewClassDetail", sender: self)
        
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "viewClassDetail"
        {
            
            // destination
            let svc = segue.destinationViewController as! ClassDetailViewController
            
            // get selected row path
            let path = self.tableView.indexPathForSelectedRow!

            // set destination course
            svc.selectedCourse = courses[path.row]

        }
    }
    
    @IBAction func unwindToManageCourse(segue: UIStoryboardSegue) {
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            let message = "Delete"
            
            let alertController = DBAlertController(title: "Warning", message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: nil))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.show()
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
