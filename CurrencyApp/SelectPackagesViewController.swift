//
//  SelectPackagesViewController.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 10/2/23.
//

import Foundation
import UIKit

class SelectPackagesViewController: ViewController {
    
    private let selectedPackagesTableView = UITableView().then {
        $0.separatorStyle = .none
    }
    
    private let goatView = UIView().then {
        $0.backgroundColor = .red
    }
    
    private var availablePackages: [ChatGroupPackage] = [] {
        didSet {
            self.selectedPackagesTableView.reloadData()
        }
    }
    private let chatGroupModel: ChatGroupModel
    private let recommendedChatsManager: RecommendedChatsManager
    private let uiFactory: UIFactory
    
    init(chatGroupModel: ChatGroupModel, recommendedChatsManager: RecommendedChatsManager, uiFactory: UIFactory) {
        
        self.uiFactory = uiFactory
        self.recommendedChatsManager = recommendedChatsManager
        self.chatGroupModel = chatGroupModel
        super.init()
        selectedPackagesTableView.dataSource = self
        selectedPackagesTableView.delegate = self
        selectedPackagesTableView.register(PackageCreatorCell.self, forCellReuseIdentifier: "PackageCell")
        selectedPackagesTableView.reloadData()
        self.title = "Select a Package"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goatView.removeFromSuperview()
        view.addSubview(selectedPackagesTableView)
        selectedPackagesTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        recommendedChatsManager.fetchPackagesForGroup(groupID: chatGroupModel.groupID).on(value: {[weak self] chatGroupPackages in
            self?.availablePackages = chatGroupPackages
        }).start()
    }
}

extension SelectPackagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availablePackages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.selectedPackagesTableView.dequeueReusableCell(withIdentifier: "PackageCell") as! PackageCreatorCell
        let currentPackage = self.availablePackages[indexPath.row]
        cell.update(amount: currentPackage.amount, kickoutTime: currentPackage.kickoutTime ?? -1, entryStrategy: self.chatGroupModel.entryStrategy)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
      return "Available Packages"
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(self.uiFactory.checkoutViewController(groupModel: chatGroupModel, chatPackage: availablePackages[ indexPath.row], onPayment: { [weak self] paymentResult, amount, currency in
                            guard let me = self else { return }
                            if case let .completed = paymentResult {
                                me.recommendedChatsManager.removeChat(groupID: me.chatGroupModel.groupID)
                            }
                        }), animated: true)
    }
}


