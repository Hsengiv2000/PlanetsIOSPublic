//
//  DropdownOptionCell.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 14/3/23.
//

import Foundation
import UIKit

class DropdownOptionCell: UITableViewCell {
    
    private let label = UILabel().then {
        $0.textColor = Theme.Color.planetsDarkGreenColor
        $0.numberOfLines = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        layer.borderWidth = 2
        layer.borderColor = Theme.Color.soberGrayColor.cgColor
        backgroundColor = Theme.Color.planetsLightGreenColor
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(text: String) {
        label.text = text
        label.sizeThatFits(CGSize(width: label.frame.size.width, height: CGFLOAT_MAX))
        
    }
}
