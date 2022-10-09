//
//  UserJoinLeaveGroupEvent.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 18/11/22.
//

import Foundation
public extension HTTPUserModel {
    
    struct UserJoinLeaveGroupEvent: Codable {
        let groupID: GroupID
        let userID: UserID
        private enum CodingKeys: String, CodingKey {
            case groupID = "groupid"
            case userID = "userid"
        }
    }
}

public struct UserJoinLeaveGroupEventModel {
    let groupID: GroupID
    let userID: UserID
    init(httpUserJoinLeaveGroupEventModel: HTTPUserModel.UserJoinLeaveGroupEvent) {
        self.groupID = httpUserJoinLeaveGroupEventModel.groupID
        self.userID = httpUserJoinLeaveGroupEventModel.userID
    }
    
    init(groupID: GroupID, userID: UserID) {
        self.groupID = groupID
        self.userID = userID
    }
}
