//
//  ViewController.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 26/10/22.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    
    public let loadingCircle = CircularLoadingProgressView()
    private var isKeyboardShown: Bool = false
    private let isTransparent: Bool
    public init(isTransparent: Bool = false) {
        self.isTransparent = isTransparent
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loadingCircle)
        loadingCircle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(40)
            make.width.height.equalTo(50)
        }
        loadingCircle.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        configureNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.hidesBottomBarWhenPushed = false
        self.shouldShowNavigationBar = true
    }

    private func configureNavBar() {
        if #available(iOS 15.0, *) {
            if isTransparent {
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithTransparentBackground()

                navigationController?.navigationBar.tintColor = .white

                navigationItem.scrollEdgeAppearance = navigationBarAppearance
                navigationItem.standardAppearance = navigationBarAppearance
                navigationItem.compactAppearance = navigationBarAppearance

            } else {
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithDefaultBackground()

                navigationController?.navigationBar.tintColor = .label

                navigationItem.scrollEdgeAppearance = navigationBarAppearance
                navigationItem.standardAppearance = navigationBarAppearance
                navigationItem.compactAppearance = navigationBarAppearance
            }

            navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, !isKeyboardShown {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
            isKeyboardShown = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 && isKeyboardShown {
            self.view.frame.origin.y = 0
            isKeyboardShown = false
        }
    }
    
    @objc private func didTapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func showErrorToast(_ errType: CustomErrorType) {
        let alert = UIAlertController(title: "Error", message: errType.errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func showErrorToast(_ txt: String, handler: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: "Error", message: txt, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func showSuccessToast(_ txt: String, handler: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: "Success!", message: txt, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func showYesNoBox(heading: String, txt: String, yesHandler: ((UIAlertAction) -> ())? = nil, noHandler: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: heading, message: txt, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sure", style: .default, handler: yesHandler))
        alert.addAction(UIAlertAction(title: "Nah", style: .default, handler: noHandler))
        self.present(alert, animated: true, completion: nil)
    }
    
    public var shouldShowNavigationBar: Bool =  true {
        didSet {
            navigationController?.setNavigationBarHidden(!shouldShowNavigationBar, animated: true)
        }
    }
    
    public func startLoadingAnimation() {
        loadingCircle.animateStroke()
    }
    
    public func stopLoadingAnimation() {
        loadingCircle.stopAnimation()
    }
}
