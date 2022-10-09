//
//  CreateGroupViewController.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 14/12/22.
//

import Foundation
import UIKit
import Kingfisher

class CreateGroupViewController: ViewController {
    
    private let avatarImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person" )
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 172/2
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.red.cgColor
        $0.isUserInteractionEnabled = true
    }
    
    
    private let dropdownView = DropdownView()
    private var groupType: GroupEntryStrategy?
    private let groupNameTextInput = ThemedUITextField().then {
        
        $0.isSecureTextEntry = true
        $0.attributedPlaceholder = NSAttributedString(
            string: "GroupName",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.Color.soberGrayColor]
        )
        $0.addPadding(padding: 22)
    }
    
    private let groupDescriptionTextInput = ThemedUITextField().then {
        $0.isSecureTextEntry = true
        $0.attributedPlaceholder = NSAttributedString(
            string: "Group Description",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.Color.soberGrayColor]
        )
        $0.addPadding(padding: 22)
    }
    
    private let limitBox = ThemedUITextField().then {
        
        $0.isSecureTextEntry = true
        $0.attributedPlaceholder = NSAttributedString(
            string: "Max Pax",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.Color.soberGrayColor]
        )
        $0.addPadding(padding: 22)
    }
    
    private let groupStartingDatePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .compact
        $0.isHidden = true
    }
    private let groupExpiryDatePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .compact
    }
    private let submitButton = UIButton().then {
        $0.setTitle("Submit", for: .normal)
        $0.backgroundColor = Theme.Color.planetsDarkGreenColor
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
    }
    
    private let groupStartTimeLabel = UILabel().then {
        $0.text = "Group starts on: "
        $0.textColor = .black
        $0.isHidden = true
        $0.font = Theme.Font.headlineFont.withSize(15)
    }
    
    private let groupExpiryTimeLabel = UILabel().then {
        $0.text = "Group expires on:"
        $0.textColor = .black
        $0.font = Theme.Font.headlineFont.withSize(15)
    }
    
    
    private var imageURLString: String = ""
    
    private let currentUserManager: CurrentUserManager
    private let uiFactory: UIFactory
    
    init(currentUserManager: CurrentUserManager, uiFactory: UIFactory) {
        
        self.currentUserManager = currentUserManager
        self.uiFactory = uiFactory
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(avatarImageView)
        scrollView.addSubview(groupNameTextInput)
        scrollView.addSubview(groupStartingDatePicker)
        scrollView.addSubview(groupExpiryDatePicker)
        scrollView.addSubview(submitButton)
        scrollView.addSubview(limitBox)
        scrollView.addSubview(groupDescriptionTextInput)
        scrollView.addSubview(groupStartTimeLabel)
        scrollView.addSubview(groupExpiryTimeLabel)
        scrollView.addSubview(dropdownView)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        
        avatarImageView.snp.makeConstraints { make in
            make.width.equalTo(172)
            make.height.equalTo(172)
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(110)
        }
        
        groupNameTextInput.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(33)
            make.leading.trailing.equalToSuperview().inset(33)
            make.height.equalTo(38)
        }
        
        groupDescriptionTextInput.snp.makeConstraints { make in
            make.top.equalTo(groupNameTextInput.snp.bottom).offset(16)
            make.leading.trailing.height.equalTo(groupNameTextInput)
        }
        
        dropdownView.snp.makeConstraints { make in
            make.top.equalTo(groupDescriptionTextInput.snp.bottom).offset(16)
            make.leading.trailing.equalTo(groupNameTextInput)
            make.height.equalTo(54)
        }
        
        
        limitBox.snp.makeConstraints { make in
            make.top.equalTo(dropdownView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(118)
            make.height.equalTo(54)
        }
        
       
        groupStartTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.centerY.equalTo(groupStartingDatePicker)
        }
        
        groupExpiryTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.centerY.equalTo(groupExpiryDatePicker)
        }
        
        groupStartingDatePicker.snp.makeConstraints { make in
            
            make.top.equalTo(limitBox.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(34)
            make.height.equalTo(54)
            make.width.equalTo(205)
        }
        
        groupExpiryDatePicker.snp.makeConstraints { make in
            
            make.top.equalTo(groupStartingDatePicker.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(34)
            make.height.equalTo(54)
            make.width.equalTo(205)
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(groupExpiryDatePicker.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(146)
            make.height.equalTo(40)
        }
        
        
        
        setupEvents()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap) // Add gesture recognizer to background view
        
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    private func setupEvents() {
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar(_:)))
        avatarImageView.addGestureRecognizer(tapRecognizer)
        dropdownView.optionsTableView.register(DropdownOptionCell.self, forCellReuseIdentifier: "DropdownOptionCell")
        dropdownView.optionsTableView.dataSource = self
        dropdownView.optionsTableView.delegate = self
    }
    
    @objc private func didTapAvatar(_ sender: UITapGestureRecognizer) {
        guard let image = avatarImageView.image else { return }
        navigationController?.pushViewController(uiFactory.avatarViewController(image: image, callback: { [weak self] uploadedURL in
            guard let me = self else { return }
        
            me.imageURLString = uploadedURL
            if let url = URL(string: uploadedURL) {
                
                me.avatarImageView.kf.setImage(with: url)
            }
        }), animated: true)
    }

    @objc private func didTapSubmit(_ sender: UIButton) {
        guard let groupNameText = groupNameTextInput.text, let limitString = limitBox.text, let limit = Int(limitString), let groupDescriptionText = groupDescriptionTextInput.text, let groupType = self.groupType else {
            showErrorToast("Some data seems sus")
            return }
        if groupNameText == "" {
            showErrorToast("Please fill all details")
            return
        }
        
       
        let expiryTime = groupExpiryDatePicker.date.timeIntervalSince1970
        
        var startTime: Double? = groupStartingDatePicker.date.timeIntervalSince1970
        if groupStartingDatePicker.isHidden {
            startTime = nil
        } else {
            if startTime! >=  expiryTime {
                showErrorToast("Start time should be lower than expiry time")
                return
            }
        }
        var entryStratRow = dropdownView.selectedIndex
        var entryStrat = GroupEntryStrategy.inviteOnly
        switch GroupEntryStrategy.allCases[entryStratRow] {
        case .inviteOnly:
            entryStrat = .inviteOnly
        case .joinDuringGroupStartTimeUntilKickout(let _):
            entryStrat = .joinDuringGroupStartTimeUntilKickout(startTime: startTime!)
        case .joinImmediatelyUntilKickout:
            entryStrat = .joinImmediatelyUntilKickout
        case .joinDuringGroupStartTime(let _):
            entryStrat = .joinDuringGroupStartTime(startTime: startTime!)
        case .joinPermanent:
            entryStrat = .joinPermanent
        }
        //TODO
        
        let vc  = AddPackagesViewController(currentUserManager: currentUserManager, groupName: groupNameText, imageURLString: imageURLString, limit: limit, groupDescriptionText: groupDescriptionText, entryStrategy: entryStrat, expiryTime: expiryTime)
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension CreateGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownOptionCell") as! DropdownOptionCell
        cell.update(text: GroupEntryStrategy.allCases[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        GroupEntryStrategy.allCases.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch GroupEntryStrategy.allCases[indexPath.row] {
        case .inviteOnly:
            groupStartingDatePicker.isHidden = true
            groupStartTimeLabel.isHidden = true
        case  .joinPermanent:
            groupStartingDatePicker.isHidden = true
            groupStartTimeLabel.isHidden = true
        case .joinImmediatelyUntilKickout:
            groupStartingDatePicker.isHidden = true
            groupStartTimeLabel.isHidden = true
        case .joinDuringGroupStartTimeUntilKickout(let _):
            groupStartingDatePicker.isHidden = false
            groupStartTimeLabel.isHidden = false
        case  .joinDuringGroupStartTime(let _):
            groupStartingDatePicker.isHidden = false
            groupStartTimeLabel.isHidden = false
        }
        dropdownView.selectedIndex = indexPath.row
        dropdownView.updateTitle(GroupEntryStrategy.allCases[indexPath.row].title)
        dropdownView.toggle()
        showYesNoBox(heading: "Explanation", txt: GroupEntryStrategy.allCases[indexPath.row].description)
        self.groupType =  GroupEntryStrategy.allCases[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
