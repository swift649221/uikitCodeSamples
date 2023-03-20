//
//  MainFolderType.swift
//  AirBill
//
//  Created by Andrey on 13.09.2022.
//

import RealmSwift

enum MainFolderType: String {
    case all
    case unread
    case flagged
    case tag
    
    // MARK: Uncomment for latest version
    /*
    case notified
    */
    func title(mainFolder: MainFolderRealm) -> String {
        switch self {
        case .all:
            return R.string.localizable.foldersAllBills(preferredLanguages: [Settings.shared.langRawValue])
        case .unread:
            return R.string.localizable.searchUnread(preferredLanguages: [Settings.shared.langRawValue])
        case .flagged:
            return R.string.localizable.searchFlagged(preferredLanguages: [Settings.shared.langRawValue])
        case .tag:
            guard let tag = RealmManager.shared.getTags(withId: mainFolder.id).first else { return "" }
            return tag.name
            // MARK: Uncomment for latest version
            /*
        case .notified:
            return R.string.localizable.searchNotified(preferredLanguages: [Settings.shared.langRawValue])
             */
        }
    }
    
    var image: UIImage {
        get {
            switch self {
            case .all:
                return R.image.allbills()!
            case .unread:
                return R.image.unread()!
            case .flagged:
                return R.image.flagged()!
                // MARK: Uncomment for latest version
                /*
            case .notified:
                return R.image.notifiedFolders()!
                 */
            case .tag:
                return R.image.tagFolders()!
            }
        }
    }
    
    static func getType(_ index: Int) -> MainFolderType {
        if index == 0 {
            return .all
        } else if index == 1 {
            return .unread
        } else {
            return .flagged
        }
        // MARK: Uncomment for latest version
        /*
        else  {
            return .notified
        }
         */
    }
    
    static func getBillsType(_ type: MainFolderType, mainFolder: MainFolderRealm) -> TypeList {
        switch type {
        case .all:
            return .all
        case .unread:
            return .unread
        case .flagged:
            return . flagged
            // MARK: Uncomment for latest version
            /*
        case .notified:
            return .notified
             */
        case .tag:
            guard let tag = RealmManager.shared.getTags(withId: mainFolder.id).first else { return .all }
            return .tagged(tag)
        }
    }
    
}
