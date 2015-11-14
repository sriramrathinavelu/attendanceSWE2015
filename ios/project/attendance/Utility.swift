//
//  Utility.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/25/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import DBAlertController

// format time and date
extension NSDate {
    func dateFromString(date: String, format: String) -> NSDate {
        
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
    
    func stringFromDate(date: NSDate, format: String) -> String {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = format
        
        return dateFormatter.stringFromDate(date)
        
    }
}

class Utils {
    
    static func alert(title: String, message: String,
        okAction: String? = "OK",
        cancelAction: String? = nil,
        okCallback: ((action: UIAlertAction!) -> Void)? = nil,
        cancelCallback: ((action: UIAlertAction!) -> Void)? = nil ) {
        
        let alertController = DBAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert)
            
        alertController.addAction(UIAlertAction(title: okAction, style: .Default, handler: okCallback))
            
        if let cancelAction = cancelAction {
            alertController.addAction(UIAlertAction(title: cancelAction, style: .Cancel, handler: cancelCallback))
        }
            
        alertController.show()
    }
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