//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 10/04/2021.
//

import Foundation

struct LoginRequest: Encodable {
    
    let udacity: UdacityBody
    
}

struct UdacityBody: Encodable {
    
    let username: String
    let password: String
    
}
