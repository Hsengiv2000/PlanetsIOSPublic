//
//  RecommendedChatsManager.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 18/11/22.
//

import Foundation
import ReactiveSwift

class RecommendedChatsManager: NetworkManager {
    
    let currentUser: UserModel
    private let _recommendedChats = MutableProperty<[ChatGroupModel]>([])
    public let recommendedChats: Property<[ChatGroupModel]>
    init(currentUser: UserModel) {
        self.currentUser = currentUser
        self.recommendedChats = Property(capturing: _recommendedChats)
        super.init()
    }
    
    public func fetchRecommendedChats() {
    
        guard let url = URL(string: baseURL + (RECOMMENDEDCHATSURL(userID: currentUser.userID))) else { return }
        let urlRequest = getRequest(type: "GET", url: url)
        request(with: urlRequest).on(value: { [weak self] data in
            guard let me = self else { return }
            if let groupChats = try? JSONDecoder().decode(HTTPChatModel.GroupChats.self, from: data) {
                me._recommendedChats.value = groupChats.groups.map {ChatGroupModel(httpChatModel: $0)}
            }
            
        }).on(failed: { [weak self] failure in
            print(failure)
            print("failed to fetch recommended chats: is recommended")
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
        var temp = recommendedChats.value
        temp.removeAll(where: {$0.groupID == groupID})
        _recommendedChats.value = temp
    }
    
    public func fetchPackagesForGroup(groupID: GroupID) -> STSignalProducer<[ChatGroupPackage]> {
        guard let url = URL(string: baseURL + CHATPACKAGESURL(groupID: groupID)) else { return .weakError }
        
        let urlRequest = getRequest(type: "GET", url: url)
        return request(with: urlRequest).flatMapLatest ({ [weak self]  chatPackagesData -> STSignalProducer<[ChatGroupPackage]> in
            guard let me = self else { return .weakError }
            if let httpChatPackagesModel = try? JSONDecoder().decode(HTTPChatModel.GroupPackages.self, from: chatPackagesData) {
                return STSignalProducer(value: httpChatPackagesModel.packages.map {ChatGroupPackage(httpChatGroupPackageModel: $0)})
            }
            return .weakError
        })
    }
}
