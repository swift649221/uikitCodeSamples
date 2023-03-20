//
//  FoldersLocationPresenter.swift
//  AirBill
//
//  Created by Andrey on 22.08.2022.
//

import UIKit

protocol FolderLocationVCProtocol: ViewController {
    var presenter: FoldersLocationPresenterProtocol { get set }
}

protocol FoldersLocationPresenterProtocol: AnyObject {
    var managedView: FolderLocationVCProtocol? { get set }
    var editFolderID: String? { get set}
    func viewDidLoad()
    func numberOfSections() -> Int
    func numberOfItems(section: Int) -> Int
    func model(at indexPath: IndexPath) -> FoldersModelProtocol?
}

class FoldersLocationPresenter: FoldersLocationPresenterProtocol {
    private var sections: [FoldersSectionModel] = []
    weak var managedView: FolderLocationVCProtocol?
    var editFolderID: String? = nil
    
    func viewDidLoad() {
        sections = FoldersLocationModelFactory( view: managedView, editFolderID: editFolderID).makeLocationFolders()
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
    
}



