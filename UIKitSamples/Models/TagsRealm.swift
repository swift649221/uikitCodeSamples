//
//  TagsRealm.swift
//  AirBill
//
//  Created by Andrey on 08.07.2022.
//

import RealmSwift

class TagsRealm: Object {
    @objc dynamic var ID = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var index: Int = 0
    @objc dynamic var isDefault: Bool = false
    
    override class func primaryKey() -> String? {
        return "ID"
    }
    
    var bill = LinkingObjects(fromType: BillRealm.self, property: "tags")
    
    convenience init(name: String, index: Int) {
        self.init()
        self.name = name
        self.index = index
    }
    
    convenience init(name: String, index: Int, isDefault: Bool) {
        self.init()
        self.name = name
        self.index = index
        self.isDefault = isDefault
    }
}
