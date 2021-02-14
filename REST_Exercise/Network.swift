//
//  Network.swift
//  REST_Exercise
//
//  Created by Dominik Polzer on 11.10.20.
//  Copyright © 2020 Dominik Polzer. All rights reserved.
//

import Foundation


// MARK: - Break down the Networking Error Struct
// Networking from the firebase endpoint

enum NetworkingError: Error , Equatable{
    case invalidEmail
    case invalidPassword
    case parsingError
    case requestError(String)
    case unknownError
    case emailNotKnown
    case toManyAttempts
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


// MARK: - Country Errors and Country Networking Errors
enum CountryError: Error {
    case unknownError
    case requestError
    case authenticateError
    case permissionError
    case notFoundError
    case noInternetError
}

struct RootCountyResponseError: Decodable {
    let error: CountryResponseError
}

struct CountryResponseError: Decodable{
    let code: Int
    let message: String
    let status: String
}



// MARK: - Networking class

class Networking {
    
    var session = URLSession(configuration: .default)
    var loggedInUser: User? = nil
    
    // MARK: - Netwoking Method
    func login(email:String, password: String, completionHandler: @escaping (User?, NetworkingError?) -> Void){
        // URL Session with database for login
        let url = URL(string:"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCTryhlVmmRHYE7iQT3k0eeNRHIKsTMpRw")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Login Body
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
            
            //                        if let data = data, let body = String(data: data, encoding: .utf8){
            //                            print(body)
            //                        }
            
            //                        if let error = error {
            //                            print("Error: \(error)")
            //                        }
            //
            //                        if let response = response{
            //                            print("Response: \(response)")
            //                        }
            
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let user = try? jsonDecoder.decode(User.self, from: data){
                    returnedUser = user
                    self.loggedInUser = user
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
    
    // MARK: - Country Method
    
    func getCountryData(completionHandler: @escaping ([Country]?, CountryError?) -> Void){
        // URL session for country data
        let urlCountires = URL(string:"https://firestore.googleapis.com/v1/projects/mad-course-3ceb1/databases/(default)/documents/countries?pageSize=1000&orderBy=name")!
        var requestCountry = URLRequest(url: urlCountires)
        requestCountry.httpMethod = "GET"
        if let loggedInUser = loggedInUser {
            requestCountry.setValue("Bearer \(loggedInUser.idToken)", forHTTPHeaderField: "Authorization")
        }
        let dataTask = session.dataTask(with: requestCountry) { (data, response, error) in
            
            var countries: [Country]? = nil
            var returnedError: CountryError? = nil
            
            //            if let data = data, let body = String(data: data, encoding: .utf8){
            //                print(body)
            //            }
            //            if let error = error {
            //                print(error)
            //            }
            //            if let response = response {
            //                print(response)
            //            }
            
            if let noInternetError = error as NSError?{
                if noInternetError.code == -1009 {
                    returnedError = .noInternetError
                }
            }
            
            if let returnedResponse = response as? HTTPURLResponse {
                if returnedResponse.statusCode != 200{
                    returnedError = .requestError
                }
            }
            
            let jsonDecoder = JSONDecoder()
            if let data = data {
                jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                if let returnedResponse = try? jsonDecoder.decode(DocumentsContainer.self, from: data){
                    countries = returnedResponse.documents
                }
                if let error = try? jsonDecoder.decode(RootCountyResponseError.self, from: data){
                    switch error.error.code{
                    case 404: // Server Not Found
                        returnedError = .notFoundError
                    case 403: // Permission Denied Error
                        returnedError = .permissionError
                    case 401: // Unauthenticate Error
                        returnedError = .authenticateError
                    default:
                        returnedError = .unknownError
                    }
                }
            }
            if countries == nil && returnedError == nil {
                returnedError = .unknownError
            }
            DispatchQueue.main.async {
                completionHandler(countries, returnedError)
            }
        }
        dataTask.resume()
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
