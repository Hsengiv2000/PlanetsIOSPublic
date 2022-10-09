//
//  DropdownView.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 14/2/23.
//

import Foundation
import UIKit
import SnapKit

class DropdownView: UIView {
    
    
    private let dropdownButton = UIButton().then {
        $0.setTitle("", for: .normal)
        $0.layer.borderColor = Theme.Color.soberGrayColor.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.semanticContentAttribute = .forceRightToLeft
        $0.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        $0.setImage(UIImage(systemName: "arrow.up"), for: .selected)
        $0.setTitleColor(Theme.Color.planetsDarkGreenColor, for: .selected )
        $0.setTitleColor(Theme.Color.planetsDarkGreenColor, for: .normal )
        $0.titleLabel?.font = Theme.Font.headlineFont.withSize(13)
    }
    private var heightConstraint: Constraint? = nil
    
    public let optionsTableView = UITableView().then {
        $0.isHidden = true
    }
    
    public var selectedIndex: Int = 0
    
    
    public init() {
        super.init(frame: .zero)
        
        setupViews()
        createConstraints()
    }
    
    private func setupViews() {
        addSubview(dropdownButton)
        addSubview(optionsTableView)
        dropdownButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        toggle()
    }
    
    public func toggle() {
        dropdownButton.isSelected.toggle()
        optionsTableView.isHidden = !optionsTableView.isHidden
        if !optionsTableView.isHidden {
            optionsTableView.reloadData()
            self.snp.updateConstraints { make in
                make.height.equalTo(204)
            }
        } else {
            self.snp.updateConstraints { make in
                make.height.equalTo(54)
            }
        }
        
        self.setNeedsLayout()
        
    }
    
    public func updateTitle(_ title: String) {
        dropdownButton.setTitle(title, for:.normal )
    }
    
    private func createConstraints() {
        dropdownButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        optionsTableView.snp.makeConstraints { make in
            make.top.equalTo(dropdownButton.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
