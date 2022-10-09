//
//  ClientSession.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 7/11/22.
//

import Foundation
import UIKit
import ReactiveCocoa
import ReactiveSwift

class ClientSession {
    
    public enum SessionType {
        case user(UserSession)
        case guest(GuestSession)
        case none
        
        var currentUser: UserModel? {
            switch self {
            case .user(let userSession):
                return userSession.currentUser
            default:
                return nil
                
            }
        }
    }
    
    private var sessionType: SessionType = .none
    
    private let uiFactory: UIFactory
    
    public func startUserSession(_ user: UserModel) {
        
        
        
        uiFactory.setupCurrentUserManagers(userModel: user, logoutCallback: { [weak self] in
            self?.startGuestSession()
        } )

        self.sessionType = .user(UserSession(deps: UserSession.Deps(socketProvider: self.socketProvider, authenticationNetworkManager: self.uiFactory.getAuthManager(), firebaseManager: self.uiFactory.getFirebaseManager()), currentUser: user))
               
        self.window?.rootViewController = TabBarViewController(uiFactory: self.uiFactory, currentUser: user)
        window?.makeKeyAndVisible()
        
    }
    
    public func startGuestSession() {
        socketProvider.disconnect()
        self.sessionType = .guest(GuestSession(deps: GuestSession.Deps(authenticationNetworkManager: self.uiFactory.getAuthManager())))
       
        self.window?.rootViewController = UINavigationController(rootViewController: uiFactory.loginLogoutVC(callback: {[weak self]  user in
            guard let user = user else { return }
            self?.startUserSession(user)
        }))
        window?.makeKeyAndVisible()
    }
    
    
    private let window: UIWindow?
    private let socketProvider: SocketProvider
    public init(window: UIWindow?) {
        self.window = window
        self.socketProvider = SocketProvider()
        self.uiFactory = UIFactory(socketProvider: socketProvider)
        self.startGuestSession()
    }
    

}


class UserSession {
    struct Deps {
        let socketProvider: SocketProvider
        let authenticationNetworkManager: AuthenticationNetworkManager
        let firebaseManager: FirebaseManager
    }
    let currentUser: UserModel
    
    init(deps: Deps, currentUser: UserModel) {
        self.deps = deps
        self.currentUser = currentUser
        deps.socketProvider.connect(userModel: currentUser)
        deps.socketProvider.acknowledgeSignal.take(duringLifetimeOf: self).observeResult({ [weak self] result in
            guard let me = self else { return }
            if case let .success = result {
                print("ACKNOWLEDGEMENT RECEIVED GOAT")
                me.deps.socketProvider.setupEvents()
            }
            
        })
    }
    let deps: Deps
}

class GuestSession {
    struct Deps {
        let authenticationNetworkManager: AuthenticationNetworkManager
    }
    init(deps: Deps) {
        self.deps = deps
    }
    let deps: Deps
    
}

