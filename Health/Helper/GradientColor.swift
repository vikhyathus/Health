//
//  GradientColor.swift
//  Health
//
//  Created by Vikhyath on 01/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import UIKit

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

//extension UINavigationBar {
//    
//     func setGradientBackgroundNav(colorOne: UIColor, colorTwo: UIColor) {
//        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
//        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
//        
//        layer.insertSublayer(gradientLayer, at: 0)
//    }
//}
