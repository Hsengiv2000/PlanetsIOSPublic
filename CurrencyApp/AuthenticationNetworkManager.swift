//
//  AuthenticationNetworkManager.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 25/10/22.
//

import Foundation

class AuthenticationNetworkManager: NetworkManager {
    
    
    func signup(username: String, email: String, password: String) -> STSignalProducer<NoValue>{
        
        guard let url = URL(string: baseURL+SIGNUPURL) else { return .weakError }
        var urlrequest = getRequest(type: "POST", url: url)
        do {
            urlrequest.httpBody = try JSONEncoder().encode( HTTPUserModel.SignupParams(email: email, username: username, password: password))
        } catch let error {
          print(error.localizedDescription)
            return .weakError
        }
   
        return request(with: urlrequest).mapToNoValue()
    }
    
    func login(username: String, password: String) -> STSignalProducer<UserModel> {
        
        guard let url = URL(string: baseURL+LOGINURL) else { return .weakError }
        var urlrequest = getRequest(type: "POST", url: url)
        do {
            urlrequest.httpBody = try JSONEncoder().encode( HTTPUserModel.LoginParams(username: username, password: password))
        } catch let error {
          print(error.localizedDescription)
            return .weakError
        }
        urlrequest.timeoutInterval = 60.0
        return request(with: urlrequest).flatMapLatest { [weak self] data -> STSignalProducer<UserModel> in
            
            if let httpUserModel = try? JSONDecoder().decode(HTTPUserModel.UserReply.self, from: data) {
                return STSignalProducer(value: UserModel(httpUserModel: httpUserModel))
            }
            return .weakError
        }
    }
    
    func logout() -> STSignalProducer<NoValue> {
        guard let url = URL(string: baseURL+LOGOUTURL) else { return .weakError }
        var urlrequest = getRequest(type: "POST", url: url)
        return request(with: urlrequest).mapToNoValue()
    }
    
    
    func mockHelloWorld() {
        guard let url = URL(string: baseURL+HELLOWORLDURL) else { return }
        var request = getRequest(type: "GET", url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            
        })
        task.resume()
    }
    
}
