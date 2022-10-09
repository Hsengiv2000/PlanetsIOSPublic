//
//  PackageCreatorCell.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 29/1/23.
//

import Foundation
import UIKit


class PackageCreatorCell: UITableViewCell {
    
    private let packageCreatorView: PackageCreatorView = PackageCreatorView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(packageCreatorView)
        packageCreatorView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(amount: Int, kickoutTime: Int, entryStrategy: GroupEntryStrategy) {
        self.packageCreatorView.update(amount: amount, kickoutTime: kickoutTime, entryStrategy: entryStrategy, isEditable: false)
    }
}

class PackageCreatorView: UIView {
    
    private let amountTextField = UITextField().then {
        $0.placeholder = "Enter amount in SGD" //currency
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.green.cgColor
    }
    
    private let kickoutTimeTextField = UITextField().then {
        $0.placeholder = "Enter kickout time in minutes"
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.green.cgColor
        
    }
    
    
    public init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .yellow
        self.layer.borderWidth = 1
        self.layer.backgroundColor = UIColor.blue.cgColor
        self.amountTextField.delegate = self
        self.kickoutTimeTextField.delegate = self
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        addSubview(amountTextField)
        addSubview(kickoutTimeTextField)
    }
    
    private func setupConstraints() {
        amountTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(10)
        }
        
        self.kickoutTimeTextField.snp.remakeConstraints { make in
            make.width.height.leading.trailing.equalTo(amountTextField)
            make.top.equalTo(amountTextField.snp.bottom).offset(10)
        }
    }
    
    public func update(amount: Int, kickoutTime: Int, entryStrategy: GroupEntryStrategy ,isEditable: Bool = false) {
        
        self.amountTextField.isEnabled = isEditable
        self.kickoutTimeTextField.isEnabled = isEditable
        
        if amount != -1 {
            self.amountTextField.text = String(amount)
        }
        if kickoutTime != -1 {
            self.kickoutTimeTextField.text = String(kickoutTime)
        }
        
        switch entryStrategy {
        case .inviteOnly, .joinDuringGroupStartTime(startTime: let _), .joinPermanent:
            self.kickoutTimeTextField.snp.remakeConstraints { make in
                make.width.height.equalTo(0)
                make.leading.trailing.equalTo(amountTextField)
                make.top.equalTo(amountTextField.snp.bottom).offset(10)
                make.bottom.equalToSuperview().inset(10)
            }
        case .joinDuringGroupStartTimeUntilKickout(startTime: let _), .joinImmediatelyUntilKickout:
            self.kickoutTimeTextField.snp.remakeConstraints { make in
                make.width.height.leading.trailing.equalTo(amountTextField)
                make.top.equalTo(amountTextField.snp.bottom).offset(7)
                make.bottom.equalToSuperview().inset(10)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getAmount() -> Int? {
        if let text = amountTextField.text, let amount = Int(text) {
            return amount
        }
            
        return nil
    }
    
    public func getKickoutTime() -> Int? {
        if let text = kickoutTimeTextField.text, let kickoutTime = Int(text) {
            return kickoutTime
        }
            
        return nil
    }
    
}

extension PackageCreatorView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
