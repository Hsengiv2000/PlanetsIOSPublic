//
//  PaymentModel.swift
//  CurrencyApp
//
//  Created by BigoSG on 8/12/22.
//

import Foundation

public struct HTTPPaymentModel {
    public struct RequestPaymentIntentParam: Codable {
        let groupID: GroupID
        let amount: Int
        let kickoutTime: Int?
        
        private enum CodingKeys: String, CodingKey {
            case groupID = "group_id"
            case amount
            case kickoutTime = "kickout_time"
        }
    }
    
    public struct PaymentIntentResponseObject: Codable {
        let customer: String
        let paymentIntent: String
        let ephemeralKey: String
        let publishableKey: String
        
        private enum CodingKeys: String, CodingKey {
            case customer
            case paymentIntent
            case ephemeralKey
            case publishableKey
        }
    }
    
    public struct AllPaymentsResponseObject: Codable {
        let purchases: [IndividualPaymentResponseObject]
        
        private enum CodingKeys: String, CodingKey {
            case purchases
        }
    }
    
    public struct IndividualPaymentResponseObject: Codable {
        let createdAt: Float
        let amount: Float
        let currency: String
        let groupID: String
        
        private enum CodingKeys: String, CodingKey {
            case createdAt = "created_at"
            case amount
            case currency
            case groupID = "group_id"
        }
    }
}

public struct PaymentIntentResponse {
    let customer: String
    let paymentIntent: String
    let ephemeralKey: String
    let publishableKey: String
    
    public init(httpPaymentResponseObject: HTTPPaymentModel.PaymentIntentResponseObject) {
        self.customer = httpPaymentResponseObject.customer
        self.paymentIntent = httpPaymentResponseObject.paymentIntent
        self.ephemeralKey = httpPaymentResponseObject.ephemeralKey
        self.publishableKey = httpPaymentResponseObject.publishableKey
    }
}


public struct IndividualPaymentModel {
    let createdAt: Float
    let amount: Float
    let currency: String
    let groupID: String
    
    public init(createdAt: Float, amount: Float, currency: String, groupID: String) {
        self.createdAt = createdAt
        self.amount = amount
        self.currency = currency
        self.groupID = groupID
    }
    
    public init(responseObject: HTTPPaymentModel.IndividualPaymentResponseObject) {
        self.createdAt = responseObject.createdAt
        self.amount = responseObject.amount
        self.currency = responseObject.currency
        self.groupID = responseObject.groupID
    }
}
