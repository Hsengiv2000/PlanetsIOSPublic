//
//  SelectPackagesViewController.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 29/1/23.
//

import Foundation
import UIKit

class AddPackagesViewController: ViewController {
    
    
    private let packageCreatorView: PackageCreatorView
    private let addPackagesButton = UIButton().then {
        $0.backgroundColor = .yellow
        $0.layer.borderWidth = 3
        $0.layer.borderColor = UIColor.green.cgColor
        $0.setTitle("Add", for: .normal)
    }
    private let addedPackagesTableView = UITableView().then {
        $0.separatorStyle = .none
    }
    
    private let submitButton = UIButton().then {
        $0.setTitle("Create Group!", for: .normal)
        $0.backgroundColor = .yellow
        $0.layer.borderWidth = 3
        $0.layer.borderColor = UIColor.green.cgColor
    }
    
    private let currentUserManager: CurrentUserManager
    private let groupName: String
    private let imageURLString: String
    private let limit: Int
    private let groupDescriptionText: String
    private let entryStrategy: GroupEntryStrategy
    private let expiryTime: Double
    private let groupExists: Bool
    private var currentPackages: [ChatGroupPackage] = []
    
    init(currentUserManager: CurrentUserManager, groupName: String, imageURLString: String, limit: Int, groupDescriptionText: String, entryStrategy: GroupEntryStrategy, expiryTime: Double, groupExists:Bool = false) {
        
        self.currentUserManager = currentUserManager
        self.groupName = groupName
        self.imageURLString = imageURLString
        self.groupDescriptionText = groupDescriptionText
        self.limit = limit
        self.entryStrategy = entryStrategy
        self.expiryTime = expiryTime
        self.groupExists = groupExists
        packageCreatorView = PackageCreatorView()
        packageCreatorView.update(amount: -1, kickoutTime: -1, entryStrategy: entryStrategy, isEditable: true)
        
        super.init()
        
        addedPackagesTableView.dataSource = self
        addedPackagesTableView.delegate = self
        
        addedPackagesTableView.reloadData()
        
        if groupExists {
            // TODO RAHUL fetch packages
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(packageCreatorView)
        view.addSubview(addPackagesButton)
        view.addSubview(addedPackagesTableView)
        view.addSubview(submitButton)
        
        addPackagesButton.addTarget(self, action: #selector(didTapAddPackage), for: .touchUpInside)
        
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
    }
    
    @objc private func didTapSubmit(_ sender: UIButton) {
        if currentPackages.count == 0 {
            showErrorToast("pls atleast add 1 package")
            return
        }
        currentUserManager.createGroupChat(groupName: groupName, imageURLString: imageURLString, limit: limit, groupDescription: groupDescriptionText, entryStrategy: entryStrategy, expiryTime: expiryTime, packages: currentPackages ).on(starting: { [weak self] in
                    self?.startLoadingAnimation()
                }).on(value: { [weak self] _ in
                    guard let me = self else { return }
                    me.stopLoadingAnimation()
                    
                    me.showSuccessToast("your group has been created")
        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        me.navigationController?.popViewController(animated: true)
                        me.navigationController?.popViewController(animated: true)
                    }
                }).start()
    }
    
    private func setupConstraints() {
        packageCreatorView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.lessThanOrEqualTo(100)
        }
        
        addPackagesButton.snp.makeConstraints { make in
            make.top.equalTo(packageCreatorView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(55)
        }
        
        addedPackagesTableView.snp.makeConstraints { make in
            make.top.equalTo(addPackagesButton.snp.bottom).offset(10)
            make.height.equalTo(240)
            make.leading.trailing.equalToSuperview()
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(addedPackagesTableView.snp.bottom).offset(4)
            make.leading.trailing.width.height.equalTo(addPackagesButton)
        }
    }
    
    @objc private func didTapAddPackage(_ sender: UIButton) {
        guard let amount = packageCreatorView.getAmount() else {
            showErrorToast("Pls Enter Amount King")
            return
        }
        
        
        var kickoutTime: Int? = nil
        
        switch entryStrategy {
        case .joinDuringGroupStartTimeUntilKickout(startTime: let _), .joinImmediatelyUntilKickout:
            guard let kt = packageCreatorView.getKickoutTime() else {
                showErrorToast("Pls Enter kickout time King")
                return
            }
            kickoutTime = kt
        default:
            break
        }
        
        let chatPackage = ChatGroupPackage(amount: amount, kickoutTime: kickoutTime )
        
        currentPackages.append(chatPackage)
        addedPackagesTableView.reloadData()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AddPackagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentPackages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PackageCreatorCell()
        let currentPackage = self.currentPackages[indexPath.row]
        cell.update(amount: currentPackage.amount, kickoutTime: currentPackage.kickoutTime ?? -1, entryStrategy: self.entryStrategy)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
      return "Added Packages"
    }
 
}
