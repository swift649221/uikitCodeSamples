//
//  FoldersMainCell.swift
//  AirBill
//
//  Created by Andrey on 09.08.2022.
//

import UIKit

class FoldersMainCell: UITableViewCell {
    
    enum Constant {
        static let inset: CGFloat = 8
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
//        textLabel!.adjustsFontSizeToFitWidth = true
//        selectionStyle = .none
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
    
    
    var model: FoldersCellModel! {
        didSet {
            clipsToBounds = true
            imageView!.image = model.icon
            imageView!.image = model.type == .new ? imageView!.image?.withRenderingMode(.alwaysOriginal) : imageView!.image?.withRenderingMode(.alwaysTemplate)
            imageView!.tintColor = model.disabled ? R.color.disabledColor() : .systemBlue
            textLabel!.text = model.title
            
            switch model.cellTextLabelColor {
            case .systemBlue:
                textLabel!.textColor = .systemBlue
            default:
                textLabel!.textColor = model.disabled ? R.color.disabledColor() : R.color.blackWhiteTheme()
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
            case .subtitle:
                accessoryView = contentView.createAccessorySubtitleView(subtitle: model.subtitle)
            default:
                accessoryType = .disclosureIndicator
            }
            
      }
    }
    
    func contentOffset() {
       layoutMargins = UIEdgeInsets(top: 0, left: (CGFloat(model.nestedIndex ?? 0)+1) * Constant.inset, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func accessoryTap(_ sender: UITapGestureRecognizer? = nil) {
        if let model = model {
            if model.countSublolsers > 0   {
                model.actionExpand()
            } else {
                model.action()
            }
        }
    }
}

