//
//  CurrentUserChatsManager.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 12/12/22.
//

import Foundation
import ReactiveSwift

class CurrentUserChatsManager: NetworkManager {
    
    let currentUser: UserModel
    private let _userChats = MutableProperty<[ChatGroupModel]>([])
    public let userChats: Property<[ChatGroupModel]>
    private let currentUserManager: CurrentUserManager
    public var userID: UserID {
        return currentUser.userID
    }
    public var paymentDict: [GroupID: [IndividualPaymentModel]] {
        return currentUserManager.paymentDict
    }
    public var groupAmountDict: [GroupID: Float] {
        return currentUserManager.groupAmountDict
    }
    public var currentUserID: UserID {
        return currentUserManager.userID
    }
    var groupIDMap: [GroupID: String] = [:] {
        didSet {
            currentUserManager.groupIDMap = groupIDMap
        }
    }
    
    init(currentUser: UserModel, currentUserManager: CurrentUserManager) {
        self.currentUser = currentUser
        self.userChats = Property(capturing: _userChats)
        self.currentUserManager = currentUserManager
        super.init()
        
        self.userChats.signal.take(duringLifetimeOf: self).observeValues { [weak self] values in
            self?.groupIDMap = Dictionary(uniqueKeysWithValues: values.map {($0.groupID, $0.groupName)})
        }
    }
    
    public func fetchUserChats() {
    
        guard let url = URL(string: baseURL + (GETUSERCHATS(userID: currentUser.userID))) else { return }
        let urlRequest = getRequest(type: "GET", url: url)
        request(with: urlRequest).on(value: { [weak self] data in
            guard let me = self else { return }
            if let groupChats = try? JSONDecoder().decode(HTTPChatModel.GroupChats.self, from: data) {
                me._userChats.value = groupChats.groups.map {ChatGroupModel(httpChatModel: $0)}
            }
            
        }).on(failed: { [weak self] failure in
            print(failure)
            print("failed to fetch my user chats:")
        }).start()
    }
    
    public func joinGroup(groupID: GroupID) -> STSignalProducer<NoValue> {
        guard let url = URL(string: baseURL + JOINROOMURL(userID: currentUser.userID)) else { return .weakError }
        var urlRequest = getRequest(type: "POST", url: url)
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode( HTTPChatModel.JoinGroupModel(groupID: groupID))
        } catch let error {
          print(error.localizedDescription)
            return .weakError
        }
        
        return request(with: urlRequest).mapToNoValue()
    }
    
    public func removeChat(groupID: GroupID) {
        var temp = userChats.value
        temp.removeAll(where: {$0.groupID == groupID})
        _userChats.value = temp
    }
    
    func appendPayment(individualPaymentObject: IndividualPaymentModel) {
        currentUserManager.appendPayment(individualPaymentObject: individualPaymentObject)
    }
    
    public func leaveGroup(groupID: GroupID) -> STSignalProducer<NoValue> {
        guard let url = URL(string: baseURL + LEAVEROOMURL(userID: currentUser.userID)) else { return .weakError }
        var urlRequest = getRequest(type: "POST", url: url)
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode( HTTPChatModel.LeaveGroupModel(groupID: groupID))
        } catch let error {
          print(error.localizedDescription)
            return .weakError
        }
        
        return request(with: urlRequest).on(value: { [weak self] _ in
            guard let me = self else { return }
            me.removeChat(groupID: groupID)
        }).mapToNoValue()
    }
}
