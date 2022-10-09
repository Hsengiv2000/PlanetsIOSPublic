//
//  AvatarEdotViewController.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 28/11/22.
//

import Foundation
import UIKit

class AvatarEditViewController: ViewController, UIScrollViewDelegate {
    
    var didEditImageHandler: ((UIImage) -> Void)?
    
    private var maskCircleRect = CGRect.zero
    
    init(image: UIImage) {
        imageView.image = image
        
        
        super.init()
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupLayouts()
        setupEvents()
        shouldShowNavigationBar = false
    }
    
    private func setupEvents() {
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        scrollView.delegate = self
    }
    
    private func setupLayouts() {
        view.addSubview(scrollView)
        view.addSubview(maskView)
        view.addSubview(titleLabel)
        view.addSubview(bottomBarView)
        scrollView.addSubview(imageView)
        bottomBarView.addSubview(cancelButton)
        bottomBarView.addSubview(doneButton)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        maskView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
        }
        bottomBarView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        doneButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(27)
            make.width.equalTo(55)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // NOTE: Probably needs to make sure the follow codes only called once.
        
        // Determine mark circle position
        let insetX: CGFloat = 12.0
        let width = scrollView.bounds.width - insetX * 2
        let rect = CGRect(x: insetX, y: (scrollView.bounds.height - width) / 2, width: width, height: width)
        maskCircleRect = rect
        maskView.setupMaskArea(ovalIn: rect)
        
        // Setup imageView size
        imageView.sizeToFit()
        if imageView.bounds.width < imageView.bounds.height {
            imageView.frame.size = CGSize(width: width, height: imageView.bounds.height * width / imageView.bounds.width)
        } else {
            imageView.frame.size = CGSize(width: imageView.bounds.width * width / imageView.bounds.height, height: width)
        }
        imageView.frame.origin = CGPoint.zero
        scrollView.contentSize = imageView.bounds.size
        
        // Setup scrollView min zoom and insets
        scrollView.contentInset = UIEdgeInsets(top: rect.minY, left: insetX, bottom: rect.minY, right: insetX)
        scrollView.minimumZoomScale = width / scrollView.bounds.width
        scrollView.zoomScale = scrollView.minimumZoomScale
        
        // Center current imageView
        scrollView.contentOffset.y = -(scrollView.bounds.height - imageView.bounds.height * scrollView.minimumZoomScale) / 2
        scrollView.contentOffset.x = -(scrollView.bounds.width - imageView.bounds.width * scrollView.minimumZoomScale) / 2
    }
    
    // MARK: - Events
    
    @objc
    private func didTapCancelButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func didTapDoneButton() {
        self.navigationController?.popViewController(animated: true)
        
        guard let image = imageView.image else { return }
        let rect = calculateRectToCrop()
        let cropRect = CGRect(x: rect.minX * image.size.width,
                              y: rect.minY * image.size.height,
                              width: rect.width * image.size.width,
                              height: rect.height * image.size.height)
        
        guard let croppedImage = image.cropping(to: cropRect)?.upOrientated() else { return }
        didEditImageHandler?(croppedImage)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private func calculateRectToCrop() -> CGRect {
        // The assumption here is that the scrollView and markView have exactly the same origin and size.
        
        let x = -scrollView.contentOffset.x
        let y = -scrollView.contentOffset.y
        let deltaX = maskCircleRect.minX - x
        let deltaY = maskCircleRect.minY - y
        
        let ratioX = deltaX / (scrollView.zoomScale * imageView.bounds.width)
        let ratioY = deltaY / (scrollView.zoomScale * imageView.bounds.height)
        let ratioWidth = maskCircleRect.width / (scrollView.zoomScale * imageView.bounds.width)
        let ratioHeight = maskCircleRect.height / (scrollView.zoomScale * imageView.bounds.height)
        
        let ratioRect = CGRect(x: ratioX, y: ratioY, width: ratioWidth, height: ratioHeight)
        return ratioRect
    }
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 4.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let maskView = ImageEditMaskView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Avatar"
        label.textColor = UIColor.white
        label.font = label.font.withSize(18)
        return label
    }()
    
    private let bottomBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(button.titleColor(for: .normal)?.withAlphaComponent(0.5), for: .highlighted)
        button.titleLabel?.font = button.titleLabel?.font.withSize(16)
        return button
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Finish", for: .normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.titleLabel?.font = button.titleLabel?.font.withSize(16)
        button.setBackgroundImage(UIImage.from(color: UIColor.red), for: .normal)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
}

class ImageEditMaskView: UIView {

    init() {
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        backgroundColor = UIColor.black
        alpha = 0.5
        
        layer.addSublayer(cropLayer)
        layer.mask = maskLayer
    }
    
    func setupMaskArea(ovalIn rect: CGRect) {
        let cropPath = UIBezierPath(ovalIn: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height))
        setupMaskArea(cropPath: cropPath)
    }
    
    func setupMaskArea(rect: CGRect) {
        let cropPath = UIBezierPath(rect: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height))
        setupMaskArea(cropPath: cropPath)
    }
    
    private func setupMaskArea(cropPath: UIBezierPath) {
        let path = UIBezierPath(rect: bounds)
        path.append(cropPath)
        
        maskLayer.path = path.cgPath
        cropLayer.path = cropPath.cgPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        return layer
    }()
    
    private let cropLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 4.0
        return layer
    }()
}

extension UIImage {
    public func cropping(to rect: CGRect) -> UIImage? {
        func rad(_ degree: Double) -> CGFloat {
            return CGFloat(degree / 180.0 * .pi)
        }
        
        var transform: CGAffineTransform
        switch imageOrientation {
        case .left:
            transform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
        case .right:
            transform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
        case .down:
            transform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
        default:
            transform = .identity
        }
        transform = transform.scaledBy(x: self.scale, y: self.scale)
        
        guard let cgImage = self.cgImage?.cropping(to: rect.applying(transform)) else { return nil }
        let result = UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        return result
    }
    
    public func upOrientated() -> UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public static func from(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return img!
    }
}
