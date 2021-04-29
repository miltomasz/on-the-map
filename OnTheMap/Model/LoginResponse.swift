//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 16/04/2021.
//

import Foundation

struct LoginResponse: Decodable {
    
    let account: Account
    let session: Session
    
}

struct Account: Decodable {
    
    let registered: Bool
    let key: String
    
}

struct Session: Decodable {
    
    let id: String
    let expiration: String // "2021-04-17T21:44:48.185545Z"
    
}
