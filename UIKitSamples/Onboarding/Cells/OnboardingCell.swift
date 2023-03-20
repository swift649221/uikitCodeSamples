//
//  OnboardingCell.swift
//  AirBill
//
//  Created by Andrey on 17.08.2022.
//

import UIKit

class OnboardingCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = R.font.sfProDisplayLight(size: 37)
        titleLabel.textColor = .black
        contentView.backgroundColor = .white
    }

    var model: OnboardingItemModel! {
        didSet {
            if let model = model {
                titleLabel.text = model.title
                infoLabel.attributedText = model.attributedText
            }
        }
    }
}
