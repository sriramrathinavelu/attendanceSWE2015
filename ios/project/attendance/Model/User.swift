//
//  User.swift
//  attendance
//
//  Created by Yifeng on 11/8/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

//import UIKit

struct User {
    
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var role: String
    var gender: Int? = 0
    var studentID: String?
    
    init(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        role: String)
    {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
    }
    
}
