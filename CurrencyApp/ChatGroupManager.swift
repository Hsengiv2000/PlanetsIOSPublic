//
//  ChatGroupManager.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 20/11/22.
//

import Foundation
import UIKit

class ChatGroupManager: NetworkManager {
    
    public let currentUser: UserModel
    public let currentGroup: ChatGroupModel
    private let socketProvider: SocketProvider
    public var messages: [Message] = []
    public let newMessageSignal: STSignal<Message>
    private let newMessageSignalObserver: STSignal<Message>.Observer
    public let onlineSignal: STSignal<Int>
    private let onlineSignalObserver: STSignal<Int>.Observer
    private var onlineCount: Int = 1
    public var groupMembers: [UserModel] = []
    
    public var canChat: Bool {
        guard let chatThread = currentGroup.chatThread else { return true }
        return chatThread.celebID == currentUser.userID || chatThread.userID == currentUser.userID
    }
    
    private let firebaseManager: FirebaseManager
    
    public init(userModel: UserModel, groupModel: ChatGroupModel, socketProvider: SocketProvider, firebaseManager: FirebaseManager) {
        self.currentUser = userModel
        self.currentGroup = groupModel
        self.socketProvider = socketProvider
        self.firebaseManager = firebaseManager
        (newMessageSignal, newMessageSignalObserver) = STSignal.pipe()
        (onlineSignal, onlineSignalObserver) = STSignal.pipe()
        super.init()
        setupEvents()
    }
    
    
    public func setupEvents() {
        socketProvider.socketEventSignal.take(duringLifetimeOf: self).observeResult { [weak self] result in
            guard let me = self else { return }
            if case let .success(socketEvent) = result {
                print("SOCKET RECEIVED GOAT", socketEvent)
                switch socketEvent {
                case .newMessage(let messageObject):
                    print("me.messages ", me.messages.count)
                    print("MESSAGE OBJECT IS LOL", messageObject)
                    if let message = messageObject as? Message, message.groupID == me.currentGroup.groupID, message.threadID == me.currentGroup.chatThread?.threadID {
                        print("append happening")
                        me.newMessageSignalObserver.send(value: messageObject)
                    } else {
                        print("ERROR WE HAVE SOME MESSAGE PARSING ISSUES")
                    }
                case .userLeft(let joinLeaveEvent):
                    
                    me.onlineSignalObserver.send(value: me.onlineCount - 1)
                    me.onlineCount -= 1
                case .userJoined(let joinLeaveEvent):
                    
                    me.onlineSignalObserver.send(value: me.onlineCount + 1)
                    me.onlineCount += 1
                    
                    
                }
            }
            
        }
        
        if currentGroup.chatThread == nil {
            fetchGroupMembers().on(value: {[weak self] members in
                guard let me = self else { return }
                me.groupMembers = members
            }).start()
        }
    }
    
    public func joinRoom() {
        socketProvider.joinRoom(groupID: currentGroup.groupID, threadID: currentGroup.chatThread?.threadID)
    }
    
    public func leaveRoom() {
        socketProvider.leaveRoom(groupID: currentGroup.groupID, threadID: currentGroup.chatThread?.threadID)
    }
    
    public func sendMessage(text: String) {
        socketProvider.sendTextMessage(text: text, groupid: currentGroup.groupID, threadID: currentGroup.chatThread?.threadID)
    }
    
    public func fetchMessages(cursor: Int = 0) -> STSignalProducer<NoValue>{
    
        let urlString = baseURL + GETMESSAGES(userID: currentUser.userID, groupID: currentGroup.groupID, threadID: currentGroup.chatThread?.threadID, cursor: messages.count)
      
                
        guard let url = URL(string: urlString) else { return  .weakError }
        let urlRequest = getRequest(type: "GET", url: url)
        return request(with: urlRequest).on(value: {[weak self] messages in
           
            if let messages = try? JSONDecoder().decode(HTTPChatModel.FetchMessagesModel.self, from: messages) {
                guard let me = self else { return }
                var temp = messages.messages.map({Message(httpNewMessageModel: $0)})
                temp.reverse()
                if me.messages.count == 0 {
                    me.messages = temp
                } else {
                    me.messages.insert(contentsOf: temp, at: 0)
                }
            }
            
        }).mapToNoValue()
    }
    
    public func createThread(message: Message, index: Int) -> STSignalProducer<ChatThreadModel> {
        guard let url = URL(string: baseURL + CREATECHATTHREADURL) else { return  .weakError }
        var urlRequest = getRequest(type: "POST", url: url)
        do {
            urlRequest.httpBody = try JSONEncoder().encode( HTTPChatModel.CreateThreadParams(celebID: currentGroup.celebID, senderID: message.sender.senderId, groupID: currentGroup.groupID, messageID: message.messageId))
        } catch let error {
          print(error.localizedDescription)
            return .weakError
        }
        return request(with: urlRequest).flatMapLatest { [weak self] thread -> STSignalProducer<ChatThreadModel> in
            guard let me = self else { return .weakError }
            if let chatThread = try? JSONDecoder().decode(HTTPChatModel.ChatThread.self, from: thread) {
                let chatThreadModel = ChatThreadModel(httpChatThreadModel: chatThread)
                me.messages[index].threadID = chatThreadModel.threadID
                return STSignalProducer(value: chatThreadModel)
            } else {
                return .weakError
            }
            
        }
    }
    
    public func fetchGroupMembers() -> STSignalProducer<[UserModel]> {
        
        guard let url = URL(string: baseURL + FETCHMEMBERSURL(groupID: currentGroup.groupID)) else { return .weakError }
        let urlRequest = getRequest(type: "GET", url: url)
        return request(with: urlRequest).flatMapLatest { [weak self] members -> STSignalProducer<[UserModel]> in
           
            if let groupMembers = try? JSONDecoder().decode(HTTPUserModel.GroupMembers.self, from: members) {
                return STSignalProducer(value: groupMembers.users.map({
                    UserModel(httpUserModel: $0)
                }))
            }
            return STSignalProducer(value: [])
            
        }
        
    }
    
    public func sendImageMessage(photo: UIImage) {
        firebaseManager.uploadImage(image: photo, useCase: .image).on(value: { [weak self] imageURLString in
            guard let me = self else { return }
            me.socketProvider.sendImageMessage(imageURLString: imageURLString, groupid: me.currentGroup.groupID, threadID: me.currentGroup.chatThread?.threadID)
        }).start()
    }
}
