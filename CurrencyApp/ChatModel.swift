//
//  ChatModel.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 18/11/22.
//

import Foundation

public enum JoinPaidStatus: Int, Codable {
    
    case paid = 1, joined = 2, none = 0
}

public enum GroupEntryStrategy: Codable, CaseIterable {
    public static var allCases: [GroupEntryStrategy] = [.joinPermanent, .joinImmediatelyUntilKickout, .joinDuringGroupStartTime(startTime: 45345), .joinDuringGroupStartTimeUntilKickout(startTime: 5433452), .inviteOnly ]
    
    
    case joinDuringGroupStartTime(startTime: Double)
    case joinDuringGroupStartTimeUntilKickout(startTime: Double)
    case joinImmediatelyUntilKickout
    case joinPermanent
    case inviteOnly
    
    var entryStrategy: Int {
        switch self {
        case .joinDuringGroupStartTime:
            return 0
        case .joinDuringGroupStartTimeUntilKickout:
            return 1
        case .joinImmediatelyUntilKickout:
            return 2
        case .joinPermanent:
            return 3
        case .inviteOnly:
            return 4
        }
    }
    
    var description: String {
        switch self {
        case .joinDuringGroupStartTime:
            return "All Users will be added to group at a specific time point. If more users have tried to join group than the groups limit, then users will be probabilistically added. Users who are not added will be refunded their amount"
        case .joinDuringGroupStartTimeUntilKickout:
            return "All Users will be added to group at a specific time  and will be kicked out at a specific time(this could be infinity as well) (unless renewed). If more users have tried to join group than the groups limit, then users will be probabilistically added. Users who are not added will be refunded their amount. "
        case .joinImmediatelyUntilKickout:
            return "Users will be added to the group immediately but kicked out at a specific time(this could be infinity as well) (unless renewed)"
        case .joinPermanent:
            return "immediate joining and permanent membership"
        case .inviteOnly:
            return "Invite only join system"
        }
    }
    
    var title: String {
        switch self {
        case .joinDuringGroupStartTime:
            return "All Users are at Specific Time permanently "
        case .joinDuringGroupStartTimeUntilKickout:
            return "All Users are added at Specific Time but allow for only specific time (could be infinity)"
        case .joinImmediatelyUntilKickout:
            return "Add User at immediately but allow for only specific time (could be infinity)"
        case .joinPermanent:
            return "Users can join anytime and leave anytime as long as group limit available"
        case .inviteOnly:
            return "Invite only"
        }
    }
    
    
}



public struct HTTPChatModel {
    
    public struct GroupChats: Codable {
        let groups: [ChatGroupModel]
        
        private enum CodingKeys: String, CodingKey {
            case groups
        }
    }
    
    
    public struct JoinGroupModel: Codable {
        let groupID: GroupID
        private enum CodingKeys: String, CodingKey {
            case groupID = "group_id"
        }
    }

    public struct LeaveGroupModel: Codable {
        let groupID: GroupID
        private enum CodingKeys: String, CodingKey {
            case groupID = "group_id"
        }
    }
    
    public struct CreateChatGroupObject: Codable {
        let groupName: String
        let startTime: Double? //how much More time
        let expiryTime: Double?
        let userID: UserID
        let thumbnailURL: String
        let entryStrategy: Int
        let limit: Int
        let groupDescription: String
        let packages: [HTTPChatModel.ChatGroupPackage]
        
        private enum CodingKeys: String, CodingKey {
            case groupName = "group_name"
            case startTime = "start_time"
            case expiryTime = "expiry_time"
            case userID = "user_id"
            case thumbnailURL = "thumbnail_url"
            case entryStrategy = "entry_strategy"
            case groupDescription = "group_description"
            case limit
            case packages
        }
    }
    
    public struct ChatGroupPackage: Codable {
        let amount: Int
        let kickoutTime: Int?
        
        private enum CodingKeys: String, CodingKey {
            case kickoutTime = "kickout_time"
            case amount
        }
    }
    
    public struct GroupPackages: Codable {
        let packages: [HTTPChatModel.ChatGroupPackage]
        
        private enum CodingKeys: String, CodingKey {
            case packages
        }
    }
    
    public struct ChatGroupModel: Codable {
        
        let groupID: GroupID
        let groupName: String
        let joinPaidStatus: JoinPaidStatus
        let celebName: String
        let celebID: UserID
        let members: [UserID]
        let chatThread: ChatThread?
        let groupDescription: String?
        let imageURL: String?
        let startTime: Double?
        let entryStrategy: Int?
        let expiryTime: Double
        
        private enum CodingKeys: String, CodingKey {
            case groupID = "group_id"
            case groupName = "group_name"
            case joinPaidStatus = "join_paid_status"
            case celebName = "celeb_name"
            case celebID = "celeb_id"
            case members
            case chatThread = "chat_thread"
            case imageURL = "image_url"
            case groupDescription = "group_description"
            case startTime = "start_time"
            case expiryTime = "expiry_time"
            case entryStrategy = "entry_strategy"
        }
    }
    
    public struct NewMessageModel: Codable {
        let message: String
        let senderID: UserID
        let groupID: GroupID
        let messageID: MessageID
        let timestamp: Timestamp
        let senderName: String
        let thread: ChatThread? //if message contains thread
        let threadID: ThreadID? //thread id if message is part of a thread
        let imageURL: String?
        
        private enum CodingKeys: String, CodingKey {
            case groupID = "group_id"
            case senderID = "sender_id"
            case messageID = "message_id"
            case message
            case timestamp
            case senderName = "sender_name"
            case thread
            case threadID = "thread_id"
            case imageURL = "image_url"
        }
        
    }
    
    public struct ChatThread: Codable {
        let threadID: ThreadID
        let celebID: UserID
        let userID: UserID
        let parentMessageID: MessageID
        let parentGroupID: GroupID
        
        private enum CodingKeys: String, CodingKey {
            case threadID = "thread_id"
            case celebID = "celeb_id"
            case userID = "user_id"
            case parentMessageID = "message_id"
            case parentGroupID = "group_id"
        }
    }
    
    public struct CreateThreadParams: Codable {
        let celebID: UserID
        let senderID: UserID
        let groupID: GroupID
        let messageID: MessageID
        
        private enum CodingKeys: String, CodingKey {
            case celebID = "celeb_id"
            case senderID = "sender_id"
            case groupID = "group_id"
            case messageID = "message_id"
        }
    }
    
    public struct FetchMessagesModel: Codable {
        let messages: [NewMessageModel]
        
        private enum CodingKeys: String, CodingKey {
            case messages
        }
    }
}


public struct ChatGroupModel {
    let groupID: GroupID
    let groupName: String
    let joinPaidStatus: JoinPaidStatus
    let celebID: UserID
    let celebName: String
    var chatThread: ChatThreadModel?
    let groupDescription: String
    let imageURL: String
    let startTime: Double?
    let entryStrategy: GroupEntryStrategy
    
    init(httpChatModel: HTTPChatModel.ChatGroupModel) {
        self.groupID = httpChatModel.groupID
        self.groupName = httpChatModel.groupName
        self.joinPaidStatus = httpChatModel.joinPaidStatus
        self.celebID = httpChatModel.celebID
        self.celebName = httpChatModel.celebName
        self.chatThread = httpChatModel.chatThread == nil ? nil : ChatThreadModel(httpChatThreadModel: httpChatModel.chatThread!)
        self.groupDescription = httpChatModel.groupDescription ?? "This is a placeholder description"
        self.imageURL = httpChatModel.imageURL ?? "https://firebasestorage.googleapis.com/v0/b/planets-image-bucket/o/637f0bd266b29115e91f5319%2FUPLOADEDIMAGES%2F02845FFF-0D00-45A6-B3D0-BF717B58E12F.png?alt=media&token=be3daf23-005e-4762-a456-ed9f0d28f13c"
        self.startTime = httpChatModel.startTime
        if let entry_strat = httpChatModel.entryStrategy {
            switch entry_strat {
            case 0:
                self.entryStrategy = .joinDuringGroupStartTime(startTime: startTime!)
            case 1:
                self.entryStrategy = .joinDuringGroupStartTimeUntilKickout(startTime: startTime!)
            case 2:
                self.entryStrategy = .joinImmediatelyUntilKickout
            case 3:
                self.entryStrategy = .joinPermanent
            case 4:
                self.entryStrategy = .inviteOnly
            default:
                self.entryStrategy = .inviteOnly
            }
        } else {
            self.entryStrategy = .inviteOnly
        }
        
    }
    
    init(groupID: GroupID, groupName: String, joinPaidStatus: JoinPaidStatus, celebID: UserID, celebName: String, chatThread: ChatThreadModel?) {
        self.groupID = groupID
        self.groupName = groupName
        self.joinPaidStatus = joinPaidStatus
        self.celebID = celebID
        self.celebName = celebName
        self.chatThread = chatThread
        self.groupDescription = "This is a placeholder description"
        self.imageURL = "https://firebasestorage.googleapis.com/v0/b/planets-image-bucket/o/637f0bd266b29115e91f5319%2FUPLOADEDIMAGES%2F02845FFF-0D00-45A6-B3D0-BF717B58E12F.png?alt=media&token=be3daf23-005e-4762-a456-ed9f0d28f13c"
        self.startTime = NSDate().timeIntervalSince1970
        self.entryStrategy = .inviteOnly
    }
    
    init(chatGroupModel: ChatGroupModel, chatThread: ChatThreadModel) {
        self = chatGroupModel
        self.chatThread = chatThread
    }
}


public struct ChatThreadModel {
    let threadID: ThreadID
    let celebID: UserID
    let userID: UserID
    let parentMessageID: MessageID
    let parentGroupID: GroupID
    
    init(httpChatThreadModel: HTTPChatModel.ChatThread) {
        self.threadID = httpChatThreadModel.threadID
        self.celebID = httpChatThreadModel.celebID
        self.userID = httpChatThreadModel.userID
        self.parentGroupID = httpChatThreadModel.parentGroupID
        self.parentMessageID = httpChatThreadModel.parentMessageID
    }
}

public struct ChatGroupPackage {
    let amount: Int
    var kickoutTime: Int?
    
    init(httpChatGroupPackageModel: HTTPChatModel.ChatGroupPackage) {
        self.amount = httpChatGroupPackageModel.amount
        self.kickoutTime = httpChatGroupPackageModel.kickoutTime
    }
    
    init(amount: Int, kickoutTime: Int? = nil) {
        self.amount = amount
        self.kickoutTime = kickoutTime
    }
}
