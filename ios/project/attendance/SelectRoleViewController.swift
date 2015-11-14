//
//  SelectRoleViewController.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/26/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit

class SelectRoleViewController: UIViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let userRole = "User Role"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //: choose User Role
    //        userDefaults.setObject("Professor", forKey: userRole )
    //        userDefaults.setObjdect("Student", forKey: userRole )

    @IBAction func studentRolePressed(sender: AnyObject) {
        userDefaults.setObject("Student", forKey: userRole )
    }

    @IBAction func professorRolePressed(sender: AnyObject) {
        userDefaults.setObject("Professor", forKey: userRole )
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
