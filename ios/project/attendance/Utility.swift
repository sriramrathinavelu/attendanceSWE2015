//
//  Utility.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/25/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import DBAlertController
import ActionSheetPicker_3_0
import PKHUD

// format time and date
extension NSDate {
    func dateFromString(date: String, format: String) -> NSDate {
        
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
    
    func stringFromDate(date: NSDate, format: String? = "MMM d, yyyy H:mm a") -> String {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = format
        
        return dateFormatter.stringFromDate(date)
        
    }
}

// make NSDate comparable
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

extension String {
    func formatDateStringForServer(fromFormat format: String) -> String {

        let date = NSDate().dateFromString(self, format: format)
        
        return NSDate().stringFromDate(date, format: Config.dateFormatInServer)
    }
    
    func formatDateStringFromString(fromFormat fromFormat: String? = Config.dateFormatInServer, toFormat: String) -> String {
        
        let date = NSDate().dateFromString(self, format: fromFormat!)
        
        return NSDate().stringFromDate(date, format: toFormat)
    }
}

class Utils {
    
    /// Display an alert view
    static func alert(title: String, message: String,
        okAction: String? = "OK",
        cancelAction: String? = nil,
        deleteAction: String? = nil,
        okCallback: ((action: UIAlertAction!) -> Void)? = nil,
        cancelCallback: ((action: UIAlertAction!) -> Void)? = nil,
        deleteCallback: ((action: UIAlertAction!) -> Void)? = nil ) {
        
        let alertController = DBAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert)
        
        if let okAction = okAction {
            alertController.addAction(UIAlertAction(title: okAction, style: .Default, handler: okCallback))
        }
            
        if let cancelAction = cancelAction {
            alertController.addAction(UIAlertAction(title: cancelAction, style: .Cancel, handler: cancelCallback))
        }
        
        if let deleteAction = deleteAction {
            alertController.addAction(UIAlertAction(title: deleteAction, style: .Destructive, handler: deleteCallback))
        }
        
        alertController.show()
    }
//    
//    static func textHUD(text: String) {
//        PKHUD.sharedHUD.contentView = PKHUDTextView(text: text)
//    }
//    
//    static func hideHUD(duration: Double? = nil) {
//        if let duration = duration {
//            PKHUD.sharedHUD.hide(afterDelay: duration)
//        } else {
//            PKHUD.sharedHUD.hide()
//        }
//    }
//    
//    static func showHUD() {
//        PKHUD.sharedHUD.show()
//    }
    
    static func beginHUD(withText text:String? = nil) {
        if let text = text {
            
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: text)
            PKHUD.sharedHUD.show()
        } else {
            
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show()
        }
    }
    
    static func endHUD(isSuccess: Bool? = true) {
        if let isSuccess = isSuccess {
            switch isSuccess {
            case true:
                PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
            case false:
                PKHUD.sharedHUD.contentView = PKHUDErrorView()
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
            }
        }
    }
    
    static func log(title:String, printBody: () -> Void ) {
        
        if Config.debug == true {
            
            print("\n\n -------", NSDate(), "---------\n", "======= \(title) ======\n")
            
            printBody()
            
            print("------ *** ------\n\n")
            
            
        }
    }
}

// A Regex operator
infix operator =~ {}

func =~(string:String, regex:String) -> Bool {

    return string.rangeOfString(regex, options: .RegularExpressionSearch) != nil
}


extension UIImage {
    //  RBResizer.swift Created by Hampton Catlin on 6/20/14.
    //  Copyright (c) 2014 rarebit. All rights reserved.
    func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
        
        Utils.alert("Test Crop Image", message: "Crop", okAction: "Good")
        
        return RBResizeImage(RBSquareImage(image), targetSize: size)
    }
    
    func RBSquareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        let cropSquare = CGRectMake((originalHeight - originalWidth)/2, 0.0, originalWidth, originalWidth)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}

class Env {
    
    static var iPad: Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
}

extension Array {
    
    public func mapWithIndex<T> (f: (Int, Element) -> T) -> [T] {
        return zip((self.startIndex ..< self.endIndex), self).map(f)
    }
}