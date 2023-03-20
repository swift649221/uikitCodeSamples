//
//  Realm+.swift
//  AirBill
//
//  Created by Andrey on 07.07.2022.
//

import Foundation
import RealmSwift

extension Results {
    func toArray() -> [Element] {
        return Array(self)
    }
}
