//
//  SignupVC.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 18/10/22.
//

import Foundation
import Then
import SnapKit

class SignupVC: ViewController {
    
    private let usernameTextField = ThemedUITextField().then {
        $0.addPaddingAndIcon(UIImage(systemName: "person")!, padding: 25, isLeftView: true, tintColor: Theme.Color.soberGrayColor)
        
        $0.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.Color.soberGrayColor]
        )
    }
    
    private let emailTextField = ThemedUITextField().then {
        $0.addPaddingAndIcon(UIImage(systemName: "envelope")!, padding: 25, isLeftView: true, tintColor: Theme.Color.soberGrayColor)
        
        $0.attributedPlaceholder = NSAttributedString(
            string: "Email",
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
    
    private let confirmPasswordTextField = ThemedUITextField().then {
        $0.addPaddingAndIcon(UIImage(systemName: "lock")!, padding: 25, isLeftView: true, tintColor: Theme.Color.soberGrayColor)
        $0.isSecureTextEntry = true
        $0.attributedPlaceholder = NSAttributedString(
            string: "Confirm Password",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.Color.soberGrayColor]
        )
    }
    
    private let submitButton = UIButton().then {
        $0.setTitle("Sign Up", for: .normal)
        $0.backgroundColor = Theme.Color.planetsDarkGreenColor
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }
    
    private let logoView = UIImageView().then {
        $0.image = UIImage(named: "planets_logo")
    }
    
    private let welcomeLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = Theme.Font.headlineFont.withSize(40)
        $0.text = "Welcome!"
    }
    
    private let welcomeSubtitleLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = Theme.Font.headlineFont.withSize(15)
        $0.text = "Create a Planets account to get an exclusive sneak peak into the daily lives of celebrities."
        $0.numberOfLines = 3
        $0.lineBreakMode = .byTruncatingTail
    }
    
    
    private let bgView = UIImageView().then {
        $0.image = UIImage(named: "planets")
    }
    
    private let authManager: AuthenticationNetworkManager
    
    init(authManager: AuthenticationNetworkManager) {
        self.authManager = authManager
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupEvents()
        self.title = "SignUp"
    }
    
    private func setupUI() {
        view.addSubview(usernameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(submitButton)
        view.addSubview(logoView)
        view.addSubview(confirmPasswordTextField)
        
        view.backgroundColor = .white
        
        view.addSubview(welcomeLabel)
        view.addSubview(welcomeSubtitleLabel)
        
        view.backgroundColor = .white
        
        
        logoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(38)
            make.leading.equalToSuperview().offset(95)
            make.trailing.equalToSuperview().inset(81)
            make.height.equalTo(116)
        }
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(51)
            make.centerX.equalToSuperview()
        }
        
        welcomeSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(60)
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(welcomeSubtitleLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(53)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.leading.trailing.width.height.centerX.equalTo(usernameTextField)
            make.top.equalTo(usernameTextField.snp.bottom).offset(33)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.leading.trailing.width.height.centerX.equalTo(usernameTextField)
            make.top.equalTo(emailTextField.snp.bottom).offset(33)
        }
        
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.leading.trailing.width.height.centerX.equalTo(usernameTextField)
            make.top.equalTo(passwordTextField.snp.bottom).offset(33)
        }
        
        submitButton.snp.makeConstraints { make in
            make.leading.trailing.width.centerX.equalTo(usernameTextField)
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(33)
            make.height.equalTo(40)
        }
    }
    
    private func setupEvents() {
        submitButton.addTarget(self, action: #selector(didTapSignup(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapSignup(_ sender: UIButton) {
        authManager.signup( username: usernameTextField.text ?? "", email: emailTextField.text ?? "", password: passwordTextField.text ?? "").on(started: { [weak self] in
            self?.startLoadingAnimation()
            
        }).on(value: { [weak self] _ in
            guard let me = self else { return }
            me.stopLoadingAnimation()
            DispatchQueue.main.async { [weak me] in
                guard let myself = me else { return }
                
                myself.showSuccessToast("Confirm email through link sent to address", handler: {[weak self] _ in
                    print("WE ARE THERE")
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }).start()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
