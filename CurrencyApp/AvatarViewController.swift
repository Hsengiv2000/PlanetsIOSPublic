//
//  AvatarViewController.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 28/11/22.
//

import Foundation
import UIKit
import AVFoundation

class AvatarViewController: ViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let uiFactory: UIFactory
    private let firebaseManager: FirebaseManager
    private var callback: ((String)->())
    init(image: UIImage, uiFactory: UIFactory, firebaseManager: FirebaseManager, callback: @escaping ((String)->())){
        self.uiFactory = uiFactory
        self.firebaseManager = firebaseManager
        self.callback = callback
        imageView.image = image
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
//        self.shouldShowNavigationBar = false
        setupLayouts()
        setupEvents()
    }
    
    
    private func setupEvents() {
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        scrollView.delegate = self
    }
    
    private func setupLayouts() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(cancelButton)
        view.addSubview(editButton)
        
        cancelButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        editButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(cancelButton.snp.top)
        }
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    
    // MARK: - Events
    
    @objc
    private func didTapCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func didTapEditButton() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (action) in
            guard let me = self else { return }
            
            let positiveBlock = {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let picker = UIImagePickerController()
                    picker.delegate = me
                    picker.sourceType = .camera
                    me.present(picker, animated: true)
                } else {
                    
                    
                }
            }
    
            let negativeBlock = {
                let alertController = UIAlertController(title: "needs camera access",message: nil, preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
                alertController.addAction(UIAlertAction(title: "settings", style: .destructive, handler: { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                self?.present(alertController, animated: true)
            }
    
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (authorized) in
                    DispatchQueue.main.async {
                        if authorized {
                            positiveBlock()
                        } else {
                            negativeBlock()
                        }
                    }
                })
            } else if status == .authorized {
                positiveBlock()
            } else {
                negativeBlock()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "select photos", style: .default, handler: { [weak self] (action) in
            guard let me = self else { return }
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let picker = UIImagePickerController()
                picker.delegate = me
                picker.sourceType = .photoLibrary
                me.present(picker, animated: true)
            } else {
                
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    // MARK: - Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let editViewController = uiFactory.avatarEditViewController(image: image)
        editViewController.didEditImageHandler = { [weak self] image in
            guard let me = self else { return }
            
            me.firebaseManager.uploadImage(image: image, useCase: .avatar).on(value: { [weak me] uploadedURL in
                guard let myself = me else { return }
                myself.callback(uploadedURL)
                myself.imageView.image = image
            }).start()
        }
        self.navigationController?.pushViewController(editViewController, animated: false)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("cancel", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(button.titleColor(for: .normal)?.withAlphaComponent(0.5), for: .highlighted)
        button.titleLabel?.font = button.titleLabel?.font.withSize(16)
        return button
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("edit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(button.titleColor(for: .normal)?.withAlphaComponent(0.5), for: .highlighted)
        button.titleLabel?.font = button.titleLabel?.font.withSize(16)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
}
