//
//  ViewController.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 7/10/22.
//

import UIKit
import SnapKit
import Then

class LoginLogoutViewController: ViewController {
    
    private var isLoggedIn: Bool = false
    private let loginButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
        $0.layer.borderColor = UIColor.white.cgColor
        $0.setTitle("LOGIN", for: .normal)
    }
    
    private let signupButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
        $0.layer.borderColor = UIColor.white.cgColor
        $0.setTitle("SIGNUP", for: .normal)
    }
    
    private let bgView = UIImageView().then {
        $0.image = UIImage(named: "planets")
    }

    private let authManager: AuthenticationNetworkManager
    private let callback: ((UserModel?)->())
    init(authManager: AuthenticationNetworkManager, callback: @escaping ((UserModel?)->())) {
        self.authManager = authManager
        self.callback = callback
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        self.title = "Planets!"
        
        loginButton.addTarget(self, action: #selector(didTapLogin(_:)), for: .touchUpInside)
        
        signupButton.addTarget(self, action: #selector(didTapSignup(_:)), for: .touchUpInside)

    }
    
    private func setupUI() {
        view.addSubview(bgView)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
    }
    
    private func setupConstraints() {
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(300)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        
        signupButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginButton.snp.bottom).offset(10)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        
    }
    
    @objc private func didTapLogin(_ sender: UIButton) {
        
        navigationController?.pushViewController(LoginVC(authManager: authManager, callback: callback), animated: true)
    }
    
    @objc private func didTapSignup(_ sender: UIButton) {
        navigationController?.pushViewController(SignupVC(authManager: authManager), animated: true)
        
    }
    
    @objc private func didTapHelloWorld(_ sender: UIButton) {
        authManager.mockHelloWorld()
    }

}

