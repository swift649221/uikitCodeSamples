//
//  UIBarButtonItem+Extensions.swift
//  AirBill
//
//  Created by Andrey on 21.07.2022.
//

import UIKit

extension UIBarButtonItem {
    func set(hide: Bool) {
        isEnabled = !hide
        tintColor = hide ? .clear : .systemBlue
    }
}
