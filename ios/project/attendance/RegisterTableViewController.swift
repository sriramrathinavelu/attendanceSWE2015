//
//  RegisterTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/7/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import DBAlertController

class RegisterTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var userFirstNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var studentGenderSegment: UISegmentedControl!
    @IBOutlet weak var studentIDTextField: UITextField!
    

    let userRole = "User Role"
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let imagePicker = UIImagePickerController()

    var userToRegister = User(email: "", password: "", firstName: "", lastName: "", role: "")

    private enum Genders: Int {
        case Male = 0, Female
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

        userToRegister.role = userDefaults.stringForKey(userRole)!

    }

    override func viewWillDisappear(animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // End editing mode when touch out of Text field
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

//    // MARK: - Table view data source
//
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 2
//    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 80
    }
    
    
    // student action
    @IBAction func nextButtonPressed(sender: AnyObject) {

        // validation of all fields

    }
    
    // user action
    @IBAction func chooseImagePressed(sender: AnyObject) {

        imagePicker.allowsEditing = true
        
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)

    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "registerStudentNext"
        {
            let isStudent = true
            
            saveCurrentUserInfo(isStudent)
            
            // destination
            let svc = segue.destinationViewController as! RegisterStudentViewController
            
            // set destination course
            svc.userToRegister = userToRegister

        }
    }
    
    func saveCurrentUserInfo(isStudent: Bool? = false) {
        
        userToRegister.firstName = userFirstNameTextField.text!
        userToRegister.lastName = userLastNameTextField.text!
        userToRegister.email = userEmailTextField.text!
        userToRegister.password = userPasswordTextField.text!
        
        if isStudent ?? false {
            userToRegister.studentID = studentIDTextField.text!
            setUserGender()
        }
    }
    
    func setUserGender() {
        let selectedSegment = Genders(rawValue: studentGenderSegment.selectedSegmentIndex)!
        switch selectedSegment {
        case .Male:
            userToRegister.gender = 1
        case .Female:
            userToRegister.gender = 2
        }
    }


    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage

        userProfileImageView.image = chosenImage.RBResizeImage(chosenImage, targetSize: CGSizeMake(128*3, 128*3))

        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }



    @IBAction func submitProfessorRegisterPressed(sender: AnyObject) {
        
        saveCurrentUserInfo()
        
        saveProfileImage()
        
        successProfessorRegister()
        
        Utils.alert("Submit Professor",
            message: "Professor\n \(userToRegister)", okAction: "OK")
        
    }
    
    func successProfessorRegister() {
        
        let keyIsNewUser = "New User"
        
        // set user flag
        userDefaults.setObject( NSDate(), forKey: keyIsNewUser )
        
    }

    // TODO: save profile image to device
    func saveProfileImage() {
        
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
