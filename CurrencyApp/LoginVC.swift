//
//  LoginVC.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 18/10/22.
//

import Foundation
import Then
import SnapKit




class LoginVC: ViewController {
    
    private let usernameTextField = ThemedUITextField().then {
        $0.addPaddingAndIcon(UIImage(systemName: "person")!, padding: 25, isLeftView: true, tintColor: Theme.Color.soberGrayColor)
        
        $0.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.Color.soberGrayColor]
        )
    }
    
    private let passwordTextField = ThemedUITextField().then {
        $0.addPaddingAndIcon(UIImage(systemName: "lock")!, padding: 25, isLeftView: true, tintColor: Theme.Color.soberGrayColor)
        $0.isSecureTextEntry = true
        $0.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.Color.soberGrayColor]
        )
    }
    
    private let submitButton = UIButton().then {
        $0.setTitle("Log in", for: .normal)
        $0.backgroundColor = Theme.Color.planetsDarkGreenColor
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }
    
    private let logoView = UIImageView().then {
        $0.image = UIImage(named: "planets_logo")
    }
    
    private let bgView = UIView().then {
        $0.backgroundColor = Theme.Color.planetsLightGreenColor
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let welcomeLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = Theme.Font.headlineFont.withSize(40)
        $0.text = "Welcome!"
    }
    
    private let welcomeSubtitleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = Theme.Font.headlineFont.withSize(15)
        $0.text = "Log into your existing Planets account"
    }
    
    private let authManager: AuthenticationNetworkManager
    private let callback: ((UserModel?)->())
    init(authManager: AuthenticationNetworkManager, callback: @escaping ((UserModel?)->())) {
        self.authManager = authManager
        self.callback = callback
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupEvents()
        self.title = "Login"
    }
    
    private func setupUI() {
        view.addSubview(bgView)
        view.addSubview(logoView)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(submitButton)
        view.addSubview(welcomeLabel)
        view.addSubview(welcomeSubtitleLabel)
        
        view.backgroundColor = .white
        
        
        logoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(38)
            make.leading.equalToSuperview().offset(95)
            make.trailing.equalToSuperview().inset(81)
            make.height.equalTo(116)
        }
        
        bgView.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(49)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(bgView).offset(22)
            make.leading.trailing.equalToSuperview().inset(51)
            make.centerX.equalToSuperview()
        }
        
        welcomeSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(welcomeSubtitleLabel.snp.bottom).offset(34)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(53)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.leading.trailing.width.height.centerX.equalTo(usernameTextField)
            make.top.equalTo(usernameTextField.snp.bottom).offset(36)
        }
        
        submitButton.snp.makeConstraints { make in
            make.leading.trailing.width.centerX.equalTo(usernameTextField)
            make.top.equalTo(passwordTextField.snp.bottom).offset(44)
            make.height.equalTo(40)
        }
    }
    
    private func setupEvents() {
        submitButton.addTarget(self, action: #selector(didTapLogin(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapLogin(_ sender: UIButton) {
        authManager.login( username: usernameTextField.text ?? "", password: passwordTextField.text ?? "").on(starting: { [weak self ] in
            self?.startLoadingAnimation()
            
        }).on(value: { [weak self] userModel in
            guard let me = self else { return }
            DispatchQueue.main.async { [weak me] in
                guard let myself = me else { return }
                
                myself.showSuccessToast("Successfully logged in!", handler: {[weak self] _ in
                    myself.navigationController?.popViewController(animated: true)
                    self?.callback(userModel)
                })
                
                
            }
        }).on(failed: { [weak self] error in
            guard let me = self else { return }
            me.stopLoadingAnimation()
            me.showErrorToast(.incorrectCredentials)
        }).start()
    }
        
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
