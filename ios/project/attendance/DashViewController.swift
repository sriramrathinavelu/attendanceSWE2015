//
//  DashViewController.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/17/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import Alamofire

class DashViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var testInputTextField: UITextField!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let keyUserRole = "User Role"
    let keyIsNewUser = "New User"

    override func viewDidLoad() {

        super.viewDidLoad()
        
        // dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }

    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(true)

        // check user role

        print("## User Role")
        print(userDefaults.stringForKey(keyUserRole))
        
        debugPrint(userDefaults.stringForKey(keyUserRole))
        debugPrint(userDefaults.objectForKey(keyUserRole))
        
        
//        guard let role = userDefaults.objectForKey(keyUserRole) where role != nil else {
//            
//        }

        if userDefaults.objectForKey(keyIsNewUser) == nil { // production
            // show login
            performSegueWithIdentifier("showLogin", sender: self)
        }
    }

    // in a tab view, viewDidLoad will only fire once
    // viewWillAppear will be fired every time view shows
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        upadateUserInfo()
        // self.navigationController?.navigationBarHidden = true


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func resetLoginPressed(sender: AnyObject) {
        // reset isNewUser flag
        userDefaults.removeObjectForKey(keyIsNewUser)
        userDefaults.removeObjectForKey(keyUserRole)
        print("## Reset user role to ", userDefaults.stringForKey(keyUserRole))
        performSegueWithIdentifier("showLogin", sender: self)
    }

    @IBAction func goToLastPressed(sender: AnyObject) {
        var numberOfTabs: Int = 0

        if let tabBarController = self.tabBarController {
            numberOfTabs = (tabBarController.viewControllers?.count)!
        }

        tabBarController?.selectedIndex = numberOfTabs - 1

    }

    @IBAction func removeTabPressed(sender: AnyObject) {

        /// ## remove a tabbar item
        /// - viewControllers property is an array of all tabbar items
        /// - remove the index from that array
        /// TODO: Find out which tabs are for students, and which are for professors.
        if let tabBarController = self.tabBarController {
            let indexToRemove = (tabBarController.viewControllers?.count)! - 1
            if indexToRemove < tabBarController.viewControllers?.count && indexToRemove > 2 {
                var viewControllers = tabBarController.viewControllers
                viewControllers?.removeAtIndex(indexToRemove)
                tabBarController.viewControllers = viewControllers
            }
        }
    }
    
    /*:
    # test requests
        
    ## example account
    - username
        - test1001@itu.edu
    - password
        - password
    - token
        - a4eb2d5118e4076f3b5a2eaaec4414415f0e6a37d40f
    
    ## modes depending on the textfield
    - rg : registration
    - lg : login
    */
    @IBAction func requestPressed(sender: AnyObject) {
        
        var message = "Error"
        
        let mode = ( testInputTextField!.text!.isEmpty ) ? "default" : testInputTextField.text
        
        let credentials = [
            "email": "test1001@itu.edu",
            "password": "password"
        ]
        
        let token = "a4eb2d5118e4076f3b5a2eaaec4414415f0e6a37d40f"
        
        func registerUser() {
            Alamofire.request(.POST, "http://23.236.59.88:8000/register/", parameters: credentials)
                .responseJSON { response in
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        message = JSON as! String
                    }
                    
                    Utils.alert("Request", message: message, okAction: "OK")
            }
        }
        
        func loginUser() {
            
            Alamofire.request(.POST, "http://23.236.59.88:8000/login/", parameters: credentials)
                .responseJSON { response in
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        message = JSON["token"] as! String
                    }
                    
                    Utils.alert("Request", message: message, okAction: "OK")
            }
            
        }
        
        func updateProfessor() {
            let headers = [
                "Authorization": "Token \(token)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let info = [
                "email": "test1001@itu.edu",
                "first_name": "Professor",
                "last_name": "NotStudent"
            ]
            
            Alamofire.request(.POST, "http://23.236.59.88:8000/professor/", parameters: info, headers: headers)
                .responseJSON { response in
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        message = JSON.description
                    }
                    
                    Utils.alert("Request", message: message, okAction: "OK")
            }

        }
        
        func getUser() {
            
            let headers = [
                "Authorization": "Token \(token)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let info = [
                "email": "test1001@itu.edu",
                "first_name": "Professor",
                "last_name": "NotStudent"
            ]
            
            Alamofire.request(.GET, "http://23.236.59.88:8000/professor/\(info["email"]!)/", headers: headers)
                .responseJSON { response in
                    debugPrint(response)
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        message = JSON.description
                    }
                    
                    Utils.alert("Request", message: message, okAction: "OK")
            }

        }
        
        switch mode! {
        case "rg", "default":
            registerUser()
        case "lg":
            loginUser()
        case "pf":
            updateProfessor()
        case "gu":
            getUser()
        default:
            print("do nothing")
        }
        

//        let headers = [
//            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
//            "Content-Type": "application/x-www-form-urlencoded"
//        ]
        
        
    }
    
    func upadateUserInfo() {

        // num1 < num2 ? DO SOMETHING IF TRUE : DO SOMETHING IF FALSE

        nameLabel.text = "John Doe"

        roleLabel.text = userDefaults.objectForKey(keyUserRole) != nil ? userDefaults.stringForKey(keyUserRole) : "Error"

        genderLabel.text = "Myth"


        if let date = userDefaults.objectForKey(keyIsNewUser) as? NSDate {
            dateLabel.text = date.stringFromDate(date, format: "MMM d, yyyy H:mm a")
        } else {
            dateLabel.text = "Error"
        }

    }

    @IBAction func unwindToDashboard(segue: UIStoryboardSegue) {
        
    }


    func disablesTab() {

        // Disable a tabbar item
        var tabbarTest: UITabBarItem = UITabBarItem()

        let tabBarControllerItems = self.tabBarController?.tabBar.items
        if let arrayOfTabBarItems = tabBarControllerItems as! AnyObject as? NSArray{

            tabbarTest = arrayOfTabBarItems[3] as! UITabBarItem
            tabbarTest.enabled = false

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

}
