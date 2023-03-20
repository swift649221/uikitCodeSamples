//
//  RealmManager.swift
//  AirBill
//
//  Created by Andrey on 07.07.2022.
//

import Foundation
import RealmSwift

enum SearchFilter {
    case readMark(_ text: String)
    case flagMark(_ text: String)
    case notify(_ text: String)
    case tag(_ text: String, _ id: String)
    case text(_ text: String)
    //case trash(_ text: String)
    //case inbox(_ text: String)
    case readMarkOnly
    case flagMarkOnly
    case notifyOnly
    case tagOnly(_ tagId: String)
    //case trashOnly
    //case inboxOnly
    
    var predicate: NSPredicate {
        
        switch self {
        case .readMark(let text):
            return NSPredicate(format: "name CONTAINS[c] %@ AND readMark == false", text)
        case .flagMark(let text):
            return NSPredicate(format: "name CONTAINS[c] %@ AND flagMark == true", text)
        case .notify(let text):
            return NSPredicate(format: "name CONTAINS[c] %@ AND notify == true", text)
        case .tag(let text, let id):
            return NSPredicate(format: "name CONTAINS[c] %@ AND ANY tags.ID == %@", text, id)
        case .text(let text):
            return NSPredicate(format: "name CONTAINS[c] %@", text)
        //case .trash(let text):
        //    return NSPredicate(format: "name CONTAINS[c] %@ AND isDeleted == true", text)
        case .readMarkOnly:
            return NSPredicate(format: "readMark == false")
        case .flagMarkOnly:
            return NSPredicate(format: "flagMark == true")
        case .notifyOnly:
            return NSPredicate(format: "notify == true")
        case .tagOnly(let id):
            return NSPredicate(format: "ANY tags.ID == %@", id)
        //case .trashOnly:
            //return NSPredicate(format: "isDeleted == true")
        //case .inbox(let text):
            //return NSPredicate(format: "name CONTAINS[c] %@ AND inboxMark == true", text)
        //case .inboxOnly:
            //return NSPredicate(format: "inboxMark == true")
        }
    }
    
    func createPredicate(withLocation: TypeList){
        
    }
}

enum BillsSort: String {
    
    typealias SortDescriptor = RealmSwift.SortDescriptor
    
    case nameAtoZ, nameZtoA, dateOldToNew, dateNewToOld, priceHightToLow, priceLowToHight
    
    var sortDescriptor: SortDescriptor {
        switch self {
        case .nameAtoZ:
            return SortDescriptor(keyPath: "name", ascending: true)
        case .nameZtoA:
            return SortDescriptor(keyPath: "name", ascending: false)
        case .dateOldToNew:
            return SortDescriptor(keyPath: "dateCreated", ascending: true)
        case .dateNewToOld:
            return SortDescriptor(keyPath: "dateCreated", ascending: false)
        case .priceHightToLow:
            return SortDescriptor(keyPath: "price", ascending: false)
        case .priceLowToHight:
            return SortDescriptor(keyPath: "price", ascending: true)
        }
    }
}

enum BillStatus {
    case flagged
    case unread
}

enum TypeToUpdate {
    case flag, read, notify, pin
}

class RealmManager: NSObject {
    
    static let shared = RealmManager()
    var realm: Realm!
    
    override init() {
        super.init()
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)//что бы пока не писать миграции каждый раз
        
        realm = try! Realm.init(configuration: config)
        
        let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
        print("folder = \(folderPath)")
    }
    
    private func deleted(_ isDeleted: Bool) -> String {
        return "isDeleted == \(isDeleted)"
    }
    
    // MARK: - Folders
        
    func getFolders() -> Results<FolderRealm> {
        return realm.objects(FolderRealm.self)
    }
    
    func binExist() -> Bool {
        return realm.objects(FolderRealm.self).filter("isBin == true").isEmpty ? false : true
    }
    
    func getBinFolderId() -> String? {
        guard let binFolder = realm.objects(FolderRealm.self).filter("isBin == true").first else {
            return nil
        }
        return binFolder.ID
    }
    
    func getFoldersFirst(nestedLevel: Int, folderIds: [String]) -> Results<FolderRealm> {
        return realm.objects(FolderRealm.self).filter("nestedIndex == %d OR ANY folder.ID IN %@", nestedLevel, folderIds)
    }
    
    func saveFolders(_ folders: [FolderRealm]){
        try! realm.write {
            realm.add(folders, update: .modified)
        }
    }

    func addSubFolderToFolderWithID(_ subfolder: FolderRealm, locationId: UUID) {
        guard let folder = self.getFolder(withId: locationId.uuidString).first  else {return}
        
        try! realm.write {
            subfolder.idParentFolder = locationId.uuidString
            folder.subfolders.append(objectsIn: [subfolder])
            realm.add(folder, update: .modified)
        }
        
        var allSubFolders = [FolderRealm]()
        addSubFoldersToArray(folder, allSubFolders: &allSubFolders)
        allSubFolders.append(folder)
        
        updateSubFoldersIndexes(allSubFolders)
    }
    
    func getFolder(withId: String) -> [FolderRealm] {
        return  realm.objects(FolderRealm.self).filter("ID == %@", withId).toArray()
    }
    
    func getRootFolder(child: FolderRealm) -> [FolderRealm] {
        return  realm.objects(FolderRealm.self).filter("ID == %@", child.idParentFolder).toArray()
    }
    
    
    func removeAllFolders() {
        try! realm.write {
            realm.delete(realm.objects(FolderRealm.self))
        }
    }
    
    func removeFolders(_ folders: [FolderRealm]) {
        try! realm.write {
            realm.delete(folders)
        }
    }
    
    func removeFolders(withIds: [UUID]) {
        try! realm.write {
            let objectsToDelete = realm.objects(FolderRealm.self).filter("ID IN %@", withIds)
            realm.delete(objectsToDelete)
        }
    }
    
    func saveMainFolder(_ folder: MainFolderRealm) {
        try! realm.write {
            realm.add(folder, update: .modified)
        }
    }
    
    func saveMainFolders(_ folders: [MainFolderRealm]) {
        try! realm.write {
            realm.add(folders, update: .modified)
        }
    }
    
    func removeAllMainFolders() {
        try! realm.write {
            realm.delete(realm.objects(MainFolderRealm.self))
        }
    }
    
    func getMainFoldersResult() -> Results<MainFolderRealm> {
        return realm.objects(MainFolderRealm.self)
    }
    
    func getMainFolders() -> [MainFolderRealm] {
        return realm.objects(MainFolderRealm.self).toArray()
    }
    
    func removeMainFolder(withId: String) {
        guard let folder = realm.objects(MainFolderRealm.self).filter("id == %@", withId).toArray().first else { return }
        try! realm.write {
            realm.delete(folder)
        }
    }
    
    func getMainFolder(withId: String) -> [MainFolderRealm] {
        return  realm.objects(MainFolderRealm.self).filter("id == %@", withId).toArray()
    }
    
    func getMainFolder(withType: String) -> [MainFolderRealm] {
        return  realm.objects(MainFolderRealm.self).filter("type == %@", withType).toArray()
    }
    
    func setMainFoldersSelected(folders: [MainFolderRealm]) {
        realm.beginWrite()
        folders.forEach({ folder in
            folder.isSelected = true
        })
        try! realm.commitWrite()
    }
    
    func setMainFolderDeselected(folder: MainFolderRealm) {
        realm.beginWrite()
        folder.isSelected = false
        try! realm.commitWrite()
    }
    
    func updateFolderData(_ folder: FolderRealm, folderName: String, idParentFolder: String?) {
        if let idParentFolder = idParentFolder, let parentFolder = getFolder(withId: idParentFolder).first, let locationId = UUID(uuidString: idParentFolder) {
            
            var allSubFolders = [FolderRealm]()
            addSubFoldersToArray(folder, allSubFolders: &allSubFolders)
            allSubFolders.append(folder)
            
            
            if idParentFolder == getBinFolderId() || parentFolder.isDeleted == true {
                putFoldersVsBillsToDeletedState(allSubFolders, deleted: true)
            } else {
                putFoldersVsBillsToDeletedState(allSubFolders, deleted: false)
            }
            
            
            try! realm.write {
                folder.nestedIndex = parentFolder.nestedIndex + 1
                folder.folderName = folderName
                if let oldParentFolder = getFolder(withId: folder.idParentFolder).first, let subfolderIndexToRemove = oldParentFolder.subfolders.firstIndex(where: {$0 == folder}) {
                    oldParentFolder.subfolders.remove(at: subfolderIndexToRemove)
                }
                folder.idParentFolder = idParentFolder
            }
             
            addSubFolderToFolderWithID(folder, locationId: locationId)
            
         } else {
            try! realm.write {
                folder.folderName = folderName
            }
        }
    }
    
    func removeFolderWithSubFolders(_ folder: FolderRealm) {
        guard let binFolderId = getBinFolderId() else { return }
        var allSubFolders = [FolderRealm]()
        addSubFoldersToArray(folder, allSubFolders: &allSubFolders)
        allSubFolders.append(folder)
        
        if !folder.isDeleted {
            // update nested indexes when folder location changed
            updateFolderData(folder, folderName: folder.folderName, idParentFolder: binFolderId)
            putFoldersVsBillsToDeletedState(allSubFolders, deleted: true)
        } else {
   
            for folder in allSubFolders {
                 try! realm.write {
                    let objectsToDelete = realm.objects(BillRealm.self).filter("idParentFolder == %@", folder.ID)
                    realm.delete(objectsToDelete)
                }
            }
            
            removeFolders(allSubFolders)
        }
    }
    
    
    func updateSubFoldersIndexes(_ folders: [FolderRealm]) {
        for folder in folders {
            try! realm.write {
                if !folder.subfolders.isEmpty {
                    for subfolder in folder.subfolders {
                        subfolder.nestedIndex = folder.nestedIndex + 1
                    }
                }
            }
        }
    }
    
    func putFoldersVsBillsToDeletedState(_ folders: [FolderRealm], deleted: Bool) {
        for folder in folders {
             try! realm.write {
                 
                 folder.isDeleted = deleted
                 let billsToUpdate = realm.objects(BillRealm.self).filter("idParentFolder == %@", folder.ID).toArray()
                 
                 for bill in billsToUpdate {
                     bill.isDeleted = deleted
                     if deleted == true {
                         bill.readMark = true
                     }
                 }
            }
        }
    }
    
    
    
    func addSubFoldersToArray(_ folder: FolderRealm, allSubFolders: inout [FolderRealm]) {
        let subfolders = folder.subfolders
        if subfolders.count > 0 {
            for subFolder in subfolders {
                allSubFolders.append(subFolder)
                addSubFoldersToArray(subFolder, allSubFolders: &allSubFolders)
            }
        }
    }
    
    

    // MARK: - Inboxes
    
    func getBillsByTypeList(_ typeList: TypeList = .all, withOrder: BillsSort = .dateNewToOld) -> Results<BillRealm> {
        var bills = realm.objects(BillRealm.self).sorted(by: [SortDescriptor(keyPath: "datePinned", ascending: false), withOrder.sortDescriptor])
        switch typeList {
        case .inbox:
            bills = bills.filter("idParentFolder == %@", "").filter(deleted(false))
        case .folder(let folder):
            bills = bills.filter("idParentFolder == %@", folder.ID)
        case .trash:
            bills = bills.filter(deleted(true))
        case .all:
            bills = bills.filter(deleted(false))
        case .unread:
            bills = bills.filter("readMark == false").filter(deleted(false))
        case .flagged:
            bills = bills.filter("flagMark == true").filter(deleted(false))
        case .tagged(let tag):
            bills = bills.filter("ANY tags.ID == %@", tag.ID).filter(deleted(false))
        case .notified:
            bills = bills.filter("notify == true").filter(deleted(false))
        case .new:
            break
        }
        return bills
    }
    
    func searchBillsByTypeList(withOrder: BillsSort = .dateNewToOld, typeFilter: SearchFilter? = nil, typeList: TypeList = .all, isDeleted: Bool = false) -> Results<BillRealm> {
        var bills = realm.objects(BillRealm.self).sorted(by: [SortDescriptor(keyPath: "datePinned", ascending: false), withOrder.sortDescriptor])
        switch typeList {
        case .inbox:
            bills = bills.filter("idParentFolder == %@", "").filter(deleted(false))
        case .folder(let folder):
            bills = bills.filter("idParentFolder == %@", folder.ID).filter(deleted(false))
        case .trash:
            bills = bills.filter(deleted(true))
        case .all:
            bills = bills.filter(deleted(false))
        case .unread:
            bills = bills.filter("readMark == false").filter(deleted(false))
        case .flagged:
            bills = bills.filter("flagMark == true").filter(deleted(false))
        case .tagged(let tag):
            bills = bills.filter("ANY tags.ID == %@", tag.ID).filter(deleted(false))
        case .notified:
            bills = bills.filter("notify == true").filter(deleted(false))
        case .new:
            break
        }
        
        if let typeFilter = typeFilter {
            bills = bills.filter(typeFilter.predicate)
        }
        
        return bills
    }
    
    func saveBills(_ items: [BillRealm]){
        try! realm.write {
            realm.add(items, update: .modified)
        }
    }
    
    func getEmptyBillsResult() -> Results<BillRealm> {
        return realm.objects(BillRealm.self).filter("FALSEPREDICATE")//для очистки списка
    }
    
    func updateFolderIdInBill(_ bill: BillRealm, folderId: String){
        let currentFolder = getFolder(withId: folderId).first
        try! realm.write {
            bill.idParentFolder = folderId
            bill.isDeleted = false
            
            if folderId == getBinFolderId() || currentFolder?.isDeleted == true {
                bill.isDeleted = true
                bill.readMark = true
            } else {
                bill.isDeleted = false
            }
            
        }
    }
    
    func getDeletedBillsResult() -> Results<BillRealm> {
        return realm.objects(BillRealm.self).filter(deleted(true))
    }
    
    func getBillsResultWithStatus(_ status: BillStatus) -> Results<BillRealm> {
        
        switch status {
        case .flagged:
            return realm.objects(BillRealm.self).filter("flagMark == true").sorted(byKeyPath: "datePinned", ascending: false)
        case .unread:
            return realm.objects(BillRealm.self).filter("readMark == false").sorted(byKeyPath: "datePinned", ascending: false)
        }
    }
    
    func removeAllBills() {
        try! realm.write {
            realm.delete(realm.objects(BillRealm.self))
        }
    }
    /*
    func removeBill(withIds: [UUID]) {
        try! realm.write {
            let objectsToDelete = realm.objects(BillRealm.self).filter("NOT ID IN %@", withIds)
            realm.delete(objectsToDelete)
        }
    }*/
    
    func removeBills(_ bills: [BillRealm]) {
        try! realm.write {
            bills.forEach { model in
                if model.isDeleted {
                    realm.delete(model)
                } else {
                    if let binFolderId = getBinFolderId() {
                        model.isDeleted = true
                        model.readMark = true
                        model.idParentFolder = binFolderId
                    }
                }
            }
        }
    }
    
    
    func removeBill(_ bill: BillRealm) {
        try! realm.write {
            if bill.isDeleted {
                realm.delete(bill)
            } else {
                if let binFolderId = getBinFolderId() {
                    bill.isDeleted = true
                    bill.readMark = true
                    bill.idParentFolder = binFolderId
                }
            }
        }
    }
    
    // MARK: - Tags
    
    func removeTag(_ tag: TagsRealm) {
        try! realm.write {
            realm.delete(tag)
        }
    }
    
    func saveTag(_ tag: TagsRealm) {
        try! realm.write {
            realm.add(tag, update: .modified)
        }
    }
    
    func removeAllTags() {
        try! realm.write {
            realm.delete(realm.objects(TagsRealm.self))
        }
    }
    
    func getTagsResult() -> Results<TagsRealm> {
        return realm.objects(TagsRealm.self)
    }
    
    func getTags() -> [TagsRealm] {
        return realm.objects(TagsRealm.self).toArray()
    }
    
    func getDefaultTags() -> [TagsRealm] {
        return realm.objects(TagsRealm.self).filter("isDefault == true").toArray()
    }
    
    func getTags(withId: String) -> [TagsRealm] {
        return  realm.objects(TagsRealm.self).filter("ID == %@", withId).toArray()
    }
    
    func saveTags(_ tags: [TagsRealm]) {
        try! realm.write {
            realm.add(tags, update: .modified)
        }
    }
    
    func removeTag(withIds: [UUID]) {
        try! realm.write {
            let objectsToDelete = realm.objects(BillRealm.self).filter("NOT ID IN %@", withIds)
            realm.delete(objectsToDelete)
        }
    }
    
    func removeItems(item: [BillRealm]) {
        try! realm.write {
            item.forEach{
                if $0.isDeleted {
                    realm.delete($0)
                } else {
                    if let binFolderId = getBinFolderId() {
                        $0.isDeleted = true
                        $0.readMark = true
                        $0.idParentFolder = binFolderId
                    }
                }
            }
        }
    }
    
    func getAllDeleted() -> Results<BillRealm>  {
        return realm.objects(BillRealm.self).filter(deleted(true))
    }
    
    func markReadBill(_ bill: BillRealm){
        realm.beginWrite()
        bill.readMark.toggle()
        try! realm.commitWrite()
    }
    
    func readBill(_ bill: BillRealm){
        realm.beginWrite()
        bill.readMark = true
        try! realm.commitWrite()
    }
    
    func unreadBill(_ bill: BillRealm){
        realm.beginWrite()
        bill.readMark = false
        try! realm.commitWrite()
    }
    
    func pinBill(_ bill: BillRealm){
        realm.beginWrite()
        bill.datePinned = bill.pinnedMark ? nil : Date()
        try! realm.commitWrite()
    }
    
    func flagBill(_ bill: BillRealm){
        realm.beginWrite()
        bill.flagMark.toggle()
        try! realm.commitWrite()
    }
    
    func markReadBill(_ bills: [BillRealm]){
        realm.beginWrite()
        bills.forEach { $0.readMark = true }
        try! realm.commitWrite()
    }
    
    
    func markUnreadBill(_ bills: [BillRealm]){
        realm.beginWrite()
        bills.forEach { $0.readMark = false }
        try! realm.commitWrite()
    }
    
    func markUnreadBill(_ bill: BillRealm){
        realm.beginWrite()
        bill.readMark = false
        try! realm.commitWrite()
    }
    
    func pinBills(_ bills: [BillRealm]){
        realm.beginWrite()
        bills.forEach {
            $0.datePinned = $0.pinnedMark ? nil : Date()
//            $0.datePinned = Date()
        }
        try! realm.commitWrite()
    }
    
    func notifyBills(_ bills: [BillRealm]){
        realm.beginWrite()
        bills.forEach { $0.notify = true }
        try! realm.commitWrite()
    }
    
    func flagBills(_ bills: [BillRealm]){
        realm.beginWrite()
        bills.forEach { $0.flagMark = true }
        try! realm.commitWrite()
    }
}



