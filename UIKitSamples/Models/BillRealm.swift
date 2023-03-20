//
//  MailRealm.swift
//  AirBill
//
//  Created by Andrey on 07.07.2022.
//


import RealmSwift
import Foundation
import UIKit
import Kingfisher

enum FlagColor: String {
    case orange = "#FF9500"
    case red = "#FF3B30"
    case yellow = "#FFCC00"
    case purple = "#AF52DE"
    case blue = "#5856D6"
    case green = "#16A085"
    case gray = "#8E8E93"
    
    func color() -> UIColor {
        return UIColor(hexString: rawValue )
    }
}

class BillRealm: Object {
    
    @objc dynamic var ID = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var readMark: Bool = false
    @objc dynamic var notify: Bool = false
    @objc dynamic var flagMark: Bool = false
    //@objc dynamic var inboxMark: Bool = true
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var datePinned: Date?
    @objc dynamic var price: Double = 0
    @objc dynamic var thumbnailImageData: Data = Data()
    @objc dynamic var imageData: Data = Data()
    @objc dynamic var currency: String = AppCurrency.USD.contentValues.1
    @objc dynamic var hexColor: String = FlagColor.orange.rawValue
    @objc dynamic var comment: String = ""
    @objc dynamic var idParentFolder: String = ""
    @objc dynamic var isDeleted: Bool = false
    
    override class func primaryKey() -> String? {
        return "ID"
    }
    
    var pinnedMark: Bool{
        get {
            return datePinned != nil
        }
    }
    
    var inboxMark: Bool{
        get {
            return idParentFolder.isEmpty && tags.isEmpty
        }
    }
    
    var info: String {
        get {
            var infoText = dateCreated.toDateStr()
            if price != 0 {
                infoText += " - \(currency) \(price)"
            }
            return infoText
        }
    }
    
    
    var tags = List<TagsRealm>()
    
    //var folder = LinkingObjects(fromType: FolderRealm.self, property: "bills")
    /*
    func imagePreview(complation: @escaping (UIImage) -> Void) {
        let prov = RawImageDataProvider(data: imageData, cacheKey: ID)
        KF.dataProvider(prov)
            .onSuccess { result in
                ImageCache.default.store(result.image, forKey: self.ID)
                complation(result.image)
            }
            .onFailure { _ in
                complation(UIImage())
            }
    }*/
    
    var imagePreview: UIImage {
        return (UIImage(data: thumbnailImageData, scale: 1.0) ?? UIImage())
    }
    
    var imageOriginal: UIImage {
        return UIImage(data: imageData, scale: 1.0) ?? UIImage()
    }
    
    convenience init(ID: UUID, idParentFolder: UUID?, readMark: Bool, flagMark: Bool, notify: Bool, dateCreated: Date, name: String, price: Double, tags: [TagsRealm], image: UIImage, hexColor: FlagColor, currency: AppCurrency = AppCurrency.USD, datePinned: Date? = nil, comment: String, isDeleted: Bool = false) {
        self.init()
        self.ID = ID.uuidString
        if let idParentFolder = idParentFolder {
            self.idParentFolder = idParentFolder.uuidString
        }
        self.readMark = readMark
        self.flagMark = flagMark
        self.notify = notify
        self.dateCreated = dateCreated
        self.name = name
        self.price = price
        self.datePinned = datePinned
        self.hexColor = hexColor.rawValue
         
        //let fixedImage = image.rotateFixImage()
        
        //let data1 = fixedImage.createThumbnail().jpeg(.medium) ?? Data()
        //let data2 = fixedImage.jpeg(.medium) ?? Data()
    
        if #available(iOS 15.0, *) {
            self.thumbnailImageData = (image.preparingThumbnail(of: CGSize(width: 200, height: 200)) ?? UIImage()).jpeg(.medium) ?? Data()
        } else {
            self.thumbnailImageData = image.createThumbnail().jpeg(.medium) ?? Data()
        }
       
        self.imageData = image.jpeg(.medium) ?? Data()
    
        self.currency = currency.contentValues.1
        self.comment = comment
        self.tags.append(objectsIn: tags)
        self.isDeleted = isDeleted
    }
    
    func getFlagType(fromHex: FlagColor.RawValue) -> FlagColor {
        return FlagColor(rawValue: fromHex) ?? .orange
    }
    
}

