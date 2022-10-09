//
//  HTTPErrors.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 3/11/22.
//

import Foundation
import Result

public struct HTTPServerError<T: CustomStringConvertible>: Error, CustomStringConvertible {
    public var info: T
    
    public var description: String {
        return info.description
    }
}

public struct HTTPStatusError: Error {
    public let status: Int
    public let responseData: Data?
    
    public init(status: Int, responseData: Data?) {
        self.status = status
        self.responseData = responseData
    }
    
    public var isNotAuthorized: Bool {
        return status == HTTP.Status.unAuthorized.rawValue || status == HTTP.Status.forbidden.rawValue
    }
    
    public var isClientError: Bool {
        return status == HTTP.Status.badRequest.rawValue
    }
    
    public var isNotFound: Bool {
        return status == HTTP.Status.notFound.rawValue
    }
    
    public var isConflictError: Bool {
        return status == HTTP.Status.conflict.rawValue
    }
    
    public var isInternalServerError: Bool {
        return status == HTTP.Status.internalServerError.rawValue
    }
    
    public var isTooManyRequests: Bool {
        return status == HTTP.Status.tooManayRequests.rawValue
    }
    
    public var isGatewayTimeout: Bool {
        return status == HTTP.Status.gatewayTimeout.rawValue
    }
    
    public var isPreconditionFailed: Bool {
        return status == HTTP.Status.preconditionFailed.rawValue
    }
}

extension HTTPStatusError: NetworkError {
    var isRecoverableOnBetterNetwork: Bool {
        return false
    }
    
    var isRecoverableOnLogin: Bool {
        return false
    }
}

public struct HTTPConnectionError: Error {
    public let inner: Error
}

public struct HTTPFallbackDomainGiveupError: Error {
    public let inner: Error
}

public struct HTTPComposeURLFailed: Error {
    public let inner: Error?
}

extension HTTPConnectionError: NetworkError {
    var isRecoverableOnBetterNetwork: Bool {
        return true
    }
    
    var isRecoverableOnLogin: Bool {
        let error = inner as NSError
        if error.domain == NSURLErrorDomain, error.code == NSURLErrorNotConnectedToInternet {
            // If I'm not connected (airplane mode), I can definitely recover on login
            return true
        }
        return false
    }
}

protocol NetworkError {
    var isRecoverableOnLogin: Bool {get}
    var isRecoverableOnBetterNetwork: Bool {get}
}

extension NetworkError {
    
    var isRecoverableOnLogin: Bool {
        return false
    }
    
    var isRecoverableOnBetterNetwork: Bool {
        if let nsError = self as? NSError {
            let acceptableCodes = [NSURLErrorTimedOut,
                                   NSURLErrorNotConnectedToInternet]
            return nsError.domain == NSURLErrorDomain && acceptableCodes.contains(nsError.code)
        }
        return false
    }
}

extension AnyError: NetworkError {
    
    var isRecoverableOnLogin: Bool {
        return (error as? NetworkError)?.isRecoverableOnLogin ?? false
    }
    
    var isRecoverableOnBetterNetwork: Bool {
        return (error as? NetworkError)?.isRecoverableOnBetterNetwork ?? false
    }
}
