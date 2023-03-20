//
//  FoldersModelFactory.swift
//  AirBill
//
//  Created by Andrey on 09.08.2022.
//

import UIKit
import RealmSwift

enum CellTextLabelColor: String {
    case systemBlue
    case black
}

class FoldersModelFactory {
    
    let view: FoldersVCProtocol?
    private let allBills: Results<BillRealm>
    private let unreadBills: Results<BillRealm>
    private let flaggedBills: Results<BillRealm>
    private let allFolders: Results<FolderRealm>
    var foldersCellModels = [FoldersCellModel]()
    var presenter: FoldersPresenter
    
    init(view: FoldersVCProtocol?, presenter: FoldersPresenter) {
        self.view = view
        self.allBills = RealmManager.shared.getBillsByTypeList()
        self.unreadBills = RealmManager.shared.getBillsResultWithStatus(.unread)
        self.flaggedBills = RealmManager.shared.getBillsResultWithStatus(.flagged)
        self.allFolders = RealmManager.shared.getFolders()
        self.presenter = presenter
    }
    
    private func makeFoldersItems(_ folders: [FolderRealm], isEditing: Bool) {
        for folder in folders {
            var parentId = ""
            if let parent = folder.folder.first {
                parentId = parent.ID
            }
            let billsCount = RealmManager.shared.searchBillsByTypeList(withOrder: .dateNewToOld, typeFilter: .readMarkOnly, typeList: .folder(folder), isDeleted: false).count
            foldersCellModels.append(FoldersCellModel(type: .folder(folder), id: UUID(uuidString: folder.ID), nestedIndex: folder.nestedIndex, icon: folder.isBin ? R.image.trash()! : R.image.defaultFolder()!, title: folder.folderName, subtitle: billsCount == 0 ? "" : String(billsCount), action: {}, typeAccessory: isEditing ? (folder.subfolders.count == 0 ? .subtitle : .nextWithText) : (billsCount == 0 ? .next : .nextWithText), cellTextLabelColor: .black, selected: folder.nestedIndex == 0 ? true : false, countSublolsers: folder.subfolders.count, parentId: parentId, actionExpand: {}, disabled: false, editable: true))
            if !folder.subfolders.isEmpty {
                makeFoldersItems(folder.subfolders.compactMap{ $0 }, isEditing: isEditing)
            }
        }
    }
    
    func getCreatedFoldersCells(isEditing: Bool) -> [FoldersCellModel] {
        
        let inboxCount = RealmManager.shared.searchBillsByTypeList(withOrder: .dateNewToOld, typeFilter: .readMarkOnly, typeList: .inbox, isDeleted: false).count
        let trashCount = RealmManager.shared.searchBillsByTypeList(withOrder: .dateNewToOld, typeFilter: .readMarkOnly, typeList: .trash, isDeleted: true).count
        
        let inboxCell: FoldersCellModel  = FoldersCellModel(type: .inbox, icon: R.image.inbox()!, title: R.string.localizable.foldersInbox(), subtitle: inboxCount == 0 ? "" : String(inboxCount), action: {
        }, typeAccessory: isEditing ? .subtitle : ( inboxCount == 0 ? .next : .nextWithText), actionExpand: {}, disabled: isEditing ? true : false)
        
        
        let trashCell: FoldersCellModel = FoldersCellModel(type: .trash, icon: R.image.trash()!, title: R.string.localizable.foldersTrash(), subtitle: trashCount == 0 ? "" : String(trashCount), action: {
        }, typeAccessory: isEditing ? .subtitle : (trashCount == 0 ? .next : .nextWithText), actionExpand: {}, disabled: isEditing ? true : false)
        
        foldersCellModels.append(inboxCell)
        
        makeFoldersItems(RealmManager.shared.getFoldersFirst(nestedLevel: 0, folderIds: []).toArray().sorted(by: { !$0.isBin && $1.isBin }), isEditing: isEditing)
        
        //foldersCellModels.append(trashCell)
        
        for (index, folder) in foldersCellModels.enumerated() {
            switch folder.type {
            case .folder(_):
                if let id = folder.id {
                    foldersCellModels[index].action = { self.openBills(withId: id.uuidString) }
                }
                foldersCellModels[index].actionExpand = { self.presenter.expandFolders(index: index) }
            case .inbox:
                foldersCellModels[index].action = { self.openBills(withType: .inbox) }
            case .trash:
                foldersCellModels[index].action = { self.openBills(withType: .trash) }
            case .notified:
                foldersCellModels[index].action = { self.openBills(withType: .unread) }
            case .tagged(let tag):
                foldersCellModels[index].action = { self.openBills(withType: .tagged(tag)) }
            case .all, .flagged, .unread, .new, .none:
                break
            }
        }
        return foldersCellModels
    }
    
    
    func makeMainFolders(isEditing: Bool) -> [FoldersSectionModel] {
        var sections = [FoldersSectionModel]()
        
        let mainfolders = RealmManager.shared.getMainFoldersResult().sorted(byKeyPath: "index", ascending: true).filter("isSelected == true")
        var folders = [FoldersCellModel]()
        
        mainfolders.forEach { folder in
            
            let billsCount = folder.type == "flagged" ?   RealmManager.shared.searchBillsByTypeList(withOrder: .dateNewToOld, typeList: MainFolderType.getBillsType(MainFolderType(rawValue: folder.type) ?? .all, mainFolder: folder), isDeleted: false).count : RealmManager.shared.searchBillsByTypeList(withOrder: .dateNewToOld, typeFilter: .readMarkOnly, typeList: MainFolderType.getBillsType(MainFolderType(rawValue: folder.type) ?? .all, mainFolder: folder), isDeleted: false).count
            
            folders.append(FoldersCellModel(mainFolderType: MainFolderType(rawValue: folder.type), id: UUID(uuidString: folder.id), icon: MainFolderType(rawValue: folder.type)?.image, title: MainFolderType(rawValue: folder.type)?.title(mainFolder: folder) ?? "", subtitle: String(billsCount), action: { self.openBills(withType: MainFolderType.getBillsType(MainFolderType(rawValue: folder.type)!, mainFolder: folder)) }, typeAccessory: billsCount == 0 ? .next : .nextWithText, actionExpand: {}, mainFoldersSelected: folder.isSelected))
        }
        sections.append(FoldersSectionModel(cells: folders))
        
        if isEditing {
            sections[0].cells.removeAll()
            
            let allmainfolders = RealmManager.shared.getMainFoldersResult().sorted(byKeyPath: "index", ascending: true).toArray()
            var folders = [FoldersCellModel]()
            allmainfolders.forEach { folder in
                let billsCount = RealmManager.shared.searchBillsByTypeList(withOrder: .dateNewToOld, typeFilter: .readMarkOnly, typeList: MainFolderType.getBillsType(MainFolderType(rawValue: folder.type) ?? .all, mainFolder: folder), isDeleted: false).count
                folders.append(FoldersCellModel(mainFolderType: MainFolderType(rawValue: folder.type), id: UUID(uuidString: folder.id), icon: MainFolderType(rawValue: folder.type)?.image, title: MainFolderType(rawValue: folder.type)?.title(mainFolder: folder) ?? "", subtitle: String(billsCount), action: { self.openBills(withType: MainFolderType.getBillsType(MainFolderType(rawValue: folder.type)!, mainFolder: folder)) }, typeAccessory: billsCount == 0 ? .next : .nextWithText, actionExpand: {}, mainFoldersSelected: folder.isSelected))
            }
            sections[0].cells.append(contentsOf: folders)
        }
        
        if RealmManager.shared.getFolders().filter("isBin == false").isEmpty {
            sections.append(FoldersSectionModel(cells: [FoldersCellModel(type: .new, icon: R.image.addfolder()!, title: TypeList.new.title, subtitle: "", action: {
                let newVC = NewFolderVC()
                newVC.foldersVCDelegate = self.view as? FoldersVCDelegate
                self.presentTo(vc: newVC )
                }, typeAccessory: .next, cellTextLabelColor: .systemBlue, actionExpand: {}, disabled: false)]))
        }
        
        sections.append(FoldersSectionModel(cells: getCreatedFoldersCells(isEditing: isEditing)))
        
        return sections
    }
    
    private func openBills(withId: String){
        presenter.openBills(withId: withId)
    }
    
    private func openBills(withType: TypeList){
        presenter.openBills(withType: withType)
    }
    
    private func pushTo(vc: UIViewController){
        if let view = view {
            view.pushToViewController(vc: vc)
        }
    }
    
    private func presentTo(vc: UIViewController){
        if let view = view {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .automatic
            view.present(navigationController, animated: true)
        }
    }
    
    
    
}

