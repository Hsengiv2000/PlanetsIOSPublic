//
//  CheckoutManager.swift
//  CurrencyApp
//
//  Created by BigoSG on 8/12/22.
//

import Foundation

class CheckoutManager: NetworkManager {
    
    private let currentUser: UserModel
    public var paymentDict: [GroupID: [IndividualPaymentModel]] {
        return currentUserChatsManager.paymentDict
    }
    public var groupAmountDict: [GroupID: Float] {
        return currentUserChatsManager.groupAmountDict
    }
    public var currentUserID: UserID {
        return currentUserChatsManager.userID
    }
    private let currentUserChatsManager: CurrentUserChatsManager
    
    public init(currentUser: UserModel, currentUserChatsManager: CurrentUserChatsManager) {
        self.currentUser = currentUser
        self.currentUserChatsManager = currentUserChatsManager
        super.init()
    }
    
    public func leaveGroup(groupID: GroupID) -> STSignalProducer<NoValue> {
        return currentUserChatsManager.leaveGroup(groupID: groupID)
    }
    
    public func obtainProductPaymentIntent(groupID: GroupID, amount: Int, kickoutTime: Int?) -> STSignalProducer<PaymentIntentResponse>  {
        guard let url = URL(string: baseURL +  GETPAYMENTURL(userID: currentUser.userID)) else { return .weakError}
        var urlRequest = getRequest(type: "POST", url: url)
        do {
            urlRequest.httpBody = try? JSONEncoder().encode( HTTPPaymentModel.RequestPaymentIntentParam(groupID: groupID, amount: amount, kickoutTime: kickoutTime))
        } catch let error {
          print(error.localizedDescription)
            return .weakError
        }
        
        return request(with: urlRequest).flatMapLatest( { [weak self] data -> STSignalProducer<PaymentIntentResponse>  in
            guard let me = self else { return .weakError }
            if let paymentIntentObject = try? JSONDecoder().decode(HTTPPaymentModel.PaymentIntentResponseObject.self, from: data) {
                let paymentModel = PaymentIntentResponse(httpPaymentResponseObject: paymentIntentObject)
                return STSignalProducer(value: paymentModel)
            } else {
                return .weakError
            }
        })
        
    }
    func appendPayment(individualPaymentObject: IndividualPaymentModel) {
        currentUserChatsManager.appendPayment(individualPaymentObject: individualPaymentObject)
    }
}
