//
//  HomepageViewController.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 7/11/22.
//

import Foundation
import UIKit

class HomepageViewController: ViewController {

    private let authenticationManager: AuthenticationNetworkManager
    private let helloWorldButton = UIButton().then  {
        $0.backgroundColor = .green
        $0.setTitle("MOCK", for: .normal)
    }
    
    init(authManager: AuthenticationNetworkManager) {
        self.authenticationManager = authManager
        super.init()
        view.backgroundColor = .yellow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupEvents()
    }
    
    private func setupEvents() {
        helloWorldButton.addTarget(self, action: #selector(didTapHelloWorld(_:)), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        view.addSubview(helloWorldButton)
        helloWorldButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(60)
        }
    }
    
    
    @objc private func didTapHelloWorld(_ sender: UIButton) {
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
