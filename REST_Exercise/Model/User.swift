//
//  User.swift
//  REST_Exercise
//
//  Created by Dominik Polzer on 11.10.20.
//  Copyright © 2020 Dominik Polzer. All rights reserved.
//

import Foundation


struct User: Codable {
    let kind: String
    let localId: String
    let email: String
    let displayName: String
    let idToken: String // wenn man hier einen leeren String übergibt ist es Permission Denied
    let registered: Bool
    let profilePicture: String
    let refreshToken: String
    let expiresIn: String
    
    
// Code darunter entkommentieren um parsing error zu erzeugen
//    let test1: String
//    var test:Int

}
