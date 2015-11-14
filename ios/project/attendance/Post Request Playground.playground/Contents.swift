//: 
import UIKit

let info = [
    "email": "test1001@itu.edu",
    "first_name": "Professor",
    "last_name": "NotStudent"
]

let token = "a4eb2d5118e4076f3b5a2eaaec4414415f0e6a37d40f"

let headers = [
    "Authorization": "Token \(token)",
    //                "Content-Type": "application/x-www-form-urlencoded"
]


let url = "http://23.236.59.88:8000/professor/\(info["email"]!)"

print(url)

