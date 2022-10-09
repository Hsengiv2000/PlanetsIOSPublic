//
//  IndividualPaymentsCell.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 13/12/22.
//

import Foundation
import UIKit

class IndividualPaymentsCell: UITableViewCell {

    private let amountLabel = UILabel().then {
        $0.textColor = .black
        $0.font = $0.font.withSize(23)
    }
    private let timestampLabel = UILabel().then {
        $0.textColor = .blue
        $0.font = $0.font.withSize(14)
    }
    
    private let groupNameLabel = UILabel().then {
        $0.textColor = .black
        $0.font = $0.font.withSize(23)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupConstraints()
        contentView.backgroundColor = .darkGray
    }

    private func setupUI() {
        contentView.addSubview(amountLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(groupNameLabel)
    
    }
    
    private func setupConstraints() {
        
        timestampLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.top.equalTo(groupNameLabel.snp.bottom).offset(10)
        }
        
        groupNameLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(10)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(timestampLabel.snp.leading).inset(10)
            make.centerY.equalToSuperview()
            make.top.equalTo(groupNameLabel.snp.bottom).offset(10)
        }
    }
    
    
    
    public func update(individualPaymentModel: IndividualPaymentModel, groupName: String = "yo dawg") {
        timestampLabel.text = createDateTime(String(individualPaymentModel.createdAt))
        amountLabel.text = String(individualPaymentModel.amount / 100) + " " + individualPaymentModel.currency
        
        groupNameLabel.text = groupName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createDateTime(_ timestamp: String) -> String {
        var strDate = "undefined"
            
        if let unixTime = Double(timestamp) {
            let date = Date(timeIntervalSince1970: unixTime)
            let dateFormatter = DateFormatter()
            let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
            dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm" //Specify your format that you want
            strDate = dateFormatter.string(from: date)
        }
            
        return strDate
    }
}
