//
//  FolderLocationCell.swift
//  AirBill
//
//  Created by Andrey on 22.08.2022.
//

import UIKit

class FolderLocationCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
     
    override func draw(_ rect: CGRect) {
        textLabel!.adjustsFontSizeToFitWidth = true
        selectionStyle = .none
        textLabel!.font = R.font.sfProTextRegular(size: 17)
        if let subtitleLabel = detailTextLabel {
            subtitleLabel.font = R.font.sfProTextRegular(size: 13)
        }
    }
    
    var model: FoldersCellModel! {
        didSet {
            imageView!.image = model.icon
            textLabel!.text = model.title
      }
    }
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
