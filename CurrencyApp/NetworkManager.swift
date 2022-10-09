//
//  NetworkManager.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 26/10/22.
//

import Foundation
import ReactiveSwift
import Result

class NetworkManager {
    
    //todo use sexy enum
    public let SIGNUPURL = "/signup"
    public let LOGINURL = "/login"
    public let LOGOUTURL = "/logout"
    public let baseURL = "http://116.86.229.147:5000"
    public let HELLOWORLDURL = "/"
    public let CREATECHATTHREADURL = "/chat/thread/create"
    public let CREATECHATURL = "/chat/create"
    public let FIREBASEAUTHURL = "/firebaseauth"
    public func RECOMMENDEDCHATSURL(userID: UserID) -> String {
        return "/recommendedChats/" + userID
    }
    public func JOINROOMURL(userID: UserID) -> String {
        return "/user/"+userID+"/chat/join"
    }
    
    public func LEAVEROOMURL(userID: UserID) -> String {
        return "/user/"+userID+"/chat/leave"
    }
    
    public func GETUSERCHATS(userID: UserID) -> String {
        return "/user/" + userID + "/chats"
    }
    
    public func GETPAYMENTURL(userID: UserID) -> String {
        return "/user/" + userID + "/chat/pay"
    }
    public func GETMESSAGES(userID: UserID, groupID: GroupID, threadID: ThreadID?, cursor: Int) -> String  {
        if let threadID = threadID {
            return "/user/"+userID+"/chats/"+groupID+"/"+"thread/"+threadID+"/"+String(cursor)
        }
        return "/user/"+userID+"/chats/"+groupID+"/"+String(cursor)
    }
    
    public func FETCHMEMBERSURL(groupID: GroupID) -> String {
        return "/chat/" + groupID + "/members"
    }
    
    public func UPDATEUSERURL(userID: UserID) -> String {
      return "/user/"+userID+"/update"
    }
    
    public func CHATPACKAGESURL(groupID: GroupID) -> String {
        return "/chat" +  "/packages/" + groupID
    }
    //returns all payments by user
    public func obtainPaymentsURL(userID: UserID) -> String {
        return "/user/"+userID+"/obtain-payments"
    }
    
    //Returns dict of groupid: value
    public func obtainGroupPaymentsURL(userID: UserID) -> String {
        return "/user/"+userID+"/obtain-group-payments"
    }
    
    public typealias OnCompletion = (Int, URLResponse?, Data, Error?) -> Void
    enum StupidErrors: Error {
        case weakError
    }
    
    
    public func request(with urlRequest: URLRequest) -> STSignalProducer<Data> {
        return STSignalProducer {[weak self] (observer, lifetime) in
            guard let me = self else {observer.sendWeakError(); return}
            let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
                guard let me = self else { return }
                if let error = error {
                    print("Error with fetching data: \(error)")
                    observer.send(error: AnyError(error))
                }
                
                if let data = data {
                    observer.send(value: data)
                    observer.sendCompleted()
                }
            })
            lifetime.observeEnded {
                task.cancel()
            }
            
            task.resume()
            
        }.observe(on: QueueScheduler.main)
    }
    
    private func validate(response: URLResponse?, data: Data?) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw InternalError.unknown("Wat. response should never be nil here")
        }
        
        if !httpResponse.statusCode.isHTTPSuccessResponseCode {
            throw HTTPStatusError(status: httpResponse.statusCode, responseData: data)
        }
        
        guard let data = data else {
            throw InternalError.unknown("Wat. Data should never be nil here.")
        }
        
        return data
    }
    
    func getRequest(type: String, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = type
        return request
    }
}

extension Int {
    var isHTTPSuccessResponseCode: Bool {
        return self >= 200 && self < 300
    }
}
