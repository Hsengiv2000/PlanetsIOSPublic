//
//  InternalErrors.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 3/11/22.
//

import Foundation

public enum InternalError: Error {
    case general(String)
    case invalidContent(String)
    case unknown(String)
    case weakError
    case typeCastFailed(expected: Any, got: Any)
    case unimplemented
    case needsLogin
    case unexpectedNil
    case signalInterrupted
    case wrongContext
    case timeout(String)
    case userCancelled
    case alreadyOngoing
}



extension InternalError: CustomStringConvertible {
    
    public func TXT(_ s: String) -> String {
        return s
    }
    
    public var description: String {
        switch self {
        case .general(let msg):
            return msg
        case .invalidContent(let msg):
            return TXT("error_unknown") + ": Invalid content - \(msg)"
        case .unknown(let msg):
            return TXT("error_unknown") + ": Internal - \(msg)"
        case .weakError:
            return TXT("error_unknown") + ": Weak is nil"
        case let .typeCastFailed(expected: expected, got: got):
            return TXT("error_unknown") + ": Type Error. Expected \(expected) but got \(got)"
        case .unimplemented:
            return TXT("error_unknown") + ": UnImplemented"
        case .needsLogin:
            return TXT("error_unknown") + ": Need Login"
        case .unexpectedNil:
            return TXT("error_unknown") + ": Unexpected nil"
        case .signalInterrupted:
            return TXT("error_unknown") + ": Signal Interrupted"
        case .wrongContext:
            return TXT("error_unknown") + ": Wrong Context"
        case .timeout(let msg):
            return TXT("error_unknown") + ": \(msg)"
        case .userCancelled:
            return TXT("error_unknown") + ": User cancelled"
        case .alreadyOngoing:
            return TXT("error_unknown") + ": Already ongoing"
        }
        
        
    }
}
