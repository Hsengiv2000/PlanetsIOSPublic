//
//  TabBarViewController.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 16/11/22.
//

import Foundation
import UIKit


class TabBarViewController: UITabBarController {
    
    private let uiFactory: UIFactory
    private let currentUser: UserModel
    init(uiFactory: UIFactory, currentUser: UserModel) {
        self.uiFactory = uiFactory
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = .label
        setupVCs()
    }
    
    func createNavController(for rootViewController: UIViewController,
                             title: String,
                             image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
    
    func setupVCs() {
        viewControllers = [
            createNavController(for: uiFactory.myChatsVC(), title: NSLocalizedString("My Chats", comment: ""), image: UIImage(systemName: "house")!),
            createNavController(for: uiFactory.recommendedChatsVC(), title: NSLocalizedString("Explore", comment: ""), image: UIImage(systemName: "magnifyingglass")!),
            createNavController(for: currentUser.isCeleb ? uiFactory.celebProfileVC() : uiFactory.regularProfileVC(), title: NSLocalizedString("Profile", comment: ""), image: UIImage(systemName: "person")!)
        ]
    }
}
