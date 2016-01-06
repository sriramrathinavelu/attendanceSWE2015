//
//  User.swift
//  attendance
//
//  Created by Yifeng on 11/8/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

//import UIKit

class User {
    
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var role: String
    var gender: Int?
    var studentID: String? = "0"
    var token: String?
    
    convenience init() {
        self.init(
            email: "", password: "", firstName: "", lastName: "", role: "")
    }
    
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
    
    func getGenderString() -> String {
        
        if let gender = self.gender {
            switch gender {
            case 1:
                return "Male"
            case 2:
                return "Femaile"
            default:
                return "Error, value not 1 or 2"
            }
        } else {
            return "unknown"
        }
    }
    
    func getFullName() -> String {
        return "\(firstName) \(lastName)"
    }
    
    var description: String {
        return "Email: \(email)\nFirst Name: \(firstName)\nLast Name: \(lastName)\nRole:\(role)\nGender: \(self.getGenderString())\nStudent ID: \(studentID)\nToken: \(token)"
    }
}
