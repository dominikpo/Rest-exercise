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
    let idToken: String
    let registered: Bool
    let profilePicture: String
    let refreshToken: String
    let expiresIn: String
    
}
