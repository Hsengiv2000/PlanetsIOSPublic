//
//  HTTP.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 3/11/22.
//

import Foundation
import Result

public enum HTTPRequest {}

public enum HTTP {}

// MARK: - Request
extension HTTP {
    public struct EmptyParam: Codable, HTTPURLParam, CustomStringConvertible {
        public let description: String = ""
        
        public let path: String? = nil
        public func toStringDict() -> [String : String] {
            return [:]
        }
        
        public init() {}
    }

    public struct EmptyReply: Codable {}
    
    public struct Constants {
        public static let defaultTimeout: TimeInterval = 60
    }
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
        case patch = "PATCH"
    }
    
    public enum RequestType: Int {
        case none
        case session
        case guestSession
    }
    
    public enum Mime: String {
        case jpg = "image/jpeg"
        case png = "image/png"
        case audio = "audio/*"
        case zip = "application/zip"
        case pdf = "application/pdf"
        case mp4 = "application/mp4"
        case octetStream = "application/octet-stream"
    }
    
    public enum ContentType {
        case empty
        case json
        case form
        case multipart(String)
    }
    
    public class RequestHeaders {
        // Be careful of the naming for header. Do not conflict with standard HTTP header names
        public struct Header {
            public let headerField: String
            public let headerValue: String
        }
        
        public private(set) var headers = [Header]()
        
        public func append(_ header: Header) {
            headers.append(header)
        }
        
        public init() {
            
        }
    }
}

extension HTTP.ContentType {
    func contentTypeString() -> String? {
        switch self {
        case .json:
            return "application/json"
        case .form:
            return "application/x-www-form-urlencoded"
        case .multipart(let boundary):
            return "multipart/form-data; boundary=\(boundary)"
        case .empty:
            return nil
        }
    }
}

// MARK: - Reply
extension HTTP {
    public enum ReplyContentType {
        case json
        case data
    }
}

extension HTTP {
    public enum Status: Int {
        case success = 200
        
        case badRequest = 400
        case unAuthorized = 401
        case forbidden = 403
        case notFound = 404
        case conflict = 409
        case preconditionFailed = 412
        case tooManayRequests = 429
        
        case internalServerError = 500
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
    }
}
