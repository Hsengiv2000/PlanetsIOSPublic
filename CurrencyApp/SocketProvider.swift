//
//  SocketProvider.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 26/10/22.
//

import Foundation
import SocketIO
import ReactiveSwift


public enum SocketEvent {
    case userJoined(UserJoinLeaveGroupEventModel)
    case userLeft(UserJoinLeaveGroupEventModel)
    case newMessage(Message)
}

class SocketProvider {
    private let socket: SocketIOClient
    private let manager: SocketManager
    private var userModel: UserModel?
    let acknowledgeSignal: STSignal<Bool>
    private let acknowledgeSignalObserver: STSignal<Bool>.Observer
    
    let socketEventSignal: STSignal<SocketEvent>
    private let socketEventSignalObserver: STSignal<SocketEvent>.Observer
    
    
    init() {
        self.manager = SocketManager(socketURL: URL(string: "http://116.86.229.147:4000")!, config: [.log(true), .compress, .reconnects(true)])
        self.socket = manager.defaultSocket

        (acknowledgeSignal, acknowledgeSignalObserver) = STSignal.pipe()
        (socketEventSignal, socketEventSignalObserver) = STSignal.pipe()
//        socket.on("currentAmount") {data, ack in
//            guard let cur = data[0] as? Double else { return }
//            
//            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
//                
//
//                socket.emit("update", ["amount": cur + 2.50])
//            }
//
//            ack.with("Got your currentAmount", "dude")
//        }
        
    }
    
    public func connect(userModel: UserModel) {
        self.userModel = userModel
        
        socket.connect()
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("socket connected")
            guard let me = self else { return }
            //todo retry
            me.socket.emit("establishUser", ["userid": userModel.userID, "username": userModel.username ], completion: { [weak me] in
                guard let myself = me else { return }
                myself.acknowledgeSignalObserver.send(value: true)
                myself.acknowledgeSignalObserver.sendCompleted()
            })
        }
        
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    public func setupEvents() {
        socket.on("userJoined") { [weak self] (data, ack) in
            guard let me = self else { return }
            guard let dataInfo = data.first else { return }
            print("DATA TYPE IS")
            print(type(of: dataInfo))
            print(dataInfo)
            print("BROTHER IS HERE")
        
            
            if let httpUserJoinModel: HTTPUserModel.UserJoinLeaveGroupEvent = try? me.convert(data: dataInfo) {
            let userJoinedEventModel = UserJoinLeaveGroupEventModel(httpUserJoinLeaveGroupEventModel: httpUserJoinModel)
            me.socketEventSignalObserver.send(value: .userJoined(userJoinedEventModel))
            }
        }
        
        socket.on("userLeft") { [weak self] (data, ack) in
            guard let me = self else { return }
            
            guard let dataInfo = data.first else { return }
            
            if let httpUserLeaveModel: HTTPUserModel.UserJoinLeaveGroupEvent = try? me.convert(data: dataInfo) {
            let userLeaveEventModel = UserJoinLeaveGroupEventModel(httpUserJoinLeaveGroupEventModel: httpUserLeaveModel)
            me.socketEventSignalObserver.send(value: .userLeft(userLeaveEventModel))
            }
        }
        
        socket.on("newMessage") { [weak self] (data, ack) in
            guard let me = self else { return }
            
            guard let dataInfo = data.first else { return }
            
            if let httpMessageModel: HTTPChatModel.NewMessageModel = try? me.convert(data: dataInfo) {
                let messageModel = Message(httpNewMessageModel: httpMessageModel)
            me.socketEventSignalObserver.send(value: .newMessage(messageModel))
            }
        }
        
        
        
    }
    
    public func joinRoom(groupID: GroupID, threadID: ThreadID?) {
        if let threadID = threadID {
            socket.emit("joinRoom", ["groupid": groupID, "threadid": threadID], completion: {})
        } else {
            socket.emit("joinRoom", ["groupid": groupID], completion: {})
        }
    }
    
    public func leaveRoom(groupID: GroupID, threadID: ThreadID?) {
        if let threadID = threadID {
            socket.emit("leaveRoom", ["groupid": groupID, "threadid": threadID], completion: {})
        } else {
            socket.emit("leaveRoom", ["groupid": groupID], completion: {})
        }
    }
    
    public func sendTextMessage(text: String, groupid: GroupID, threadID: ThreadID?) {
        guard let userModel = userModel else {
            return
        }
        if let threadID = threadID  {
            socket.emit("sendMessage", ["senderid": userModel.userID, "groupid": groupid, "threadid": threadID,  "message": text], completion: {})
        } else {
            socket.emit("sendMessage", ["senderid": userModel.userID, "groupid": groupid, "message": text], completion: {})
        }
        
        
    }
    
    public func sendImageMessage(imageURLString: String, groupid: GroupID, threadID: ThreadID?) {
        guard let userModel = userModel else {
            return
        }
        if let threadID = threadID  {
            socket.emit("sendMessage", ["senderid": userModel.userID, "groupid": groupid, "threadid": threadID,  "message": "", "image_url": imageURLString], completion: {})
        } else {
            socket.emit("sendMessage", ["senderid": userModel.userID, "groupid": groupid, "message": "", "image_url": imageURLString], completion: {})
        }
        
        
    }
    
    
}


extension SocketProvider {
    private func convert<T: Decodable>(data: Any) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: jsonData)
    }

    private func convert<T: Decodable>(datas: [Any]) throws -> [T] {
        return try datas.map { (dict) -> T in
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: jsonData)
        }
    }
}
