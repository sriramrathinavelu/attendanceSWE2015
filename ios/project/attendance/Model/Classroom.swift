//
//  Classroom.swift
//  attendance
//
//  Created by Yifeng on 12/17/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
 
struct Classroom {
    var code: String
    var name: String
    var radius: Int
    var type: String
    var coordinates: (Double, Double)

    init(code: String, name: String, radius: Int, type: String, coordinates: (Double, Double))
    {
        self.code = code
        self.name = name
        self.radius = radius
        self.type = type
        self.coordinates = coordinates
    }
}
