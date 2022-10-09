//
//  RecommendedChatsCell.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 18/11/22.
//

import Foundation
import UIKit
import Kingfisher

protocol RecommendedChatViewDelegate: AnyObject {
    func didTapArrow(groupID: GroupID)
    func obtainArrowExpansion(groupID: GroupID) -> Bool
}

class RecommendedChatsCell: UITableViewCell {

    let recommendedChatView = RecommendedChatsView()
    
    public var didTapEnterJoin: (()->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupConstraints()
        contentView.backgroundColor = .darkGray
    }

    private func setupUI() {
        contentView.addSubview(recommendedChatView)
    
    }
    
    private func setupConstraints() {
        
        recommendedChatView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.leading.trailing.bottom.equalToSuperview().inset(12)
        }
        
        recommendedChatView.hasJoinedButton.addTarget(self, action: #selector(didTapEnterJoinHandle(_:)), for: .touchUpInside)
    }
    
    
    @objc private func didTapEnterJoinHandle(_ sender: UIButton) {
        
        didTapEnterJoin?()
    }
    
    public func update(groupModel: ChatGroupModel,hasStarted: Bool = false, isMine: Bool = false) {
        recommendedChatView.update(groupModel: groupModel,  hideButton: false, hasStarted: hasStarted, isMine: isMine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RecommendedChatsView: UIView {
    private let roleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = Theme.Font.headlineFont.withSize(15)
        $0.text = ""
    }
    private let bgView = UIView().then {
        $0.backgroundColor = Theme.Color.creamLightColor
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    private let groupNameLabel = UILabel().then {
        $0.textColor = .black
        $0.font = Theme.Font.headlineFont.withSize(25)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = Theme.Color.planetsDarkGreenColor
        $0.font = Theme.Font.headlineFont.withSize(12)
        $0.numberOfLines = 3
    }
    
    private let avatarImageView = UIImageView().then {
        $0.image = UIImage(systemName: "magnifyingglass")
        $0.layer.cornerRadius = 33
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Theme.Color.planetsDarkGreenColor.cgColor
    }
    
    
    let hasJoinedButton = UIButton().then {
        $0.backgroundColor = .red
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 7
        $0.clipsToBounds = true
    }
    
    let arrowButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 2
        
    }
    
    
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        addSubview(bgView)
        bgView.addSubview(groupNameLabel)
        bgView.addSubview(hasJoinedButton)
        bgView.addSubview(descriptionLabel)
        bgView.addSubview(avatarImageView)
        bgView.addSubview(roleLabel)
    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        groupNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(hasJoinedButton.snp.leading).offset(-5)
            make.top.equalTo(avatarImageView.snp.bottom).offset(2)
        }
        
        hasJoinedButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerY.equalTo(groupNameLabel)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(groupNameLabel.snp.bottom).offset(10)
            make.bottom.equalTo(arrowButton.snp.top).offset(-15)
        }
        
        roleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(5)
        }
        
        
        arrowButton.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(32)
        }
        
    
        
    }
    
    private var groupModel: ChatGroupModel? = nil
    
    weak var delegate: RecommendedChatViewDelegate?
    
    public func update(groupModel: ChatGroupModel, hideButton: Bool = false ,hasStarted: Bool = false, isMine: Bool = false) {
        hasJoinedButton.isHidden = hideButton
        groupNameLabel.text = groupModel.groupName
        
        switch groupModel.entryStrategy {
        case .joinPermanent, .inviteOnly:
            break
        case .joinImmediatelyUntilKickout:
            break
        case .joinDuringGroupStartTime(let startTime):
            break
        case .joinDuringGroupStartTimeUntilKickout(let startTime):
            break
        }
        
        switch groupModel.joinPaidStatus {
        case .joined:
            
            hasJoinedButton.setTitle("Enter", for: .normal)
            hasJoinedButton.backgroundColor = .systemPink
            
            alpha = 1
        
        case .paid:
            hasJoinedButton.setTitle("Paid", for: .normal)
            hasJoinedButton.backgroundColor = .blue
            
            alpha = 1
        
        case .none:
            
            hasJoinedButton.setTitle("Join", for: .normal)
            hasJoinedButton.backgroundColor = .green
            
            
            alpha = hasStarted ? 0.5 : 1
        }
        
        roleLabel.isHidden = !isMine
        bgView.backgroundColor = isMine ? .systemYellow : .gray
        
        self.groupModel = groupModel
        descriptionLabel.text = groupModel.groupDescription
        if let url = URL(string: groupModel.imageURL) {
            avatarImageView.kf.setImage(with: url)
        }

        arrowButton.addTarget(self, action: #selector(didTapArrow), for: .touchUpInside)
    }
    
    @objc private func didTapArrow() {
        guard let groupModel = groupModel else { return }
        delegate?.didTapArrow(groupID: groupModel.groupID )
    }
    
  
    
    private func convertTimestampToDateString(unixTime: Double) -> String {
        var strDate = "undefined"
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
        dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm" //Specify your format that you want
        strDate = dateFormatter.string(from: date)
        return strDate
    }
}


class EntryStratView: UIView {
    
    private let titleLabel = UILabel().then {
        $0.font = $0.font.withSize(20)
        $0.numberOfLines = 0
    }
    private let descriptionLabel = UILabel().then {
        
        $0.font = $0.font.withSize(16)
        $0.textColor = .black
        $0.alpha = 0.8
        $0.numberOfLines = 0
    }
    
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(8)
            
        }
        layer.cornerRadius = 6
        clipsToBounds = true
        backgroundColor = .cyan
    }
    
    public func update(titleString: String, descriptionString: String) {
        titleLabel.text = titleString
        descriptionLabel.text = descriptionString
    }
    
}
