//
//  MoveMenuCell.swift
//  AirBill
//
//  Created by Andrey on 26.08.2022.
//

import UIKit

class MoveMenuCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
//        textLabel!.adjustsFontSizeToFitWidth = true
        selectionStyle = .none
        textLabel!.font = R.font.sfProTextRegular(size: 17)
        if let subtitleLabel = detailTextLabel {
            subtitleLabel.font = R.font.sfProTextRegular(size: 13)
        }
        
        textLabel!.translatesAutoresizingMaskIntoConstraints = false
        textLabel!.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        textLabel!.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

        textLabel!.leftAnchor.constraint(equalTo: self.imageView!.rightAnchor, constant: 15).isActive = true
        textLabel!.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        
    }
    
    var model: MoveMenuItem! {
        didSet {
            clipsToBounds = true
            contentView.clipsToBounds = true
            if let model = model {
                imageView!.image = model.icon
                textLabel!.text = model.type.title
                imageView!.image = imageView!.image?.withRenderingMode(.alwaysTemplate)
                imageView!.tintColor = model.disabled ? R.color.disabledColor() : .systemBlue
                
                if model.disabled {
                    textLabel!.textColor = R.color.disabledColor()
                }
                 
                switch model.typeAccessory {
                case .next:
                    accessoryView = contentView.createAccessoryMainView(image: model.countSublolsers == 0 ? R.image.settingsArrow()! : R.image.rightBlueArrow()!, subtitle: "", hasSubfolders: model.countSublolsers != 0, isOpened: model.opened)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.accessoryTap(_:)))
                    accessoryView!.addGestureRecognizer(tap)
                case .nextWithText:
                    accessoryView = contentView.createAccessoryMainView(image: model.countSublolsers == 0 ? R.image.settingsArrow()! : R.image.rightBlueArrow()!, subtitle: model.subtitle, hasSubfolders: model.countSublolsers != 0, isOpened: model.opened)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.accessoryTap(_:)))
                    accessoryView!.addGestureRecognizer(tap)
                case .none:
                    accessoryView = UIView()
                default:
                    accessoryType = .disclosureIndicator
                }
            }
        }
    }
    
    @objc func accessoryTap(_ sender: UITapGestureRecognizer? = nil) {
        if let model = model {
            model.actionExpand()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
