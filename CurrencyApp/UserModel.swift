//
//  UserModel.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 25/10/22.
//

import Foundation
public struct HTTPUserModel {
    
    
    public struct SignupParams: Codable {
        let email: String
        let username: String
        let password: String
        
        private enum CodingKeys: String, CodingKey {
            case email
            case username
            case password
        }
    }
    
    public struct LoginParams: Codable {
        let username: String
        let password: String
        
        private enum CodingKeys: String, CodingKey {
            case username
            case password
        }
    }
    
    public struct AvatarUpdateParams: Codable {
        
        let imageURL: String
        
        private enum CodingKeys: String, CodingKey {
            case imageURL = "image_url"
        }
    }
    
    
    public struct GroupMembers: Codable {
        let users: [UserReply]
        
        private enum CodingKeys: String, CodingKey {
            case users
        }
    }
    
    public struct UserReply: Codable {
        let email: String
        let hasConfirmed: Bool
        let userID: UserID
        let username: String
        let imageURL: String?
        let isCeleb: Bool
        private enum CodingKeys: String, CodingKey {
            case email
            case hasConfirmed = "has_confirmed"
            case userID = "id"
            case username
            case isCeleb = "is_celeb"
            case imageURL = "image_url"
        }
    }
}


public struct UserModel {
    let email: String
    let username: String
    let userID: UserID
    let imageURL: String?
    let isCeleb: Bool
    
    public init(httpUserModel: HTTPUserModel.UserReply) {
        self.email = httpUserModel.email
        self.userID = httpUserModel.userID
        self.username = httpUserModel.username
        self.imageURL = httpUserModel.imageURL
        self.isCeleb = httpUserModel.isCeleb
    }
    
    public init() {
        email  = ""
        username = ""
        userID = ""
        imageURL = nil
        isCeleb = false
    }
}
