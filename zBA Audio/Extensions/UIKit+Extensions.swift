//
//  UIKit+Extensions.swift
//  zBA Audio
//
//  Created by Syon on 15/03/19.
//  Copyright © 2019 Syon. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func cornerRadiusWithoutAnimation(cornerRadius: CGFloat) {
        let button = self
        button.layer.cornerRadius = cornerRadius
        button.layer.borderColor = UIColor.green.cgColor
        button.layer.masksToBounds = false
    }
    
    func cornerRadius(cornerRadius: CGFloat) {
        let button = self
        button.layer.cornerRadius = cornerRadius
        button.layer.borderColor = UIColor.green.cgColor
        button.layer.masksToBounds = false
        
        playingAnimation(buttonView: button)
    }
}

public let shapeLayer = CAShapeLayer()
//public let pulsatingLayer = CAShapeLayer()

func playingAnimation(buttonView: UIButton) {
    
    shapeLayer.frame = buttonView.bounds
//    pulsatingLayer.frame = buttonView.bounds
    
    let lineWidth:CGFloat = 1
    let rectFofOval = CGRect(x: lineWidth / 2, y: lineWidth / 2, width: buttonView.bounds.width - lineWidth, height: buttonView.bounds.height - lineWidth)
    
    let circlePath = UIBezierPath(ovalIn: rectFofOval)

//    pulsatingLayer.path = circlePath.cgPath
//    pulsatingLayer.strokeColor = UIColor.orange.cgColor
//    pulsatingLayer.lineWidth = 10
//    pulsatingLayer.fillColor = UIColor.clear.cgColor
//    pulsatingLayer.lineCap = .round
//    buttonView.layer.addSublayer(pulsatingLayer)
//
//    animationPulsatingLayer()
    
    shapeLayer.path = circlePath.cgPath
    shapeLayer.strokeColor = UIColor.orange.cgColor
    shapeLayer.strokeEnd = 0
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = 5
    shapeLayer.lineCap = .round
    buttonView.layer.addSublayer(shapeLayer)
    recordingVoice()
}

func recordingVoice() {
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    basicAnimation.toValue = 1
    basicAnimation.duration = 2
    basicAnimation.fillMode = .forwards
    basicAnimation.repeatCount = .infinity
    shapeLayer.add(basicAnimation, forKey: "recording")
}

func animationPulsatingLayer() {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.toValue = 1.5
    animation.duration = 1
    animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
    animation.autoreverses = true
    animation.repeatCount = .infinity
//    pulsatingLayer.add(animation, forKey: "pulsatingLayer")
    
}

func removeAnimation() {
    shapeLayer.removeAllAnimations()
    shapeLayer.superlayer?.removeAllAnimations()
//    pulsatingLayer.removeAllAnimations()
}
