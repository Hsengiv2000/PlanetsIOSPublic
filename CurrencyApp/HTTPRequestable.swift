//
//  HTTPRequestable.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 4/11/22.
//

import Foundation

public protocol HTTPURLParam {
    var path: String? { get }
    func toStringDict() -> [String: String]
}

public protocol HTTPRequestable: CustomStringConvertible {
    associatedtype URLParamT: HTTPURLParam
    associatedtype BodyParamT: Codable
    associatedtype ReplyT: Decodable
    associatedtype ErrorInfoT: Codable, CustomStringConvertible = HTTP.EmptyParam
    
    var method: HTTP.Method { get }
    var type: HTTP.RequestType { get }
    var timeout: TimeInterval { get }
    
    var contentType: HTTP.ContentType { get }
    var customHeaders: HTTP.RequestHeaders { get }
    
    var replyContentType: HTTP.ReplyContentType { get }
    
    var urlParam: URLParamT { get }
    var bodyParam:  BodyParamT { get }
    var url: URL { get }
    
    func buildRequestBody() throws -> Data?
}

// MARK: - Request
extension HTTPRequestable {
    func urlRequest(compulsaryHeaders: [String : String]) throws -> URLRequest {
        
        var baseURL = url
        if let path = urlParam.path {
            baseURL.appendPathComponent(path)
        }
        
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw InternalError.invalidContent("Invalid URL")
        }
        
        let existingItems = urlComponents.queryItems ?? []
        
        urlComponents.queryItems = existingItems + urlParam.toStringDict().map({ (arg) -> URLQueryItem in
            let (key, value) = arg
            return URLQueryItem(name: key, value: value)
        })
        
        guard let url = urlComponents.url else {
            throw InternalError.invalidContent("Invalid url params")
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)

        if let contentTypeString = contentType.contentTypeString() {
            request.setValue(contentTypeString, forHTTPHeaderField: "Content-Type")
        }

        if let body = try buildRequestBody() {
            request.httpBody = body
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        }

        for header in compulsaryHeaders {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        for header in customHeaders.headers {
            request.setValue(header.headerValue, forHTTPHeaderField: header.headerField)
        }

        request.httpMethod = method.rawValue
        
        return request
    }
}

// MARK: - Response
extension HTTPRequestable {
    func convertToReply(data: Data) throws -> ReplyT {
        if ReplyT.self == HTTP.EmptyParam.self {
            return HTTP.EmptyParam() as! Self.ReplyT
        }
        
        switch replyContentType {
        case .json:
            let reply: ReplyT = try jsonDecode(data: data)
            return reply
        case .data:
            guard let replyData = data as? ReplyT else {
                assertionFailure()
                throw InternalError.invalidContent("Expected ReplyT to be Data when replyContentType is .data")
            }
            return replyData
        }
    }
    
    func convertToErrorInfo(data: Data) throws -> ErrorInfoT {
        let info: ErrorInfoT = try jsonDecode(data: data)
        return info
    }
    
    private func jsonDecode<ResultT: Decodable>(data: Data) throws -> ResultT {
        let decoder = JSONDecoder()
        let reply = try decoder.decode(ResultT.self, from: data)
        return reply
    }
}

extension HTTPRequestable where Self.ReplyT == HTTP.EmptyParam {
    func convertToReply(data: Data) throws -> ReplyT {
        return HTTP.EmptyParam()
    }
}

// MARK: Protocol
extension HTTPRequestable {
    public var description: String {
        return "\(method.rawValue) \(url.absoluteString) Timeout: \(timeout) bodyParam: \(bodyParam)"
    }
}
