//
//  MainFolderRealm.swift
//  AirBill
//
//  Created by Andrey on 09.09.2022.
//

import RealmSwift
import Foundation

class MainFolderRealm: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var index: Int = 0
    @objc dynamic var isSelected: Bool = false
    @objc dynamic var type: String = ""
    
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(index: Int, isSelected: Bool, type: MainFolderType) {
        self.init()
        self.index = index
        self.isSelected = isSelected
        self.type = type.rawValue
    }
    
    convenience init(id: String, index: Int, isSelected: Bool, type: MainFolderType) {
        self.init()
        self.id = id
        self.index = index
        self.isSelected = isSelected
        self.type = type.rawValue
    }
}
