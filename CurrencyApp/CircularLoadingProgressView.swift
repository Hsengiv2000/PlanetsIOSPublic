//
//  ProgressView.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 10/12/22.
//

import Foundation

import UIKit

class CircularLoadingProgressView: UIView {
    
    private let progressCircleShapeLayer = CAShapeLayer().then {
        $0.strokeColor = UIColor.red.cgColor
        $0.lineWidth = 5
        $0.fillColor = UIColor.clear.cgColor
        $0.lineCap = .round
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.width / 2
        let path = UIBezierPath(ovalIn:
                                    CGRect(
                                        x: 0,
                                        y: 0,
                                        width: self.bounds.width,
                                        height: self.bounds.width
                                    )
        )
        
        progressCircleShapeLayer.path = path.cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    func animateStroke() {
        self.isHidden = false
        
        let startAnimation = StrokeAnimation(
            type: .start,
            beginTime: 0.25,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )
        
        let endAnimation = StrokeAnimation(
            type: .end,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )
        
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation, endAnimation]
    
        progressCircleShapeLayer.add(strokeAnimationGroup, forKey: nil)
    
        self.layer.addSublayer(progressCircleShapeLayer)
    }
    
    func stopAnimation() {
    
        progressCircleShapeLayer.removeAllAnimations()
        self.isHidden = true
    }
    
}


//MARK: - Stroke Animation
class StrokeAnimation: CABasicAnimation {
   
    enum StrokeType {
        case start
        case end
    }
    
    override init() {
        super.init()
    }
    
    init(type: StrokeType,
         beginTime: Double = 0.0,
         fromValue: CGFloat,
         toValue: CGFloat,
         duration: Double) {
        
        super.init()
        
        self.keyPath = type == .start ? "strokeStart" : "strokeEnd"
        
        self.beginTime = beginTime
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
