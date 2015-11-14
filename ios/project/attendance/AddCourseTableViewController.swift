//
//  AddCourseTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/9/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit

class AddCourseTableViewController: UITableViewController {

    @IBOutlet weak var isWeekendSwitch: UISwitch!
    

    
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

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 8
//    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }


    @IBAction func isWeekendToggleChanged(sender: AnyObject) {
        
        if isWeekendSwitch.on {
            
        } else {
            
        }
        
        tableView.reloadData()
        
    }

    //    isWeekendSwitch.on
    // TODO: add function to set row height = 0, implement hide/show on toggle
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 2 {
//            return 0.1
//        }
//        
//        return 20
//    }
//    
//    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 2 {
//            return 0.1
//        }
//        
//        return 20
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
