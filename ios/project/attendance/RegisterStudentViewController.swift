//
//  RegisterStudentViewController.swift
//  attendance
//
//  Created by Yifeng on 11/8/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import DBAlertController

class RegisterStudentViewController: UIViewController {
    
    var userToRegister: User?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let keyIsNewUser = "New User"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.alert("Submit Form",
            message: "User Current value: \(userToRegister)", okAction: "Submit")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func submitStudentRegisterPressed(sender: AnyObject) {
        
        Utils.alert("Submit Form",
            message: "User Current value: \(userToRegister)", okAction: "Submit")
        
        successStudentRegister()
        
    }
    
    func successStudentRegister() {
        // set user flag
        userDefaults.setObject(NSDate(), forKey: keyIsNewUser )
        
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
