//
//  FoldersPresenter.swift
//  AirBill
//
//  Created by Andrey on 09.08.2022.
//

import UIKit
import RealmSwift

protocol FoldersModelProtocol {
    var nestedIndex: Int? { get set }
    var id: UUID? { get set }
    var opened: Bool { get set }
    var parentId: String { get set }
    var selected: Bool { get set }
}

struct FoldersColorCellModel: FoldersModelProtocol {
    var parentId: String = ""
    var opened: Bool = false
    var id: UUID? = nil
    var nestedIndex: Int? = 0
    var selected: Bool
    let action: () -> Void
    let title: String
    let color: UIColor
}

struct FoldersCellModel: FoldersModelProtocol {
    var type: TypeList?
    var mainFolderType: MainFolderType?
    var id: UUID? = nil
    var nestedIndex: Int? = 0
    let icon: UIImage?
    let title: String
    var subtitle: String = ""
    var action: () -> Void
    let typeAccessory: TypeAccessory
    var cellTextLabelColor: CellTextLabelColor = .black
    var selected = true
    var opened: Bool = false
    var countSublolsers = 0
    var parentId: String = ""
    var actionExpand: () -> Void
    var disabled: Bool = false
    var editable: Bool = false
    var mainFoldersSelected: Bool = false
}

struct FoldersSectionModel {
    var cells: [FoldersModelProtocol]
    var identify: String = ""
    var footer: String? = ""
}

protocol FoldersVCProtocol: ViewController {
    var presenter: FoldersPresenterProtocol { get set }
    func pushToVC(vc: UIViewController)
    func expand(index: Int, section: Int)
    func reloadTableView()
}

protocol FoldersPresenterProtocol: AnyObject {
    var managedView: FoldersVCProtocol? { get set }
    var isEditing: Bool { get set }
    var selectedFolders: [MainFolderRealm] { get set }
    func viewDidLoad()
    func numberOfSections() -> Int
    func numberOfItems(section: Int) -> Int
    func model(at indexPath: IndexPath) -> FoldersModelProtocol?
    func footerText(at index: Int) -> String?
    func addNewFolder(_ folder: FolderRealm, locationFolderID: UUID?)
    func openBills(withId: String)
    func openBills(withType: TypeList)
    func addToSelectedFolders(withId: UUID)
    func addToSelectedFolders(with index: Int)
    func removeSelectedFolders(with index: Int)
    func setFoldersSelected()
    func moveCell(from sourceIndex: Int, to destinationIndex: Int)
    func changeOrder()
    func indexOfLastFolder() -> Int?
}

class FoldersPresenter: FoldersPresenterProtocol {
    private var defaultTags = [TagsRealm(name: R.string.localizable.tagsWarranty(preferredLanguages: [Settings.shared.langRawValue]), index: 0, isDefault: true),TagsRealm(name: R.string.localizable.tagsBringBack(preferredLanguages: [Settings.shared.langRawValue]), index: 1, isDefault: true), TagsRealm(name: R.string.localizable.tagsCheck(preferredLanguages: [Settings.shared.langRawValue]), index: 2, isDefault: true)]
    
    private var sections: [FoldersSectionModel] = []
    weak var managedView: FoldersVCProtocol?
    var isEditing: Bool = false
    var selectedFolders = [MainFolderRealm]()
    
    init() {
        
        if RealmManager.shared.getDefaultTags().isEmpty {
            RealmManager.shared.saveTags(defaultTags)
        }
        
        let mainFolders = RealmManager.shared.getMainFolders()
        let tags = RealmManager.shared.getDefaultTags()
        
        // MARK: Uncomment for latest version
        /*
        for i in 0..<4 {
            if !mainFolders.contains(where: { $0.index == i }) {
                if i == 3 {
                    RealmManager.shared.saveMainFolder(MainFolderRealm(index: i, isSelected: false, type: MainFolderType.getType(i)))
                } else {
                    RealmManager.shared.saveMainFolder(MainFolderRealm(index: i, isSelected: true, type: MainFolderType.getType(i)))
                }
            }
        }
        */
        
        for i in 0..<3 {
            if !mainFolders.contains(where: { $0.index == i }) {
                    RealmManager.shared.saveMainFolder(MainFolderRealm(index: i, isSelected: true, type: MainFolderType.getType(i)))
            }
        }
        
        tags.forEach { tag in
            if !mainFolders.contains(where: { $0.id == tag.ID }) {
                RealmManager.shared.saveMainFolder(MainFolderRealm(id: tag.ID, index: tag.index + 4, isSelected: false, type: .tag))
            }
        }
    }
    
    func viewDidLoad() {
        
        sections = FoldersModelFactory( view: managedView, presenter: self).makeMainFolders(isEditing: isEditing)
//        if let managedView = managedView {
//            managedView.reloadTableView()
//        }
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(section: Int) -> Int {
        if let section = sections[safe: section] {
            return section.cells.count
        }
        return 0
    }
    
    func footerText(at index: Int) -> String? {
        if let section = sections[safe: index] {
            return section.footer
        }
        return nil
    }
    
    func model(at indexPath: IndexPath) -> FoldersModelProtocol? {
        if let section = sections[safe: indexPath.section], let item = section.cells[safe: indexPath.item] {
            return item
        }
        return nil
    }
    
    func changeOrder() {
        let mainfolders = RealmManager.shared.getMainFolders()
        RealmManager.shared.realm.beginWrite()
        for i in sections[0].cells.indices {
            if let index = mainfolders.firstIndex(where: { $0.id == sections[0].cells[i].id?.uuidString }) {
               mainfolders[index].index = i
            }
        }
       try! RealmManager.shared.realm.commitWrite()
    }
    
    func moveCell(from sourceIndex: Int, to destinationIndex: Int) {
        let itemToMove = sections[0].cells[sourceIndex]
        sections[0].cells.remove(at: sourceIndex)
        sections[0].cells.insert(itemToMove, at: destinationIndex)
    }
    
    
    func addToSelectedFolders(withId: UUID) {
        if let folder = RealmManager.shared.getMainFolder(withId: withId.uuidString).first {
            if !selectedFolders.contains(folder) {
                selectedFolders.append(folder)
            }
        }
    }
    
    func addToSelectedFolders(with index: Int) {
        guard let selectedFolderId = sections.first?.cells[index].id?.uuidString else { return }
        if !selectedFolders.contains(where: { $0.id == selectedFolderId }) {
            guard let folder = RealmManager.shared.getMainFolder(withId: selectedFolderId).first else { return }
            selectedFolders.append(folder)
        }
    }
    
    func indexOfLastFolder() -> Int? {
        let mainfolders = RealmManager.shared.getMainFolders()
        guard let folder = selectedFolders.first else { return nil }
        let index = mainfolders.firstIndex(of: folder)
        return index
    }
    
    func removeSelectedFolders(with index: Int) {
        guard let selectedFolderId = sections.first?.cells[index].id?.uuidString else { return }
        if selectedFolders.contains(where: { $0.id == selectedFolderId }) {
            guard let folder = RealmManager.shared.getMainFolder(withId: selectedFolderId).first else { return }
            RealmManager.shared.setMainFolderDeselected(folder: folder)
            if let indexFolder = selectedFolders.firstIndex(of: folder) {
                selectedFolders.remove(at: indexFolder)
            }
        }
    }
    
    func setFoldersSelected() {
        RealmManager.shared.setMainFoldersSelected(folders: selectedFolders)
    }
    
    func openBills(withId: String) {
        guard let folder = RealmManager.shared.getFolder(withId: withId).first else { return }
        let vc = MainInboxScreenVC(presenter: MainInboxPresenter(type: .folder(folder), screenType: .folders))
        managedView?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openBills(withType: TypeList) {
        let vc = MainInboxScreenVC(presenter: MainInboxPresenter(type: withType, screenType: .folders))
        managedView?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func expandFolders(index: Int) {
        let tapped = sections[sections.count - 1].cells[index]
        sections[sections.count - 1].cells[index].opened.toggle()
        if let id = tapped.id {
            toogleAllChilds(id: id.uuidString, close: sections[sections.count - 1].cells[index].opened)
        }
        
    }
    
    private func toogleAllChilds(id: String, close: Bool){
        for (i , item) in sections[sections.count - 1].cells.enumerated() {
            if item.parentId == id {
                sections[sections.count - 1].cells[i].selected = close
                if let managedView = managedView {
                    managedView.expand(index: i, section: sections.count - 1)
                }
                if !sections[sections.count - 1].cells[i].selected {
                    sections[sections.count - 1].cells[i].opened = false
                    if let id = sections[sections.count - 1].cells[i].id {
                        toogleAllChilds(id: id.uuidString, close: sections[sections.count - 1].cells[i].selected)
                    }
                }
            }
        }
    }
    
}

extension FoldersPresenterProtocol {
    func addNewFolder(_ folder: FolderRealm, locationFolderID: UUID? = nil) {
        if let locationFolderID = locationFolderID {
            RealmManager.shared.addSubFolderToFolderWithID(folder, locationId: locationFolderID)
        } else {
            var folders: [FolderRealm] = []
            folders.append(folder)
            RealmManager.shared.saveFolders(folders)
        }
        
        
    }
}
