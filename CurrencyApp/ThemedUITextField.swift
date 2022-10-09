//
//  ThemedUITextField.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 30/1/23.
//

import Foundation
import UIKit

class ThemedUITextField: UITextField {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.leftView?.tintColor = Theme.Color.soberGrayColor
        self.layer.borderColor = Theme.Color.soberGrayColor.cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.backgroundColor = .white
        
        self.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                      for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let placeholder = self.placeholder ?? ""
        if self.text == "" {
            self.leftView?.tintColor = Theme.Color.soberGrayColor
            self.layer.borderColor = Theme.Color.soberGrayColor.cgColor
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : Theme.Color.soberGrayColor])
        } else {
            self.leftView?.tintColor = Theme.Color.planetsDarkGreenColor
            self.layer.borderColor = Theme.Color.planetsDarkGreenColor.cgColor
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : Theme.Color.planetsDarkGreenColor])
        }
    }
}

extension UITextField {
    func addPaddingAndIcon(_ image: UIImage, padding: CGFloat,isLeftView: Bool, tintColor: UIColor) {
        let frame = CGRect(x: 0, y: 0, width: image.size.width + padding, height: image.size.height)
        
        let outerView = UIView(frame: frame)
        let iconView  = UIImageView(frame: frame)
        iconView.image = image
        iconView.contentMode = .center
        outerView.addSubview(iconView)
        
        if isLeftView {
            leftViewMode = .always
            leftView = outerView
            leftView?.tintColor = tintColor
        } else {
            rightViewMode = .always
            rightView = outerView
            rightView?.tintColor = tintColor
        }
        
        
    
  }
    
    func addPadding(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
