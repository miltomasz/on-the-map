//
//  StudentsLocation.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 20/04/2021.
//

import Foundation

struct StudentsLocationResponse: Decodable {
    
    let results: [StudentLocationResult]
    
}

struct StudentLocationResult: Decodable {
    
    let createdAt: String
    let updatedAt: String
    let firstName: String
    let lastName: String
    let longitude: Double
    let latitude: Double
    let mediaURL: String
    let mapString: String
    let uniqueKey: String
    let objectId: String
    
}
