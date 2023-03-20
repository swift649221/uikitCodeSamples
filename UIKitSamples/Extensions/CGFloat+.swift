//
//  CGFloat+.swift
//  AirBill
//
//  Created by Andrey on 01.08.2022.
//

import CoreGraphics

infix operator ~<
infix operator ~==
infix operator ~>

extension CGFloat {

    static func ~< (lhs: CGFloat, rhs: CGFloat) -> Bool {
        (lhs < rhs) || (lhs ~== rhs)
    }

    static func ~> (lhs: CGFloat, rhs: CGFloat) -> Bool {
        (lhs > rhs) || (lhs ~== rhs)
    }

    static func ~== (lhs: CGFloat, rhs: CGFloat) -> Bool {
        abs(lhs - rhs) < 0.000001
    }
}
