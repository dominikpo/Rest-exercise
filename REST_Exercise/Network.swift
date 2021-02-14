//
//  Network.swift
//  REST_Exercise
//
//  Created by Dominik Polzer on 11.10.20.
//  Copyright © 2020 Dominik Polzer. All rights reserved.
//

import Foundation

enum NetworkingError: Error , Equatable{
    case invalidEmail
    case invalidPassword
    case parsingError
    case requestError(String)
    case unknownError
    case emailNotKnown
    case toManyAttempts
    case serverNotFound
}

struct RootResponseError: Codable{
    let error: ResponseError
}

struct NestedError: Codable {
    let message: String
    let domain: String
    let reason: String
}

struct ResponseError: Codable {
    let code: Int
    let message: String
    let errors: [NestedError]
}



class Networking {

    func login(email:String, password: String, completionHandler: @escaping (User?, NetworkingError?) -> Void){

        let session = URLSession(configuration: .default)

        let url = URL(string:"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCTryhlVmmRHYE7iQT3k0eeNRHIKsTMpRw")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "password": password, "returnSecureToken": true]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completionHandler(nil, .parsingError)
            return
        }
        request.httpBody = jsonData

        let dataTask = session.dataTask(with: request) { (data, response, error) in
            var returnedUser: User? = nil
            var returnedError: NetworkingError? = nil
     
            
            
            if let error = error as NSError? {
                returnedError = .requestError(error.localizedDescription)
            }
            
//            if let data = data, let body = String(data: data, encoding: .utf8){
//                print(body)
//            }
//
//            if let error = error {
//                print("Error: \(error)")
//            }
//            
//            if let response = response{
//                print("Response: \(response)")
//            }
            
            let jsonDecoder = JSONDecoder()
            
            if let data = data{
                if let user = try? jsonDecoder.decode(User.self, from: data){
                    returnedUser = user
                }else{
                    returnedError = .parsingError
                }
            }
            if let data = data {
                if let rootResponseError = try? jsonDecoder.decode(RootResponseError.self, from: data){
                    var error: NetworkingError
                    switch rootResponseError.error.message{
                    case "INVALID_EMAIL":
                        error = .invalidEmail
                    case "INVALID_PASSWORD":
                        error = .invalidPassword
                    case "EMAIL_NOT_FOUND":
                        error = .emailNotKnown
                    case """
                        TOO_MANY_ATTEMPTS_TRY_LATER : Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.
                        """ :
                        error = .toManyAttempts
                    default:
                        error = .unknownError
                    }
                    returnedError = error
                }else {
                    returnedError = .parsingError
                }
            }
                    
            
            if returnedUser == nil && returnedError == nil{
                  returnedError = .unknownError
            }
            
            DispatchQueue.main.async {
                completionHandler(returnedUser, returnedError)
            }
        }
        dataTask.resume()
    }
}
