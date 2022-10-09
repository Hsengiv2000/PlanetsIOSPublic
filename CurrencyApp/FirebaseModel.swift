//
//  FirebaseModel.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 26/11/22.
//

import Foundation

public struct HTTPFirebaseModel {
    
    public struct FirebaseAuthRequest: Codable {
        let userID: UserID
        
        private enum CodingKeys: String, CodingKey {
            case userID = "userid"
        }
    }
    
    public struct FirebaseAuthResponse: Codable {
        let authToken: String
        
        private enum CodingKeys: String, CodingKey {
            case authToken = "auth_token"
        }
    }
}
