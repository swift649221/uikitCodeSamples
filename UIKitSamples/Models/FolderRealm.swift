//
//  FolderRealm.swift
//  AirBill
//
//  Created by Andrey on 07.07.2022.
//

import RealmSwift
import Foundation

class FolderRealm: Object {
    @objc dynamic var ID = UUID().uuidString
    @objc dynamic var folderName: String = ""
    @objc dynamic var nestedIndex: Int = 0 {
        didSet {
            if self.subfolders.count > 0 {
                for subfolder in self.subfolders {
                    subfolder.nestedIndex = self.nestedIndex + 1
                }
            }
        }
    }
    @objc dynamic var idParentFolder: String = ""
    @objc dynamic var isBin: Bool = false
    @objc dynamic var isDeleted: Bool = false
    
    var subfolders = List<FolderRealm>()
    var bills = List<BillRealm>()
    
    var folder = LinkingObjects(fromType: FolderRealm.self, property: "subfolders")
    
    override class func primaryKey() -> String? {
        return "ID"
    }
    
    convenience init(folderName: String, items: [BillRealm], subfolders: [FolderRealm], nestedIndex: Int, idParentFolder: String) {
        self.init()
        self.folderName = folderName
        self.bills.append(objectsIn: items)
        self.subfolders.append(objectsIn: subfolders)
        self.nestedIndex = nestedIndex
        self.idParentFolder = idParentFolder
    }
    
    
    convenience init(folderName: String, nestedIndex: Int, isBin: Bool = false) {
        self.init()
        self.folderName = folderName
        self.nestedIndex = nestedIndex
        self.isBin = isBin
    }
}


