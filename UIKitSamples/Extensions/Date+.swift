//
//  Date+Extensions.swift
//  Xpresent
//
//  Created by Andrey on 27.05.2021.
//

import UIKit

extension Date {
    func toDateStr(dateFormat: String = "dd.MM.yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
