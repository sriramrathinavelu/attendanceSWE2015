//
//  Constants.swift
//  attendance
//
//  Created by Yifeng on 11/18/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import Foundation
import UIKit
import SwiftCharts
import AVFoundation

/*:
# colors
- orange #ff7302
- greenD1 #00622e
- greenD2 #01833e
- greenL1 #94bf7d
- greenL2 #bbdba6
*/
struct Colors {
    static let orange = UIColor(red:1.00, green:0.45, blue:0.01, alpha:1.0)
    static let greenL1 = UIColor(red:0.58, green:0.75, blue:0.49, alpha:1.0)
    static let greenL2 = UIColor(red:0.73, green:0.86, blue:0.65, alpha:1.0)
    static let greenD1 = UIColor(red:0.00, green:0.38, blue:0.18, alpha:1.0)
    static let greenD2 = UIColor(red:0.00, green:0.51, blue:0.24, alpha:1.0)
    static let white = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    static let grey = UIColor(red:0.55, green:0.55, blue:0.55, alpha:1.0)
    static let black = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0)
}

struct BarColors {
    static let array:[UIColor] = [
        UIColor(red:0.65, green:0.93, blue:0.91, alpha:0.7),
        UIColor(red:0.92, green:0.82, blue:0.58, alpha:0.7),
        UIColor(red:0.56, green:0.80, blue:0.76, alpha:0.7),
        UIColor(red:0.84, green:0.82, blue:0.70, alpha:0.7),
        UIColor(red:0.15, green:0.80, blue:0.71, alpha:0.7),
        UIColor(red:1.00, green:0.40, blue:0.45, alpha:0.7),
        UIColor(red:0.70, green:0.92, blue:0.80, alpha:0.7),
        UIColor(red:0.96, green:0.68, blue:0.65, alpha:0.7),
        UIColor(red:0.76, green:0.92, blue:0.94, alpha:0.7),
        UIColor(red:0.98, green:0.88, blue:0.76, alpha:0.7),
    ]
}

struct Config {

    static let version = "0.9.0"
    static let debug = true
    static let dateFormatInServer = "yyyy-MM-dd'T'HH:mm:ss"
    static let recordSettings = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
//        AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // kAudioFormatMPEGLayer3 kAudioFormatMPEG4AAC kAudioFormatLinearPCM
        AVEncoderBitRateKey : 96000,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1 as NSNumber,
        AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
}

struct UDKeys {

    static let isNewUser = "New User"
    static let version = "Version"
    static let userRole = "User Role"
    static let isTester = "isTester"
    static let token = "key"
    static let uname = "un"
}

struct ChartDefaults {

    static var chartSettings: ChartSettings {
        if Env.iPad {
            return self.iPadChartSettings
        } else {
            return self.iPhoneChartSettings
        }
    }

    private static var iPadChartSettings: ChartSettings {
        let chartSettings = ChartSettings()
        chartSettings.leading = 20
        chartSettings.top = 20
        chartSettings.trailing = 20
        chartSettings.bottom = 20
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.labelsToAxisSpacingY = 10
        chartSettings.axisTitleLabelsToLabelsSpacing = 5
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 15
        chartSettings.spacingBetweenAxesY = 15
        return chartSettings
    }

    private static var iPhoneChartSettings: ChartSettings {
        let chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        return chartSettings
    }

    static func chartFrame(containerBounds: CGRect) -> CGRect {
        return CGRectMake(0, 70, containerBounds.size.width, containerBounds.size.height - 70)
    }

    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: ChartDefaults.labelFont)
    }

    static var labelFont: UIFont {
        return ChartDefaults.fontWithSize(Env.iPad ? 14 : 11)
    }

    static var labelFontSmall: UIFont {
        return ChartDefaults.fontWithSize(Env.iPad ? 12 : 10)
    }

    static func fontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: size) ?? UIFont.systemFontOfSize(size)
    }

    static var guidelinesWidth: CGFloat {
        return Env.iPad ? 0.5 : 0.1
    }

    static var minBarSpacing: CGFloat {
        return Env.iPad ? 10 : 5
    }
}

/*
consider nested structs
struct Constants {
    struct NotificationKey {
        static let Welcome = "kWelcomeNotif"
    }

    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
}
*/