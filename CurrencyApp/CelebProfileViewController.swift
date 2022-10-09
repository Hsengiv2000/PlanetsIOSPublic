//
//  CelebProfileViewController.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 3/12/22.
//

import Foundation
import UIKit
import Kingfisher
class CelebProfileViewController: ViewController {
    
    
    private let emailLabel = UITextField().then {
        $0.text = ""
        $0.backgroundColor = .clear
        $0.textColor  = .black
        $0.isUserInteractionEnabled = false
        $0.font = Theme.Font.headlineFont.withSize(20)
        $0.textAlignment = .center
    }
    
    private let usernameLabel = UITextField().then {
        $0.text = ""
        $0.textColor  = .black
        $0.isUserInteractionEnabled = false
        $0.font = Theme.Font.headlineFont.withSize(35)
        $0.textAlignment = .center
    }
    
    private let myChatsbutton = UIButton().then {
        $0.setTitle("Created Groups", for: .normal)
        $0.backgroundColor = Theme.Color.planetsDarkGreenColor
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 27
    }
    
    private let purchaseListButton = UIButton().then {
        $0.setTitle("Purchases", for: .normal)
        $0.backgroundColor = Theme.Color.planetsDarkGreenColor
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 27
    }
    
    private let avatarImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person" )
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 95
        $0.layer.borderWidth = 3
        $0.layer.borderColor = Theme.Color.planetsDarkGreenColor.cgColor
        $0.isUserInteractionEnabled = true
    }
    
    private let scrollView = UIScrollView()
    
    private let logoutButton = UIButton().then  {
        $0.setTitle("Logout", for: .normal)
        $0.setTitleColor(Theme.Color.planetsLightGreenColor, for: .normal)
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 19
        $0.layer.borderColor = Theme.Color.planetsLightGreenColor.cgColor
    }
    
    private let bgView = UIImageView().then {
        $0.image = UIImage(named: "cream_wave_background")
    }
    
    private let createGroupButton = UIButton().then {
        $0.setTitle("Create a group", for: .normal)
        $0.backgroundColor = Theme.Color.planetsDarkGreenColor
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 27
    }
    
    
    
    private let authManager: AuthenticationNetworkManager
    private let currentUserManager: CurrentUserManager
    private let uiFactory: UIFactory
    init(authManager: AuthenticationNetworkManager, currentUserManager: CurrentUserManager, uiFactory: UIFactory) {
        self.authManager = authManager
        self.currentUserManager = currentUserManager
        self.uiFactory = uiFactory
        super.init()
        view.backgroundColor = .white
    
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupEvents()
        self.title = "Celeb Profile"
        updateUser(currentUserManager.currentUser.value)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupConstraints() {
        view.addSubview(bgView)
        view.addSubview(scrollView)
        scrollView.addSubview(logoutButton)
        scrollView.addSubview(avatarImageView)
        scrollView.addSubview(emailLabel)
        scrollView.addSubview(usernameLabel)
        scrollView.addSubview(createGroupButton)
        scrollView.addSubview(myChatsbutton)
        scrollView.addSubview(purchaseListButton)
        
        bgView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-230)
        }
        scrollView.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(190)
            make.height.equalTo(190)
            make.top.equalToSuperview().offset(105)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.height.equalTo(44)
            make.width.equalToSuperview()
        }
        emailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(usernameLabel.snp.bottom).offset(7)
            make.height.equalTo(26)
            make.width.equalToSuperview()
        }
        myChatsbutton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emailLabel.snp.bottom).offset(60)
            make.leading.trailing.equalToSuperview().inset(53)
            make.height.equalTo(54)
        }
        
        createGroupButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(myChatsbutton.snp.bottom).offset(27)
            make.leading.trailing.equalToSuperview().inset(53)
            make.height.equalTo(54)
        }
        
        purchaseListButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(createGroupButton.snp.bottom).offset(27)
            make.leading.trailing.equalToSuperview().inset(53)
            make.height.equalTo(54)
        }
        
        
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(purchaseListButton.snp.bottom).offset(25)
            make.width.equalTo(130)
            make.height.equalTo(38)
        }
        
    }
    
    
    private func setupEvents() {
        logoutButton.addTarget(self, action: #selector(didTapLogout(_:)), for: .touchUpInside)
        
        createGroupButton.addTarget(self, action: #selector(didTapCreateGroup(_:)), for: .touchUpInside)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar(_:)))
        avatarImageView.addGestureRecognizer(tapRecognizer)
        currentUserManager.currentUser.signal.take(duringLifetimeOf: self).observeValues { [weak self] user in
            guard let me = self else { return }
            me.updateUser(user)
            
        }
        
        purchaseListButton.addTarget( self, action: #selector(didTapPurchaseListButton), for: .touchUpInside)
        
        let tapRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(didTapMyGroups(_:)))
        myChatsbutton.addGestureRecognizer(tapRecognizer2)
    }
    
    private func updateUser(_ userModel: UserModel) {
        emailLabel.text = userModel.email ?? "lols"
        usernameLabel.text = userModel.username
        if let imageURLString = userModel.imageURL, let imageURL = URL(string: imageURLString) {
            KF.url(imageURL)
                    .set(to: avatarImageView)
        }
    }
    
    @objc private func didTapMyGroups(_ sender: UITapGestureRecognizer) {
        navigationController?.pushViewController(uiFactory.myCreatedChatsViewController(), animated: true)
    }
    
    @objc private func didTapPurchaseListButton(_ sender: UIButton) {
        
        let tableview = UITableView().then {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
        }
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(IndividualPaymentsCell.self, forCellReuseIdentifier: "IndividualPaymentsCell")
        let vc = ZoomedOutTableViewController(tableView: tableview)
        present(vc, animated: true)
        
    }
    
    @objc private func didTapLogout(_ sender: UIButton) {
        currentUserManager.logout().on(starting: { [weak self] in
            self?.startLoadingAnimation()
        }).on(value: { [weak self] _ in
            self?.stopLoadingAnimation()
        }).start()
    }
    
    
    @objc private func didTapCreateGroup(_ sender: UIButton) {
        navigationController?.pushViewController(uiFactory.createGroupVC(), animated: true)
    }
    
    @objc private func didTapAvatar(_ sender: UITapGestureRecognizer) {
        guard let image = avatarImageView.image else { return }
        navigationController?.pushViewController(uiFactory.avatarViewController(image: image, callback: { [weak self] uploadedURL in
            guard let me = self else { return }
        
            me.currentUserManager.updateAvatar(urlString: uploadedURL).start()
        }), animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CelebProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = currentUserManager.paymentList.count == 0
        return currentUserManager.paymentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IndividualPaymentsCell = tableView.dequeueReusableCell(withIdentifier: "IndividualPaymentsCell") as! IndividualPaymentsCell
        cell.update(individualPaymentModel: currentUserManager.paymentList[indexPath.row], groupName: currentUserManager.groupIDMap[currentUserManager.paymentList[indexPath.row].groupID] ?? "???")
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Payment History"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .yellow
        
        headerView.addSubview(label)
        headerView.backgroundColor = .darkGray
        
        return headerView
    }
}

