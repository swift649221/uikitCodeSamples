//
//  MoveMenuPresenter.swift
//  AirBill
//
//  Created by Andrey on 19.08.2022.
//

import UIKit

enum TypeMoveMenuItem {
    
    case folder(FolderRealm)
    case inbox
    case trash
    
    var title: String {
        get {
            switch self {
            case .folder(let folderRealm):
                return folderRealm.folderName
            case .inbox:
                return R.string.localizable.foldersInbox(preferredLanguages: [Settings.shared.langRawValue])
            case .trash:
                return R.string.localizable.foldersTrash(preferredLanguages: [Settings.shared.langRawValue])
            }
        }
    }
}

struct MoveMenuItem {
    let type: TypeMoveMenuItem
    let icon: UIImage
    let disabled: Bool
    let typeAccessory: TypeAccessory
    var selected = true
    var action: () -> Void
    var actionExpand: () -> Void
    var nestedIndex: Int? = 0
    var parentId: String = ""
    var Id: String = ""
    var opened: Bool = false
    var countSublolsers = 0
    var subtitle: String = ""
}

protocol MoveMenuVCProtocol: UIViewController {
    var presenter: MoveMenuPresenterProtocol { get set }
    func moveTo(index: Int)
    func expand(index: Int)
    func removeWith(_ index: Int)
    func reloadView(image: UIImage, titleInfo: String, textInfo: String)
    func reloadTableView()
    func closeVC()
}

protocol MoveMenuPresenterProtocol: AnyObject {
    
    var managedView: MoveMenuVCProtocol? { get set }
    var backButtonTitle: String { get set }
    var items: [MoveMenuItem] { get set }
    var bills: [BillRealm] { get set }
    var folders: [FolderRealm] { get set }
    var type: TypeList { get set }
    func getItem(at index: Int) -> MoveMenuItem?
    func createData()
    func deleteWithRealm()
    func updateFolders()
    func moveBills(index: Int)
    func expandFolders(index: Int)
    func addNewFolder(_ folder: FolderRealm, locationFolderID: UUID?)
}

class MoveMenuPresenter: MoveMenuPresenterProtocol {
    
    init(bills: [BillRealm], backButtonTitle: String, type: TypeList) {
        self.bills = bills
        self.backButtonTitle = backButtonTitle
        self.type = type
        folders = RealmManager.shared.getFolders().toArray()
    }
    
    weak var managedView: MoveMenuVCProtocol?
    var backButtonTitle: String
    var bills: [BillRealm]
    var folders: [FolderRealm]
    var items: [MoveMenuItem] = []
    var type: TypeList
    
    private func moveBills(to folderId: String){
        bills.forEach {
            RealmManager.shared.updateFolderIdInBill($0, folderId: folderId)
        }
    }
    
    func updateFolders(){
        folders = RealmManager.shared.getFolders().toArray()
        createData()
    }
    
    func moveBills(index: Int) {
        moveBills(to: items[index].Id)
        if let managedView = managedView {
            managedView.moveTo(index: index)
        }
    }
    
    func remove(index: Int){
        if let managedView = managedView {
            managedView.removeWith(index)
        }
    }
    
    func deleteWithRealm(){
        if let managedView = managedView {
            if Settings.shared.deleteConfimation {
                Router.shared.showDeleteAlert(vc: managedView, actionClosure: { [weak self] in
                    guard let self = self else { return }
                    RealmManager.shared.removeBills(self.bills)
                    managedView.closeVC()
                }, count: bills.count)
            }else{
                RealmManager.shared.removeBills(bills)
                managedView.closeVC()
            }
        }
    }
    
    func createData(){
        
        var title = ""
        var image = UIImage()
        var text = ""

        if let billFirst = bills.first {
            image = billFirst.imagePreview
            if bills.count > 1 {
                title = R.string.localizable.moveMenuMore(billFirst.name, bills.count-1, preferredLanguages: [Settings.shared.langRawValue])
                text = R.string.localizable.moveMenuBills(bills.count, preferredLanguages: [Settings.shared.langRawValue])
            }else{
                title = billFirst.name
                text = billFirst.info
            }
        }
        items = MoveMenuFactory(view: managedView, presenter: self).makeMenuItems()
        if let managedView = managedView {
            managedView.reloadView(image: image, titleInfo: title, textInfo: text)
            managedView.reloadTableView()
        }
    }
    
    func getItem(at index: Int) -> MoveMenuItem? {
        return items[safe: index]
    }
    
    func addNewFolder(_ folder: FolderRealm, locationFolderID: UUID? = nil) {
        if let locationFolderID = locationFolderID {
            RealmManager.shared.addSubFolderToFolderWithID(folder, locationId: locationFolderID)
        } else {
            var folders: [FolderRealm] = []
            folders.append(folder)
            RealmManager.shared.saveFolders(folders)
        }
    }
    
    // MARK: EXPAND LOGIC
    func expandFolders(index: Int) {
        if let tapped = items[safe: index] {
        items[index].opened.toggle()
            toogleAllChilds(id: tapped.Id, close: items[index].opened)
        }
    }
    
    private func toogleAllChilds(id: String, close: Bool){
        for (i ,item) in items.enumerated() {
            if item.parentId == id {
                items[i].selected = close
                if let managedView = managedView {
                    managedView.expand(index: i)
                }
                if !items[i].selected {
                    items[i].opened = false
                    toogleAllChilds(id: items[i].Id, close: items[i].selected)
                }
            }
        }
    }
}
