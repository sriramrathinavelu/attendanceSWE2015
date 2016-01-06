//
//  DashboardViewController.swift
//  attendance
//
//  Created by Yifeng on 12/11/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftCharts
import SwiftyJSON

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dashboardTextView: UITextView!
    
    let requester = RequestHelper()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    /* swiftcharts */
    private var chart: Chart? // arc
    
    let sideSelectorHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = NSDate().stringFromDate(NSDate(), format: "EEEE, MMMM d")
        // dashboardTextView.text = "Text that is long enough to scroll"
    }
    
    func updateUserInfo() {
        
        // TODO: get user info
        // 1. get name, gender, role
        // 2. get courses
        
        guard let role = self.userDefaults.stringForKey(UDKeys.userRole) else {
            log.error("Token missing. Cannot make request.")
            return
        }
        
        guard let token = self.userDefaults.stringForKey(UDKeys.token) else {
            log.error("Token missing. Cannot make request.")
            return
        }
        
        guard let email = self.userDefaults.stringForKey(UDKeys.uname) else {
            log.warning("User email is empty, user info updating aborted.")
            return
        }
        
        if role.isEmpty {
            log.warning("User role is empty, user info updating aborted.")
        } else {
            
            switch role {
            case "Student":
                requester.getUserData(.Student, token: token, email: email, successCallback: { (response) -> Void in
                    
                    if let res = response.response {
                        
                        let json = JSON(data: response.data!)
                        
                        switch res.statusCode {
                        case 404: // user not found
                            Utils.alert("Error", message: json.stringValue)
                        case 403:
                            Utils.alert("Error", message: json.stringValue)
                        case 200:
                            let firstName = json["first_name"].stringValue
                            let lastName = json["last_name"].stringValue
                            let gender = json["gender"].intValue
                            
                            UserManager.sharedInstance.info.firstName = firstName
                            UserManager.sharedInstance.info.lastName = lastName
                            UserManager.sharedInstance.info.gender = gender
                            
                            self.requester.getUserAllCourses(.Student, token: token, email: email) { (response) -> Void in
                                
                                let json = JSON(data: response.data!)
                                
                                switch response.response!.statusCode {
                                case 200:
                                    
                                    let courses = json.arrayValue.map({ $0 })
                                    
                                    log.info("all course data \(courses)")
                                    
                                    CourseManager.sharedInstance.studentCourseData = courses.map({ Course.JSONtoCourse($0) })
                                    
                                default:
                                    log.warning("Code \(response.response!.statusCode) not handled.")
                                }
                            }
                            
                        default:
                            log.error("Error: \(res.statusCode) not handled - getUser")
                        }
                    }
                })
                
                requester.getUserAllCourses(.Student, token: token, email: email, successCallback: { (response) -> Void in
                    
                    if let res = response.response {
                        
                        let json = JSON(data: response.data!)
                        
                        switch res.statusCode {
                        case 200:
                            let courses = json.arrayValue
                            
                            CourseManager.sharedInstance.studentCourseData = courses.map({ Course.JSONtoCourse($0) })
                            
                        default:
                            log.error("Error: \(res.statusCode) not handled - getUser")
                        }
                    }
                })
            case "Professor":
                requester.getUserData(.Professor, token: token, email: email, successCallback: { (response) -> Void in
                    
                    if let res = response.response {
                        
                        let json = JSON(data: response.data!)
                        
                        switch res.statusCode {
                        case 404: // user not found
                            Utils.alert("Error", message: json.stringValue)
                        case 403:
                            Utils.alert("Error", message: json.stringValue)
                        case 200:
                            let email = json["email"].stringValue
                            let firstName = json["first_name"].stringValue
                            let lastName = json["last_name"].stringValue
//                            let courses = json["courses"].arrayValue

                            UserManager.sharedInstance.info.firstName = firstName
                            UserManager.sharedInstance.info.lastName = lastName
                            
                            self.requester.getUserAllCourses(.Professor, token: token, email: email) { (response) -> Void in
                            
                                let json = JSON(data: response.data!)
                                
                                switch response.response!.statusCode {
                                case 200:
                                    
                                    let courses = json.arrayValue.map({ $0 })
                                    
                                    log.info("all course data \(courses)")
                                    
                                    CourseManager.sharedInstance.courseData = courses.map({ Course.JSONtoCourse($0) })
                                    
                                default:
                                    log.warning("Code \(response.response!.statusCode) not handled.")
                                }
                            }
                            
                        default:
                            log.error("Error: \(res.statusCode) not handled - getUser")
                        }
                    }
                })
            default:
                log.error("User role unknown (\(role)), user info updating aborted.")
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.dashboardTextView.scrollRangeToVisible(NSRange(location:0, length:0))
        })
        
        // TODO: Get status from shardInstance
        // TODO: use API to get attendance data, and update whenever a course update/check in action happens
        
        var chartXTitle: String? = nil
        
        
        
        chartXTitle = "Sample Attendance Data"
        
        let barModels = prepareBarModels(dataSource: [
                ("CSC 500", (5, 6) ),
                ("SWE 500", (6, 7) ),
                ("TST 341", (5, 7) ),
                ("TST 341", (6, 6) )
            ])
        
        self.showChart(horizontal: false, barModels: barModels, xLabelTitle: chartXTitle)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
        if userDefaults.objectForKey(UDKeys.isNewUser) == nil { // production
            // show login
            self.performSegueWithIdentifier("showLogin", sender: self)
        } else {
            
            if let role = userDefaults.stringForKey(UDKeys.userRole) {
                /// TODO: load name, and other user info
                /// TODO: save other user info
                
                updateUserInfo()
                UserManager.sharedInstance.info.role = role
                prepareTabForRole(role)
            }
        }
    }
    
    // MARK: - SwiftCharts
    
    func prepareBarModels(dataSource dataSource: [(String, ( Int , Int ) )]) -> [ChartBarModel] {

        let zero = ChartAxisValueDouble(0)
        
        let labelSettings = ChartLabelSettings(font: ChartDefaults.labelFont)
        
        let barModels: [ChartBarModel] = dataSource.mapWithIndex { (index, data) -> ChartBarModel in
           
//            print(data.0)
//            print(data.1, data.1.0, data.1.1)
            
            return ChartBarModel(constant: ChartAxisValueString(data.0, order: index + 1, labelSettings: labelSettings), axisValue1: zero, axisValue2: ChartAxisValueDouble( Double(data.1.0) / Double(data.1.1) * 100 ), bgColor: BarColors.array[index])
        }
        
        return barModels
        
        /* swiftcharts
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: 100, by: 20)
        )
        
        let size:CGFloat = 300
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        let frame = CGRectMake((screenWidth / 2) - (size / 2), (screenHeight - size - 49 - 20), size, (size + 20))
        
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Course",
            yTitle: "Attendance",
            bars: [
                ("CSC 500", 20),
                ("SWE 500", 100),
                ("TST 341", 80),
                ("TST 341", 80)
            ],
            color: Colors.orange,
            barWidth: 30
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
        */
        
        
    }
    
    private func barsChart(horizontal horizontal: Bool, barModels: [ChartBarModel], xLabelTitle: String? = "Courses") -> Chart {
        let labelSettings = ChartLabelSettings(font: ChartDefaults.labelFont)
        
        let (axisValues1, axisValues2) = (
            0.stride(through: 100, by: 20).map {ChartAxisValueFloat(CGFloat($0), labelSettings: labelSettings)},
            [ChartAxisValueString("", order: 0, labelSettings: labelSettings)] + barModels.map{$0.constant} + [ChartAxisValueString("", order: 5, labelSettings: labelSettings)]
        )
        let (xValues, yValues) = horizontal ? (axisValues1, axisValues2) : (axisValues2, axisValues1)

        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: xLabelTitle!, settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Attendance Rate", settings: labelSettings.defaultVertical()))
        
        let viewWidth = self.view.bounds.size.width
        let viewHeight = self.view.bounds.size.height
//        print(viewHeight)
        let frame = CGRectMake(0, 220, viewWidth, viewHeight - 220 )
        
        let chartFrame = self.chart?.frame ?? CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - sideSelectorHeight)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ChartDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let chartBarsLayer = ChartBarsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: barModels, horizontal: horizontal, barWidth: 40, animDuration: 0.5)

        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ChartDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        return Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartBarsLayer
            ]
        )
    }
    
    private func showChart(horizontal horizontal: Bool, barModels: [ChartBarModel], xLabelTitle: String? = "Courses") {
        self.chart?.clearView()
        
        let chart = self.barsChart(horizontal: horizontal, barModels: barModels, xLabelTitle: xLabelTitle)
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    func prepareTabForRole(role:String) {
        
        if userDefaults.objectForKey(UDKeys.isTester) == nil {
            
            if let tabBarController = self.tabBarController {
                
                switch role {
                case "Student":
                    if tabBarController.viewControllers!.count > 6 {
                        var viewControllers = tabBarController.viewControllers
                        viewControllers?.removeAtIndex(1)
                        viewControllers?.removeAtIndex(1)
                        viewControllers?.removeAtIndex(1)
                        tabBarController.viewControllers = viewControllers
                    }
                case "Professor":
                    if tabBarController.viewControllers!.count > 6 {
                        var viewControllers = tabBarController.viewControllers
                        viewControllers?.removeAtIndex(4)
                        viewControllers?.removeAtIndex(4)
                        tabBarController.viewControllers = viewControllers
                    }
                default:
                    print("no role")
                }
            }
        }
    }
    
    @IBAction func unwindToDashboard(segue: UIStoryboardSegue) {
        
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
