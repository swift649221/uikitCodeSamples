//
//  UICollectionView.swift
//  AirBill
//
//  Created by Andrey on 17.08.2022.
//

import UIKit

extension UICollectionView {

    func register<View: ReusableView>(_ type: View.Type) {
        if type is UITableViewCell.Type {
            register(type.nib, forCellWithReuseIdentifier: type.reuseKey)
        } else {
            register(type.nib, forCellWithReuseIdentifier: type.reuseKey)
        }
    }
}
