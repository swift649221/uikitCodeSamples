//
//  SearchToken.swift
//  AirBill
//
//  Created by Andrey on 09.08.2022.
//

import Foundation
import UIKit

enum SearchTypeToken {
    case tagged(String)
    case unread
    case notified
    case flagged
}

struct SearchToken {
    let type: SearchTypeToken
    let name: String
    let icon: UIImage
    let tint: UIColor
}
