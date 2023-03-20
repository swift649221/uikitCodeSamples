//
//  UIView+Extensions.swift
//  AirBill
//
//  Created by Andrey on 07.07.2022.
//

import UIKit

extension UIView {
    
    func startAnimation(duration: TimeInterval){
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
    
    func circle(){
        layer.cornerRadius = frame.size.height/2
        clipsToBounds = true
    }
    
    func roundCorners(radius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = .clear, clipsToBounds: Bool = true) {
        self.layer.cornerRadius = radius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = clipsToBounds
    }
    
    func rotate(duration: CFTimeInterval = 0.3, repeatCount: Float = 0, degree: NSNumber = NSNumber(value: Double.pi * 2)) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = degree
        rotation.duration = duration
        rotation.isCumulative = false
        rotation.repeatCount = repeatCount
        self.layer.add(rotation, forKey: "rotationAnimation")

    }
    
    func isVisible() -> Bool {
        func isVisible(view: UIView, inView: UIView?) -> Bool {
            guard let inView = inView else { return true }
            let viewFrame = inView.convert(view.bounds, from: view)
            if viewFrame.intersects(inView.bounds) {
                return isVisible(view: view, inView: inView.superview)
            }
            return false
        }
        return isVisible(view: self, inView: self.superview)
    }
    
    func createAccessoryMainView(image: UIImage, subtitle: String, hasSubfolders: Bool, isOpened: Bool) -> UIView {
        let imageRender = image.withRenderingMode(.alwaysTemplate)
        let customAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 19))
        let arrowImageView = UIImageView(frame: CGRect(x: 92, y: 3, width: 7, height: 13))
        arrowImageView.contentMode = .scaleAspectFill
        arrowImageView.image = imageRender
        isOpened ? arrowImageView.transform = arrowImageView.transform.rotated(by: .pi / 2) : nil
        arrowImageView.tintColor = hasSubfolders ? R.color.arrowColorAccessory() : R.color.arrowAccessory()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 20))
        label.font = R.font.sfProTextRegular(size: 17)
        label.textColor = R.color.greyColor()
        label.text = subtitle
        label.textAlignment = .right
        customAccessoryView.addSubview(label)
        customAccessoryView.addSubview(arrowImageView)
        return customAccessoryView
    }
    
    func createAccessorySubtitleView(subtitle: String) -> UIView {
        let customAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 19))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        label.font = R.font.sfProTextRegular(size: 17)
        label.textColor = R.color.greyColor()
        label.text = subtitle
        label.textAlignment = .right
        customAccessoryView.addSubview(label)
        return customAccessoryView
    }
    
    func createFooterView(frame: CGRect, text: String, footerLeftInset: CGFloat) -> UIView {
        let viewFooter = UIView(frame: frame)//CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: Constants.footerHeight))
        let footerLabel = UILabel(frame: CGRect(x: frame.origin.x + footerLeftInset, y: 0, width: frame.size.width, height: frame.size.height))
        footerLabel.text = text
        footerLabel.font = R.font.sfProTextRegular(size: 12)
        footerLabel.textColor = R.color.arrowAccessory()
        viewFooter.addSubview(footerLabel)
        return viewFooter
    }
    
    func createHeaderView(frame: CGRect, text: String) -> UIView {
        let headerView = UIView()
        let label = UILabel(frame: frame)
        label.textAlignment = .left
        label.font = R.font.sfProTextRegular(size: 12)
        label.textColor = R.color.greyColor()
        label.text = text
        headerView.addSubview(label)
        return headerView
    }
}

extension UIView {

    var x: CGFloat {
        get {
            self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }

    var y: CGFloat {
        get {
            self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }

    var height: CGFloat {
        get {
            self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }

    var width: CGFloat {
        get {
            self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
}
