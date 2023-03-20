//
//  FoldersLocationModelFactory.swift
//  AirBill
//
//  Created by Andrey on 22.08.2022.
//

import UIKit
import RealmSwift



struct FoldersLocationModelFactory: SubFoldersDelegate {
    
    let view: FolderLocationVCProtocol?
    private let rootFolders: Results<FolderRealm>
    private var editFolderID: String? = nil
    
    init(view: FolderLocationVCProtocol?, editFolderID: String? = nil) {
        self.view = view
        self.rootFolders = RealmManager.shared.getFolders().filter("nestedIndex == %@", 0).filter("isBin == false")
        self.editFolderID = editFolderID
    }
    
    
    private func getFoldersCells() -> [FoldersCellModel] {
        var foldersCellModels = [FoldersCellModel]()
        var allFolders = [FolderRealm]()
        
        for rootFolder in rootFolders {
            if editFolderID != nil && rootFolder.ID != editFolderID {
                allFolders.append(rootFolder)
                self.appendSubFolders(rootFolder, allFolders: &allFolders, editFolderID: editFolderID)
            } else if editFolderID == nil {
                allFolders.append(rootFolder)
                self.appendSubFolders(rootFolder, allFolders: &allFolders, editFolderID: editFolderID)
            }
            
            
        }
        
        for item in allFolders {
            let folder = FoldersCellModel(type: .folder(item), id: UUID(uuidString: item.ID), nestedIndex: item.nestedIndex, icon: R.image.defaultFolder()!, title: item.folderName, subtitle: "0", action: {
                }, typeAccessory: .nextWithText, actionExpand: {}, disabled: false, editable: true)
                foldersCellModels.append(folder)
        }
        
        return foldersCellModels
        
    }
    
    func makeLocationFolders() -> [FoldersSectionModel] {
        return [
             FoldersSectionModel(cells: getFoldersCells())
        ]
    }
    
    
}
