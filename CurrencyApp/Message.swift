//
//  Message.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 20/11/22.
//

import Foundation
import MessageKit

public struct Message: MessageType {
    
    public var sender: SenderType
    
    public var messageId: String
    
    public var sentDate: Date
    
    public var kind: MessageKind
    
    public var chatThread: ChatThreadModel?
    
    public var threadID: ThreadID?
    
    public var groupID: GroupID
    
    public init(sender: SenderType, messageId: MessageID, groupID: GroupID, sentDate: Date, kind: MessageKind, chatThread: ChatThreadModel? = nil, threadID: ThreadID? = nil) {
        self.sender = sender
        self.messageId = String(messageId)
        self.sentDate = sentDate
        self.kind = kind
        self.sentDate = Date()
        self.chatThread = chatThread
        self.threadID = threadID
        self.groupID = groupID
    }
    
    public init(httpNewMessageModel: HTTPChatModel.NewMessageModel) {
        self.sender = Sender(senderID: httpNewMessageModel.senderID, displayName: httpNewMessageModel.senderName)
        self.messageId = String(httpNewMessageModel.messageID)
        self.sentDate = Date(timeIntervalSince1970: TimeInterval(httpNewMessageModel.timestamp))
        self.chatThread = httpNewMessageModel.thread == nil ? nil :  ChatThreadModel(httpChatThreadModel: httpNewMessageModel.thread!)
        self.threadID = httpNewMessageModel.threadID
        self.groupID = httpNewMessageModel.groupID
        
        if httpNewMessageModel.imageURL == nil {
            self.kind = .text(httpNewMessageModel.message)
        } else if let imageURLString = httpNewMessageModel.imageURL {
            self.kind = .photo(MediaMessage(url: URL(string: imageURLString), image: nil, placeholderImage: UIImage(systemName: "magnifyingglass")!, size: CGSize(width: 250, height: 250)))
        } else {
            self.kind = .text(httpNewMessageModel.message)
        }
    }
    
}


public struct MediaMessage: MediaItem {
    public var url: URL? = nil

    public var image: UIImage? = nil

    public var placeholderImage: UIImage = UIImage(systemName: "magnifyingglass")!

    public var size: CGSize = CGSize(width: 150, height: 150)
    
    
}
