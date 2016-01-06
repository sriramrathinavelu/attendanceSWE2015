//
//  AddCourseTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/9/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftValidator
import ActionSheetPicker_3_0
import SwiftyJSON

class AddCourseTableViewController: UITableViewController,
    UITextFieldDelegate,
    ValidationDelegate {

    @IBOutlet weak var isWeekendSwitch: UISwitch!
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var courseCodeTextField: UITextField!
    @IBOutlet weak var courseSectionTextField: UITextField!
    @IBOutlet weak var courseRoomTextField: UITextField!

    @IBOutlet weak var trimesterTextField: UITextField!
    @IBOutlet weak var timeStartTextField: UITextField!
    @IBOutlet weak var timeEndTextField: UITextField!
    @IBOutlet weak var durationStartTextField: UITextField!
    @IBOutlet weak var durationEndTextField: UITextField!
    @IBOutlet weak var dayOfWeekTextField: UITextField!
    @IBOutlet weak var selectedDatesTextField: UITextField!

    // Error Labels
    @IBOutlet weak var errLabelName: UILabel!
    @IBOutlet weak var errLabelCode: UILabel!
    @IBOutlet weak var errLabelSection: UILabel!
    @IBOutlet weak var errLabelRoom: UILabel!
    @IBOutlet weak var errLabelTrimester: UILabel!
    @IBOutlet weak var errLabelTimeStart: UILabel!
    @IBOutlet weak var errLabelTimeEnd: UILabel!
    @IBOutlet weak var errLabelCourseStart: UILabel!
    @IBOutlet weak var errLabelCourseEnd: UILabel!
    @IBOutlet weak var errLabelDayOfWeek: UILabel!
    @IBOutlet weak var errLabelSelectedDates: UILabel!

    let validator = Validator()
    let fieldsForWeekend = [6,7]
    let fieldsForWeekday = [5]
    let timeFormat = "h:mm a"
    let dateFormat = "MMM d, yyyy"
    let dateServerFormat = Config.dateFormatInServer
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let requester = RequestHelper()
    
    var isWeekendChecked = false
    var textFields:[UITextField] = []
    var selectedCourse: Course?
    var currentCourseKey: String?
    var courseToAdd = Course()
    var indexToUpadate: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Colors.greenL2

        registerNextFields()

        hideErrorLabels()
        registerValidators()
        registerValidatorMessageStyle()

        if let course = selectedCourse {

            self.title = "Edit \(course.getCourseKey())"

            currentCourseKey = course.getCourseKey()
            isWeekendChecked = course.isWeekend
            fillCourseInfo(course)

        } else {

            self.title = "Add New Course"
            courseToAdd.professor = UserManager.sharedInstance.info.email
        }


        // dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
    }

    /// Validator
    func hideErrorLabels() {
        errLabelName.text = ""
        errLabelCode.text = ""
        errLabelSection.text = ""
        errLabelRoom.text = ""
        errLabelTrimester.text = ""
        errLabelTimeStart.text = ""
        errLabelTimeEnd.text = ""
        errLabelCourseStart.text = ""
        errLabelCourseEnd.text = ""
        errLabelDayOfWeek.text = ""
        errLabelSelectedDates.text = ""
    }

    func registerValidators() {
        // register validators

        validator.registerField(courseNameTextField, errorLabel: errLabelName, rules: [RequiredRule()])
        validator.registerField(courseCodeTextField, errorLabel: errLabelCode, rules: [RequiredRule()])
        validator.registerField(courseSectionTextField, errorLabel: errLabelSection, rules: [RequiredRule()])
        validator.registerField(courseRoomTextField, errorLabel: errLabelRoom, rules: [RequiredRule()])

        validator.registerField(trimesterTextField, errorLabel: errLabelTrimester, rules: [RequiredRule()])
        validator.registerField(timeStartTextField, errorLabel: errLabelTimeStart, rules: [RequiredRule()])
        validator.registerField(timeEndTextField, errorLabel: errLabelTimeEnd, rules: [RequiredRule()])
        validator.registerField(durationStartTextField, errorLabel: errLabelCourseStart, rules: [RequiredRule()])
        validator.registerField(durationEndTextField, errorLabel: errLabelCourseEnd, rules: [RequiredRule()])
        
        validator.registerField(selectedDatesTextField, errorLabel: errLabelSelectedDates, rules: [WeekendRequiredRule(isWeekendSwitch: isWeekendSwitch)])
        
        validator.registerField(dayOfWeekTextField, errorLabel: errLabelDayOfWeek, rules: [dayOfWeekRequiredRule(isWeekendSwitch: isWeekendSwitch)])

    }

    func registerValidatorMessageStyle() {
        // change text field style on error
        validator.styleTransformers(success:{ (validationRule) -> Void in
            // clear error label
            validationRule.errorLabel?.hidden = true
            validationRule.errorLabel?.text = ""
            validationRule.textField.textColor = Colors.greenD1

            }, error:{ (validationError) -> Void in
                validationError.errorLabel?.hidden = false
                validationError.errorLabel?.text = validationError.errorMessage
                validationError.textField.textColor = UIColor.redColor()
        })
    }

    func validationSuccessful() {

        hideKeyboard()

        if var selectedCourse = selectedCourse { // Edit selected course
            
            selectedCourse.name = self.courseNameTextField.text!
            selectedCourse.code = self.courseCodeTextField.text!
            selectedCourse.section = self.courseSectionTextField.text!
            selectedCourse.room = self.courseRoomTextField.text!

            for (index, course) in CourseManager.sharedInstance.courseData.enumerate() {
                if course.courseKey == currentCourseKey {
                    indexToUpadate = index
                }
            }

            if let index = indexToUpadate {
                CourseManager.sharedInstance.courseData[index].isWeekend = isWeekendSwitch.on
                CourseManager.sharedInstance.courseData[index].name = self.courseNameTextField.text!
                CourseManager.sharedInstance.courseData[index].code = self.courseCodeTextField.text!
                CourseManager.sharedInstance.courseData[index].section = self.courseSectionTextField.text!
                CourseManager.sharedInstance.courseData[index].room = self.courseRoomTextField.text!
                CourseManager.sharedInstance.courseData[index].trimester = self.trimesterTextField.text!

                CourseManager.sharedInstance.courseData[index].timeStart = formatDateForServer(self.timeStartTextField.text!, format: timeFormat)
                CourseManager.sharedInstance.courseData[index].timeEnd = formatDateForServer(self.timeEndTextField.text!, format: timeFormat)
                CourseManager.sharedInstance.courseData[index].durationStart = formatDateForServer(self.durationStartTextField.text!, format: dateFormat)
                CourseManager.sharedInstance.courseData[index].durationEnd = formatDateForServer(self.durationEndTextField.text!, format: dateFormat)
                
                if isWeekendChecked {

                    CourseManager.sharedInstance.courseData[index].dayOfWeek = nil
                    CourseManager.sharedInstance.courseData[index].selectedDates = courseToAdd.selectedDates

                } else {

                    CourseManager.sharedInstance.courseData[index].dayOfWeek = weekdays.indexOf(self.dayOfWeekTextField.text!)
                    CourseManager.sharedInstance.courseData[index].selectedDates = nil

                }
                
                let token = UserManager.sharedInstance.info.token!
                
                requester.updateCourse(.Course, token: token, isWeekend: isWeekendChecked, courseData: CourseManager.sharedInstance.courseData[index].toJSON(), failureCallback: { (response) -> Void in
                    
                    Utils.alert("Update course information failed", message: "Something went wrong.")
                    
                    }, successCallback: { (response) -> Void in
                        
                        if let res = response.response {
                            
                            let json = JSON(data: response.data!)
                            
                            switch res.statusCode {
                            case 400:
                                
                                let message = json.string!
                                Utils.alert("Failed", message: message)
                            case 201:
                                print("201")
                            default:
                                print(res.statusCode, "not handled. - update course")
                            }
                            
                            
                        }
                        
                })
                
                Utils.alert("JSON for server", message: CourseManager.sharedInstance.courseData[index].toJSON().description)
                
            }

            self.performSegueWithIdentifier("backToCourseDetail", sender: self)

        } else { // Add New Course
            
            self.courseToAdd.isWeekend = self.isWeekendChecked
            self.courseToAdd.name = self.courseNameTextField.text!
            self.courseToAdd.code = self.courseCodeTextField.text!
            self.courseToAdd.section = self.courseSectionTextField.text!
            self.courseToAdd.room = self.courseRoomTextField.text!
            
            self.courseToAdd.timeStart = self.timeStartTextField.text!.formatDateStringForServer(fromFormat: timeFormat)
            self.courseToAdd.timeEnd = self.timeEndTextField.text!.formatDateStringForServer(fromFormat: timeFormat)
            self.courseToAdd.durationStart = self.durationStartTextField.text!.formatDateStringForServer(fromFormat: dateFormat)
            self.courseToAdd.durationEnd = self.durationEndTextField.text!.formatDateStringForServer(fromFormat: dateFormat)
            
            if isWeekendChecked {
                
//                self.courseToAdd.selectedDates = [NSDate(), NSDate(), NSDate()]
                
            } else {
                
                // weekday course
                self.courseToAdd.dayOfWeek = weekdays.indexOf(self.dayOfWeekTextField.text!)
                
            }
            
            print(self.courseToAdd)
            // TODO: save course to server
            let token = UserManager.sharedInstance.info.token!
            
            requester.updateCourse(.Course, token: token, isWeekend: isWeekendChecked, courseData: self.courseToAdd.toJSON(), failureCallback: { (response) -> Void in
                
                    Utils.alert("Update course information failed", message: "Something went wrong.")
                
                }, successCallback: { (response) -> Void in
                    
                    if let res = response.response {
                        
                        let json = JSON(data: response.data!)
                        
                        switch res.statusCode {
                        case 400:
                            
                            let message = json.string!
                            Utils.alert("Failed", message: message)
                        case 201:
                            print("201")
                            
                            
                            CourseManager.sharedInstance.courseData.append(self.courseToAdd)
                            
                            self.performSegueWithIdentifier("backToCourseList", sender: self)
                            
                        default:
                            print(res.statusCode, "not handled. - register user")
                        }
                        
                        
                    }
                    
            })
            
            Utils.alert("JSON for server", message: self.courseToAdd.toJSON().description)

        }

    }

    func validationFailed(errors:[UITextField:ValidationError]) {

        print("Validation Failed")
        
        // TODO: remove options
        Utils.alert("Validation", message: "Validation Failed", okAction: "Stay", cancelAction: "Back to Courses", cancelCallback: { (action) -> Void in
            print("Back to course list")
            self.performSegueWithIdentifier("backToCourseList", sender: self)
        })
    }
    /// End Validator

    func hideKeyboard(){
        self.view.endEditing(true)
    }

    /// Go to next field
    func registerNextFields() {

        self.courseNameTextField.delegate = self
        self.courseCodeTextField.delegate = self
        self.courseSectionTextField.delegate = self
        self.courseRoomTextField.delegate = self

        textFields = [
            courseNameTextField,
            courseCodeTextField,
            courseSectionTextField,
            courseRoomTextField
        ]

    }

    // Next Field
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        var currentTextField = textFields[0]

        for (index, field) in textFields.enumerate() {

            if textField == field {
                if index < textFields.count-1 {
                    currentTextField = textFields[index+1]
                    currentTextField.becomeFirstResponder()
                }
//                else { // last item
//                    currentTextField.resignFirstResponder()
//                    // do submit stuff
//                    Utils.alert("Alert", message: "Submit")
//                }
            }
        }

        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fillCourseInfo(course: Course) {

        isWeekendSwitch.setOn(course.isWeekend, animated: false)

        courseNameTextField.text = course.name
        courseCodeTextField.text = course.code
        courseSectionTextField.text = course.section
        courseRoomTextField.text = course.room

        durationStartTextField.text = course.durationStart.formatDateStringFromString(toFormat: dateFormat)
        durationEndTextField.text = course.durationEnd.formatDateStringFromString(toFormat: dateFormat)
        timeStartTextField.text = course.timeStart.formatDateStringFromString(toFormat: timeFormat)
        timeEndTextField.text = course.timeEnd.formatDateStringFromString(toFormat: timeFormat)

        trimesterTextField.text = course.trimester

        if course.isWeekend {
            if let selectedDates = course.selectedDates {
                var displayDatesString = ""
                
                selectedDates.forEach({ (date) -> () in
                    displayDatesString += "\(date.stringFromDate(date, format: dateFormat)) /"
                })
                
                selectedDatesTextField.text = displayDatesString.substringToIndex(displayDatesString.endIndex.advancedBy(-1))            }
        } else {
            dayOfWeekTextField.text = weekdays[course.dayOfWeek!]
        }

    }

    // MARK: - Table view data source

    @IBAction func isWeekendToggleChanged(sender: AnyObject) {
        isWeekendChecked = isWeekendSwitch.on

        courseToAdd.isWeekend = isWeekendSwitch.on
        // registerValidators()
        tableView.reloadData()
    }


    @IBAction func saveCourseButtonPressed(sender: AnyObject) {

        hideKeyboard()
        validator.validate(self)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.backgroundColor = Colors.greenL2
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if isWeekendChecked && indexPath.section == 2 {
           // is weekend, hide weekday

            if fieldsForWeekday.contains(indexPath.row) {

                return 0
            }

            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)

        } else {
            // is weekday, hide weekend

            if fieldsForWeekend.contains(indexPath.row) {

                return 0
            }

            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    /// Date Picker Fields
    @IBAction func trimesterButtonPressed(sender: AnyObject) {

        let trimesters = ["Spring", "Summer", "Fall"]
        let currentYear = NSDate().stringFromDate(NSDate(), format: "yyyy")
        let years = [String(Int(currentYear)! - 1), currentYear, String(Int(currentYear)! + 1)]

        var selected = [1, 1]

        self.hideKeyboard()

        if let ttext = trimesterTextField.text where !ttext.isEmpty {
            var words = ttext.componentsSeparatedByString(" ")

            if let index1 = trimesters.indexOf(words[0]) {
                selected[0] = index1
            }

            if let index2 = years.indexOf(words[1]) {
                selected[1] = index2
            }

        }

        ActionSheetMultipleStringPicker.showPickerWithTitle(
            "Select Trimester", rows: [trimesters, years], initialSelection: selected,
            doneBlock: {
                picker, values, indexes in

                let data = values as! [Int]

                self.trimesterTextField.text = trimesters[data[0]] + " " + years[data[1]]

                // TODO: save
                // self.courseToAdd.trimester = trimesters[data[0]] + " " + years[data[1]]

            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }

    @IBAction func timeStartButtonPressed(sender: AnyObject) {

        var selected = NSDate()

        self.hideKeyboard()

        if let tstext = timeStartTextField.text where !tstext.isEmpty {
            selected = NSDate().dateFromString(tstext, format: timeFormat)
        }

        let datePicker = ActionSheetDatePicker(title: "Time Start:", datePickerMode: .Time, selectedDate: selected, doneBlock: { picker, values, indexes in

                let time = values as! NSDate

                self.timeStartTextField.text = time.stringFromDate(time, format: self.timeFormat)

            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender.superview!!.superview)

        // origin: sender.superview!!.superview

        datePicker.minuteInterval = 5
        datePicker.showActionSheetPicker()
    }

    @IBAction func timeEndButtonPressed(sender: AnyObject) {

        var selected = NSDate()

        self.hideKeyboard()

        if let tetext = timeEndTextField.text where !tetext.isEmpty {
            selected = NSDate().dateFromString(tetext, format: timeFormat)
        }

        let datePicker = ActionSheetDatePicker(title: "Time Start:", datePickerMode: .Time, selectedDate: selected, doneBlock: { picker, values, indexes in

            let time = values as! NSDate

            self.timeEndTextField.text = time.stringFromDate(time, format: self.timeFormat)

            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender.superview!!.superview)

        // origin: sender.superview!!.superview

        datePicker.minuteInterval = 5
        datePicker.showActionSheetPicker()

    }

    @IBAction func durationStartButtonPressed(sender: AnyObject) {

        var selected = NSDate()

        self.hideKeyboard()

        if let dstext = durationStartTextField.text where !dstext.isEmpty {
            selected = NSDate().dateFromString(dstext, format: dateFormat)
        }

        let datePicker = ActionSheetDatePicker(title: "Start Date:", datePickerMode: .Date, selectedDate: selected, doneBlock: {
            picker, value, index in

            let date = value as! NSDate
            self.durationStartTextField.text = date.stringFromDate(date, format: self.dateFormat)

            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender.superview!!.superview)
        let secondsInYear: NSTimeInterval = 52 * 7 * 24 * 60 * 60
        datePicker.minimumDate = NSDate(timeInterval: -secondsInYear, sinceDate: NSDate())
        datePicker.maximumDate = NSDate(timeInterval: secondsInYear, sinceDate: NSDate())
        datePicker.showActionSheetPicker()

    }

    @IBAction func durationEndButtonPressed(sender: AnyObject) {

        var selected = NSDate()

        self.hideKeyboard()

        if let detext = durationEndTextField.text where !detext.isEmpty {
            selected = NSDate().dateFromString(detext, format: dateFormat)
        }

        let datePicker = ActionSheetDatePicker(title: "End Date:", datePickerMode: .Date, selectedDate: selected, doneBlock: {
            picker, value, index in

            let date = value as! NSDate
            self.durationEndTextField.text = date.stringFromDate(date, format: self.dateFormat)

            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender.superview!!.superview)
        let secondsInYear: NSTimeInterval = 52 * 7 * 24 * 60 * 60
        datePicker.minimumDate = NSDate(timeInterval: -secondsInYear, sinceDate: NSDate())
        datePicker.maximumDate = NSDate(timeInterval: secondsInYear, sinceDate: NSDate())
        datePicker.showActionSheetPicker()

    }

    @IBAction func dayOfWeekButtonPressed(sender: AnyObject) {

        var initialSelection = 0

        self.hideKeyboard()

        if let dowText = self.dayOfWeekTextField.text where !dowText.isEmpty {
            if let index = weekdays.indexOf(dowText) {
                initialSelection = index
            }
        }

        ActionSheetStringPicker.showPickerWithTitle("Select Day of Week", rows: weekdays, initialSelection: initialSelection, doneBlock: {
            picker, value, index in

            self.dayOfWeekTextField.text = self.weekdays[value]

            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)

    }

    @IBAction func selectDatesButtonPressed(sender: AnyObject) {

//        courseToAdd.selectedDates?.append(NSDate().stringFromDate(NSDate()))

    }

    // timeStartTextTouched

    /// End Date Picker

    /*:
    Add new resource to array

    @IBAction func savePlayerDetail(segue:UIStoryboardSegue) {
        if let playerDetailsViewController = segue.sourceViewController as? PlayerDetailsViewController {

            //add the new player to the players array
            if let player = playerDetailsViewController.player {
                players.append(player)

                //update the tableView
                let indexPath = NSIndexPath(forRow: players.count-1, inSection: 0)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }

    */
    
    // MARK: Felper funcs
    func formatDateForServer(date: String, format: String) -> String {
        
        return date.formatDateStringFromString(fromFormat: format, toFormat: Config.dateFormatInServer)
        
    }
    
    @IBAction func unwindToAddCourse(segue: UIStoryboardSegue) {
        
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "backToCourseDetail" {
            
            // destination
            let svc = segue.destinationViewController as! ClassDetailTableViewController
            // set destination course
            svc.selectedCourse = CourseManager.sharedInstance.courseData[indexToUpadate!]
        }
        
        if segue.identifier == "showCalendar" {
            
            // destination
            let svc = segue.destinationViewController as! CalendarViewController
            
            // TODO: passing dates to calendar view
            if let dates = courseToAdd.selectedDates {
                svc.selectedDates = dates
            }
        }
    }
}

//
// Custom valition rules
//
public class WeekendRequiredRule: Rule {
    
    private let isWeekendSwitch: UISwitch
    private var message : String
    
    public init(isWeekendSwitch : UISwitch , message : String = "This field is required"){
        self.isWeekendSwitch = isWeekendSwitch
        self.message = message
    }
    
    public func validate(value: String) -> Bool {
        if isWeekendSwitch.on {
            return !value.isEmpty
        }
        return true
    }
    
    public func errorMessage() -> String {
        return message
    }
}

public class dayOfWeekRequiredRule: Rule {
    
    private let isWeekendSwitch: UISwitch
    private var message : String
    
    public init(isWeekendSwitch : UISwitch , message : String = "This field is required"){
        self.isWeekendSwitch = isWeekendSwitch
        self.message = message
    }
    
    public func validate(value: String) -> Bool {
        if !isWeekendSwitch.on {
            return !value.isEmpty
        }
        return true
    }
    
    public func errorMessage() -> String {
        return message
    }
}
