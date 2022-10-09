//
//  CurrentUserManager.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 16/11/22.
//

import Foundation
import ReactiveSwift

class CurrentUserManager: NetworkManager {
    
    
    private let _currentUser = MutableProperty<UserModel>(UserModel())
    let currentUser: Property<UserModel>
    let logoutCallback: (()->())
    var paymentDict: [GroupID: [IndividualPaymentModel]] = [:]
    var groupAmountDict: [GroupID: Float] = [:]
    var paymentList: [IndividualPaymentModel] = []
    var groupIDMap: [GroupID:String] = [:]
    var userID: UserID {
        return currentUser.value.userID
    }
    
    var email: String {
        return currentUser.value.email
    }
    
    var username: String  {
        return currentUser.value.username
        
    }
    
    var imageURL: String? {
        return currentUser.value.imageURL
    }
    
    init(currentUser: UserModel, logoutCallback: @escaping (()->())) {
        self.logoutCallback = logoutCallback
        self.currentUser = Property(capturing: _currentUser)
        _currentUser.value = currentUser
        super.init()
        obtainUserPayments().start()
    }
    
    
    func logout() -> STSignalProducer<NoValue> {
        guard let url = URL(string: baseURL+LOGOUTURL) else { return .weakError }
        var requestObject = getRequest(type: "POST", url: url)
        return request(with: requestObject).on(value: {[weak self] _ in
            
            self?.logoutCallback()
        }).mapToNoValue()
//        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in })
//        task.resume()
    }
    
    
    func updateAvatar(urlString: String) -> STSignalProducer<NoValue> {
        guard let url = URL(string: baseURL+UPDATEUSERURL(userID: userID)) else { return .weakError }
        var requestObject = getRequest(type: "POST", url: url)
        do {
            requestObject.httpBody = try JSONEncoder().encode( HTTPUserModel.AvatarUpdateParams(imageURL: urlString))
        } catch let error {
          print(error.localizedDescription)
            return .weakError
        }
        
        return request(with: requestObject).on(value: {[weak self] userData in
            guard let me = self else { return }
            if let userModel = try? JSONDecoder().decode(HTTPUserModel.UserReply.self, from: userData) {
                me._currentUser.value = UserModel(httpUserModel: userModel)
            }
            
        }).mapToNoValue()
    }
    
    func appendPayment(individualPaymentObject: IndividualPaymentModel) {
        if let _ = paymentDict[individualPaymentObject.groupID] {
            paymentDict[individualPaymentObject.groupID]!.append(individualPaymentObject)
        } else {
            paymentDict[individualPaymentObject.groupID] = [individualPaymentObject]
        }
        
        if let _ = groupAmountDict[individualPaymentObject.groupID] {
            groupAmountDict[individualPaymentObject.groupID]! += individualPaymentObject.amount
        } else {
            groupAmountDict[individualPaymentObject.groupID] = individualPaymentObject.amount
        }
        paymentList.append(individualPaymentObject)
    }
    
    func obtainUserPayments() -> STSignalProducer<[GroupID: [IndividualPaymentModel]]> {
        guard let url = URL(string: baseURL + obtainPaymentsURL(userID: userID)) else { return .weakError }
        
        let requestObject = getRequest(type: "GET", url: url)
        return request(with: requestObject).flatMapLatest ({ [weak self] data -> STSignalProducer<[GroupID: [IndividualPaymentModel]]> in
            guard let me = self else { return .weakError }
            if let paymentsModel = try? JSONDecoder().decode(HTTPPaymentModel.AllPaymentsResponseObject.self, from: data) {
                me.groupAmountDict = [:]
                me.paymentDict = [:]
                let individualPayments = paymentsModel.purchases.map {IndividualPaymentModel(responseObject: $0)}
                me.paymentList = individualPayments
                for payment in individualPayments {
                    if let _ = me.paymentDict[payment.groupID] {
                        me.paymentDict[payment.groupID]!.append(payment)
                    } else {
                        me.paymentDict[payment.groupID] = [payment]
                    }

                    if let _ = me.groupAmountDict[payment.groupID] {
                        me.groupAmountDict[payment.groupID]! += payment.amount
                    } else {
                        //TODO currency handling
                        me.groupAmountDict[payment.groupID] = payment.amount
                    }
                }

                return STSignalProducer(value: me.paymentDict)
            } else {
                return .weakError
            }
        })
    }
    
    func createGroupChat(groupName: String, imageURLString: String, limit:Int, groupDescription: String, entryStrategy: GroupEntryStrategy, expiryTime: Double, packages: [ChatGroupPackage] ) -> STSignalProducer<NoValue> {
        guard let url = URL(string: baseURL + CREATECHATURL) else { return .weakError }
        var urlRequest = getRequest(type: "POST", url: url)
        print("CRETING GROUP W ENTRY STRATEGY", entryStrategy.title)
        var httpPackages = packages.map { HTTPChatModel.ChatGroupPackage(amount: $0.amount, kickoutTime: $0.kickoutTime)}
        
        do {
            switch entryStrategy {
            case .joinDuringGroupStartTime(let startTime), .joinDuringGroupStartTimeUntilKickout(let startTime):
                urlRequest.httpBody = try JSONEncoder().encode( HTTPChatModel.CreateChatGroupObject(groupName: groupName, startTime: startTime, expiryTime: expiryTime , userID: currentUser.value.userID, thumbnailURL: imageURLString, entryStrategy: entryStrategy.entryStrategy ,limit: limit, groupDescription: groupDescription, packages: httpPackages))
            default:
                
                urlRequest.httpBody = try JSONEncoder().encode( HTTPChatModel.CreateChatGroupObject(groupName: groupName, startTime: nil, expiryTime: expiryTime, userID: currentUser.value.userID, thumbnailURL: imageURLString, entryStrategy: entryStrategy.entryStrategy ,limit: limit, groupDescription: groupDescription, packages: httpPackages))
            
            }

        } catch let error {
          print(error.localizedDescription)
            return .weakError
        }
        
        return request(with: urlRequest).mapToNoValue()

    }
    
    
}
