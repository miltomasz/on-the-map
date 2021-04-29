//
//  PostStudentLocationRequest.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 28/04/2021.
//

import Foundation


struct PostStudentLocationRequest: Encodable {
    
    let uniqueKey: String
    let firstName: String
    let lastName: String?
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
}
