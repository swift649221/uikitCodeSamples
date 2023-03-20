//
//  MoveMenuFactory.swift
//  AirBill
//
//  Created by Andrey on 19.08.2022.
//

import UIKit

//enum TypeMoveAction {
//    case move
//    case delete
//}

class MoveMenuFactory {

    weak var view: MoveMenuVCProtocol?
    var presenter: MoveMenuPresenter
    var moveItems: [MoveMenuItem] = []
    
    init(view: MoveMenuVCProtocol?, presenter: MoveMenuPresenter) {
        self.view = view
        self.presenter = presenter
    }
    
    // MARK: EXPAND LOGIC
    //вытягиваем childs и создаем из них items
    private func makeFoldersItems(_ folders: [FolderRealm]) {
        for folder in folders {
            var parentId = ""
            if let parent = folder.folder.first {
                parentId = parent.ID
            }
            let billsCount = RealmManager.shared.searchBillsByTypeList(withOrder: .dateNewToOld, typeFilter: .readMarkOnly, typeList: .folder(folder), isDeleted: false).count
            let parentFolder = presenter.type.folder
            moveItems.append(MoveMenuItem(type: .folder(folder), icon: folder.isBin ? R.image.trash()! : R.image.defaultFolder()!, disabled: parentFolder?.ID == folder.ID ? true : false, typeAccessory: billsCount == 0 ? .next : .nextWithText, selected: folder.nestedIndex == 0 ? true : false, action: {}, actionExpand: {}, nestedIndex: folder.nestedIndex, parentId: parentId, Id: folder.ID, countSublolsers: folder.subfolders.count, subtitle: billsCount == 0 ? "" : String(billsCount)))
            if !folder.subfolders.isEmpty {
                makeFoldersItems(folder.subfolders.compactMap{ $0 })
            }
        }
    }
    func makeMenuItems() -> [MoveMenuItem] {
    
        moveItems = [MoveMenuItem(type: .inbox, icon: R.image.inboxDisabled()!, disabled: presenter.backButtonTitle == "Inbox" ? true : false, typeAccessory: .none, action: {}, actionExpand: {})]
        makeFoldersItems(RealmManager.shared.getFoldersFirst(nestedLevel: 0, folderIds: []).toArray().sorted(by: { !$0.isBin && $1.isBin }))
        
        let trashCount = RealmManager.shared.searchBillsByTypeList(withOrder: .dateNewToOld, typeFilter: .readMarkOnly, typeList: .trash, isDeleted: true).count
        
//        moveItems.append(MoveMenuItem(type: .trash, icon: R.image.trash()!, disabled: presenter.type == .trash ? true : false, typeAccessory: trashCount == 0 ? .next : .nextWithText, action: {}, actionExpand: {}, subtitle: trashCount == 0 ? "" : String(trashCount)))

        for (index, folder) in moveItems.enumerated() {
            
            switch folder.type {
            case .folder(_):
                if folder.disabled {
                    moveItems[index].action = {}
                } else {
                    moveItems[index].action = { self.moveBills(to: index) }
                }
                moveItems[index].actionExpand = { self.expandBills(to: index) }
            case .inbox:
                if presenter.backButtonTitle == "Inbox" {
                    moveItems[index].action = {}
                } else {
                    moveItems[index].action = {
                        self.moveBills(to: index)
                    }
                }
            case .trash:
                if folder.disabled {
                    moveItems[index].action = {}
                    moveItems[index].actionExpand = {}
                } else {
                    moveItems[index].action = { self.removeBills(index: index) }
                    moveItems[index].actionExpand = { self.removeBills(index: index) }
                }
            }
        }
        return moveItems
    }
    
    private func removeBills(index: Int){
        presenter.remove(index: index)
    }
    
    private func expandBills(to index: Int){
        presenter.expandFolders(index: index)
    }
    
    private func moveBills(to index: Int){
        presenter.moveBills(index: index)
    }
}
