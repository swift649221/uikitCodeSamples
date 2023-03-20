//
//  UiTableView+Extensions.swift
//  AirBill
//
//  Created by Andrey on 06.07.2022.
//

import UIKit

extension UITableView {
    
    func register<View: ReusableView>(_ type: View.Type) {
        if type is UITableViewCell.Type {
            register(type.nib, forCellReuseIdentifier: type.reuseKey)
        } else {
            register(type.nib, forHeaderFooterViewReuseIdentifier: type.reuseKey)
        }
    }
    
    func dequeueCell<Cell: ReusableView>(_ type: Cell.Type, for indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: type.reuseKey, for: indexPath)
    }
    
    func setEditing(edit: Bool, animated: Bool = true){
        if isEditing == edit {
            setEditing(edit: !isEditing, completionHandler: { [weak self] in
                guard let self = self else { return }
                //для полного сброса editing mode во всех ячейках
                self.reloadData { [unowned self] in
                    UIView.animate(withDuration: 0.2) {
                        self.setEditing(edit, animated: false)
                    }
                    
                }
            })
        }else{
            UIView.animate(withDuration: 0.2) {
                self.setEditing(edit: edit, animated: false) {
                    self.reloadData()
                }
            }
        }
    }
    
    private func setEditing(edit: Bool, animated: Bool = true, completionHandler: @escaping () -> ()) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completionHandler()
        }
        self.setEditing(edit, animated: animated)
        CATransaction.commit()
    }
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: reloadData)
                { _ in completion() }
    }
    
}
