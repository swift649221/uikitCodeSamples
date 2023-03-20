//
//  UITextField+.swift
//  AirBill
//
//  Created by Andrey on 17.08.2022.
//

import UIKit

extension UITextField {

    func maskPrice(string: String) -> Bool {
        let charCurrency = Settings.shared.currentCurrency.contentValues.1
        let decimalRange = self.text!.rangeOfCharacter(from: CharacterSet.decimalDigits)
        let punctuationTeRange = self.text!.rangeOfCharacter(from: CharacterSet.punctuationCharacters)
        let punctuationIncomingRange = string.rangeOfCharacter(from: CharacterSet.punctuationCharacters)
        
        if string.rangeOfCharacter(from: CharacterSet.letters) != nil {
            return false
        }
        if (punctuationTeRange != nil && punctuationIncomingRange != nil) || (punctuationIncomingRange != nil && self.text!.isEmpty) {//проверка на запятые
           return false
        } else if !string.isEmpty && decimalRange == nil {//проверка для маски валют
            self.text = charCurrency + " " + string
            return false
        }else if self.text!.contains(charCurrency) && decimalRange != nil {//ввод разрешен
            return true
        }else{
            self.text = ""
            return false
        }
    }
}
