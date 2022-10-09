//
//  Sender.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 20/11/22.
//

import Foundation
import MessageKit


public struct Sender: SenderType {
    
    public var senderId: String
    
    public var displayName: String
    
    init(senderID: String, displayName: String) {
        self.senderId = senderID
        self.displayName = displayName
    }
    
}
