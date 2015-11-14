//
//  AppDelegate.swift
//  attendance
//
//  Created by Yifeng on 10/26/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        /*:
        ## customize app colors
        # colors
        - orange #ff7302
        - greenD1 #00622e
        - greenD2 #01833e
        - greenL1 #94bf7d
        - greenL2 #bbdba6
        */

        // let orange = UIColor(red:1.00, green:0.45, blue:0.01, alpha:1.0)
        let greenD1 = UIColor(red:0.00, green:0.38, blue:0.18, alpha:1.0)
        let greenD2 = UIColor(red:0.00, green:0.51, blue:0.24, alpha:1.0)
        // let greenL1 = UIColor(red:0.58, green:0.75, blue:0.49, alpha:1.0)
        // let greenL2 = UIColor(red:0.73, green:0.86, blue:0.65, alpha:1.0)
        let white = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        // let grey = UIColor(red:0.55, green:0.55, blue:0.55, alpha:1.0)
        // let black = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0)
        

        // change global tint color
        self.window?.tintColor = greenD1
        
        // change tint color of navigation bar items
        UINavigationBar.appearance().tintColor = white
        
        // change tint color of navigation bar background
        UINavigationBar.appearance().barTintColor = greenD2
        
        // change tint color of tool bar items
        UIBarButtonItem.appearance().tintColor = white
        
        // change tint color of tool bar background
        UIToolbar.appearance().barTintColor = greenD1
        
        // change tint color of tab bar items
        UITabBar.appearance().tintColor = greenD2
        
        // change tint color of tab bar background
        UITabBar.appearance().barTintColor = white
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

