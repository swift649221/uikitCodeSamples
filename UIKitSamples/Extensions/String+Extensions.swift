//
//  String+Extensions.swift
//  Xpresent
//
//  Created by Andrey on 28.01.2021.
//

import Foundation

extension String {

    func replaceWithStrings(string: String, with: String) -> String {
        var textResult = self
        textResult = textResult.replacingOccurrences(of: string, with: with)
        return textResult
    }

    func toDouble() -> Double {
        let price = self.filter("0123456789.,".contains).trimmingCharacters(in: CharacterSet.punctuationCharacters)

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 3
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.maximumIntegerDigits = 3
        numberFormatter.allowsFloats = true
        numberFormatter.alwaysShowsDecimalSeparator = true
        
        return (numberFormatter.number(from: price) ?? NSNumber(value: 0)).doubleValue
    }
    
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return Date()
    }
    
}
