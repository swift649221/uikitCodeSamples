//
//  Collection+.swift
//  AirBill
//
//  Created by Andrey on 11.07.2022.
//

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

