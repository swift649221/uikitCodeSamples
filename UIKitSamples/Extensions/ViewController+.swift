//
//  ViewController+.swift
//  AirBill
//
//  Created by Andrey on 28.07.2022.
//

import UIKit

extension UIViewController: Loading {}

extension Loading where Self : UIViewController {
    func startLoading(interactionDisabled: Bool = true) {
        DispatchQueue.main.async(execute: {
            self.view.isUserInteractionEnabled = interactionDisabled
            let activityView = UIActivityIndicatorView()
            activityView.style = .large
            activityView.tintColor = UIColor.white
            activityView.isHidden = false
            activityView.hidesWhenStopped = true
            self.view.addSubview(activityView)
            activityView.center = CGPoint(x: self.view.bounds.midX,
                                          y: self.view.bounds.midY-40)
            activityView.startAnimating()
        })
    }
    func stopLoading(interactionDisabled: Bool = true) {
        DispatchQueue.main.async(execute: {
            self.view.isUserInteractionEnabled = interactionDisabled
            self.view.subviews.forEach { view in
                if view is UIActivityIndicatorView {
                    view.removeFromSuperview()
                }
            }
        })
    }
}

protocol Loading {
    func startLoading(interactionDisabled: Bool)
    func stopLoading(interactionDisabled: Bool)
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
