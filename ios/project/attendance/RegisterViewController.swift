//
//  RegisterViewController.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/26/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import DBAlertController

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var profFirstname: UITextField!
    @IBOutlet weak var profLastname: UITextField!
    @IBOutlet weak var profEmail: UITextField!
    @IBOutlet weak var profPassword: UITextField!

    let userRole = "User Role"
    let userDefaults = NSUserDefaults.standardUserDefaults()

    var frameView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        setTextFieldDelegate()
        
        // draw a UIView
        self.frameView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        // Keyboard stuff.
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
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
    
    
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardHeight: CGFloat = keyboardSize.height
        
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
        
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.frameView.frame = CGRectMake(0, (self.frameView.frame.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardHeight: CGFloat = keyboardSize.height
        
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.frameView.frame = CGRectMake(0, (self.frameView.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            }, completion: nil)
        
    }
    
//    func setTextFieldDelegate() {
//        // set the textFieldDelegates
//        registerProfessorWindow.profFirstname.delegate=self
//        registerProfessorWindow.profLastname.delegate=self
//        registerProfessorWindow.profEmail.delegate=self
//        registerProfessorWindow.profPassword.delegate=self
//    }
//    
    
//    // go to next field on return
//    func textFieldShouldReturn(textField: UITextField) -> Bool
//    {
//        switch textField
//        {
//        case registerProfessorWindow.profFirstname:
//            registerProfessorWindow.profLastname.becomeFirstResponder()
//            break
//        case registerProfessorWindow.profLastname:
//            registerProfessorWindow.profEmail.becomeFirstResponder()
//            break
//        case registerProfessorWindow.profEmail:
//            registerProfessorWindow.profPassword.becomeFirstResponder()
//            break
//        default:
//            textField.resignFirstResponder()
//        }
//        return true
//    }

    // Submit Professor registration
    @IBAction func registerProfessorPressed(sender: AnyObject) {
//
//        if let role = userDefaults.stringForKey(userRole)
//        {
//            print("User Role: \(role)")
//        }
        
        // check user input is empty
        if profFirstname.text!.isEmpty ||
           profLastname.text!.isEmpty ||
           profEmail.text!.isEmpty ||
           profPassword.text!.isEmpty
        {
            let message = "All fields are required"
            
            let alertController = DBAlertController(title: "Attendance", message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            alertController.show()
        } else { // display alert, show user imputs ##TODO
            displayRegisterInfo()
        }
        
    }
    
    func displayRegisterInfo() {
        
        view.endEditing(true)
        let role = userDefaults.stringForKey(userRole)
        let message = "User Role: \(role!)\n \(profFirstname.text!)\n \(profLastname.text!)\n\(profEmail.text!)\n \(profPassword.text!)"
        
        let alertController = DBAlertController(title: "Your inputs are", message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
            print("Cancel Pressed")
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        alertController.show()
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

