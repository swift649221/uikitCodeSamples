//
//  UIImageView+.swift
//  AirBill
//
//  Created by Andrey on 17.08.2022.
//

import UIKit

extension UIImageView {
    func setImage(_ image: UIImage, animated shouldAnimate: Bool, rotate: Bool) {
        self.image = image
        
        if rotate {
            self.rotate()
        }
        
        if shouldAnimate {
            let animationKey = "hub_imageAnimation"
            layer.removeAnimation(forKey: animationKey)
            
            let animation = CATransition()
            animation.duration = 0.3
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            layer.add(animation, forKey: animationKey)
            
        }
    }
    
    
    
    
    
}
