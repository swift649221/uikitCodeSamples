//
//  Dictionary+Extensions.swift
//  AirBill
//
//  Created by Andrey on 17.08.2022.
//

import Foundation

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
