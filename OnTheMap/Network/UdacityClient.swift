//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 10/04/2021.
//

import Foundation

class UdacityClient {
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId: String? = ""
        static let defaultLimit = 100
        static let defaultOrder = "-updatedAt"
        static var loggedUser = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case logout
        case getStudentsLocation
        case postStudentLocation
        
        var stringValue: String {
            switch self {
            case .login, .logout:
                return Endpoints.base + "/session"
            case .getStudentsLocation:
                return Endpoints.base + "/StudentLocation?limit=\(Auth.defaultLimit)&order=\(Auth.defaultOrder)"
            case .postStudentLocation:
                return Endpoints.base + "/StudentLocation"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let responseObject = decodeJson(from: data, type: ResponseType.self)
            
            DispatchQueue.main.async {
                completion(responseObject, nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    class func taskForDELETERequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let range = 5..<data.count
            let newData = data.subdata(in: range)
            
            let responseObject = decodeJson(from: newData, type: ResponseType.self)
            
            DispatchQueue.main.async {
                completion(responseObject, nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, responseSubdata: Bool, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            var dataToDecode = data
            
            if responseSubdata {
                let range = 5..<data.count
                dataToDecode = data.subdata(in: range)
            }
            
            let responseObject = decodeJson(from: dataToDecode, type: ResponseType.self)
            
            DispatchQueue.main.async {
                completion(responseObject, nil)
            }
        }
        
        task.resume()
    }
    
    private class func decodeJson<ResponseType: Decodable>(from data: Data, type: ResponseType.Type) -> ResponseType? {
        let decoder = JSONDecoder()
        do {
            let responseObject = try decoder.decode(type, from: data)
            return responseObject
        } catch {
            return nil
        }
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: UdacityBody(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.login.url, responseType: LoginResponse.self, body: body, responseSubdata: true) { response, error in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.loggedUser = username
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        taskForDELETERequest(url: Endpoints.login.url, responseType: LogoutResponse.self) { _, error in
            if let error = error {
                completion(false, error)
            } else {
                Auth.sessionId = nil
                completion(true, nil)
            }
        }
    }
    
    class func getStudentsLocation(completion: @escaping ([StudentLocationResult], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getStudentsLocation.url, responseType: StudentsLocationResponse.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func postStudentLocation(body: PostStudentLocationRequest, completion: @escaping (Bool, Error?) -> Void) {
        taskForPOSTRequest(url: Endpoints.postStudentLocation.url, responseType: PostStudentLocationResponse.self, body: body, responseSubdata: false) { response, error in
            if response != nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
}
