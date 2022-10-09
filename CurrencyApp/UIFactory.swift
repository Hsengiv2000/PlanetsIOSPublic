//
//  UIFactory.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 18/10/22.
//

import Foundation
import UIKit
import StripePaymentSheet

class UIFactory {
    
    private let authManager: AuthenticationNetworkManager
    private var currentUserManager: CurrentUserManager? = nil
    private var recommendedChatsManager: RecommendedChatsManager? = nil
    private var currentUserChatsManager: CurrentUserChatsManager? = nil
    private let urlSession: URLSession
    private let socketProvider: SocketProvider
    private let firebaseManager: FirebaseManager
    private var checkoutManager: CheckoutManager? = nil
    init(socketProvider: SocketProvider) {
        self.socketProvider = socketProvider
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        authManager = AuthenticationNetworkManager()
        firebaseManager = FirebaseManager()
    }
    
    func setupCurrentUserManagers(userModel: UserModel, logoutCallback: @escaping (()->())) {
        currentUserManager = CurrentUserManager(currentUser: userModel, logoutCallback: logoutCallback)
        recommendedChatsManager = RecommendedChatsManager( currentUser: userModel)
        currentUserChatsManager = CurrentUserChatsManager( currentUser: userModel, currentUserManager: currentUserManager!)
        firebaseManager.setupUser(userModel)
        checkoutManager = CheckoutManager(currentUser: userModel, currentUserChatsManager: currentUserChatsManager!)
    }
    
    func nullifyCurrentUserManager() {
        currentUserManager = nil
    }
    
    func loginLogoutVC(callback: @escaping ((UserModel?)->())) -> LoginLogoutViewController {
        return LoginLogoutViewController(authManager: authManager, callback: callback)
    }
    
    func homeVC() -> HomepageViewController {
        return HomepageViewController(authManager: authManager)
    }
    
    func regularProfileVC() -> RegularProfileViewController {

        
        return RegularProfileViewController(authManager: authManager, currentUserManager: currentUserManager!, uiFactory: self)
    }
    
    func celebProfileVC() -> CelebProfileViewController {

        
        return CelebProfileViewController(authManager: authManager, currentUserManager: currentUserManager!, uiFactory: self)
    }
    
    func recommendedChatsVC() -> RecommendedChatsViewController {
        
        return RecommendedChatsViewController(recommendedChatsManager:  recommendedChatsManager, uiFactory: self)
    }
    
    func myChatsVC() -> MyChatsViewController {
        return MyChatsViewController(currentUserChatsManager: currentUserChatsManager!, uiFactory: self)
    }
    
    func getAuthManager() -> AuthenticationNetworkManager {
        return authManager
    }
    
    func chatWallVC(group: ChatGroupModel, userModel: UserModel) -> ChatWallViewController {
        let chatGroupManager = getChatGroupManager(userModel: userModel, groupModel: group)
        return ChatWallViewController(currentUser: userModel, chatGroupManager: chatGroupManager, uiFactory: self)
    }
    
    private func getChatGroupManager(userModel: UserModel, groupModel: ChatGroupModel) -> ChatGroupManager {
        return ChatGroupManager(userModel: userModel, groupModel: groupModel, socketProvider: socketProvider, firebaseManager: firebaseManager)
    }
    
    func avatarViewController(image: UIImage, callback: @escaping ((String)->())) -> AvatarViewController {

        return AvatarViewController(image: image, uiFactory: self, firebaseManager: firebaseManager, callback: callback)
        
    }
    
    func avatarEditViewController(image: UIImage) -> AvatarEditViewController {
        return AvatarEditViewController(image: image)
    }
    
    func getFirebaseManager() -> FirebaseManager {
        return firebaseManager
    }
    
    func checkoutViewController(groupModel: ChatGroupModel, chatPackage: ChatGroupPackage, onPayment: ((PaymentSheetResult, Float, String)->())?) -> CheckoutViewController {
        return CheckoutViewController(groupModel: groupModel, checkoutManager: checkoutManager!, chatPackage: chatPackage, onPayment: onPayment)
    }
    
    func createGroupVC() -> CreateGroupViewController {
        return CreateGroupViewController(currentUserManager: currentUserManager!, uiFactory: self)
    }
    
    func myCreatedChatsViewController() -> MyCreatedChatsViewController {
        return MyCreatedChatsViewController(currentUserChatsManager: currentUserChatsManager!, uiFactory: self)
    }
    
    func selectPackagesViewController(groupModel: ChatGroupModel) -> SelectPackagesViewController {
        return SelectPackagesViewController(chatGroupModel: groupModel, recommendedChatsManager: self.recommendedChatsManager!, uiFactory: self)
    }
}
