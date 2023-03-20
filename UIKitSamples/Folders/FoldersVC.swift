//
//  FoldersVC.swift
//  AirBill
//
//  Created by Andrey on 05.08.2022.
//

import UIKit
import RealmSwift

protocol FoldersVCDelegate: AnyObject {
    func getNewFolder(name: String, nestedIndex: Int?, locationFolderID: UUID?)
    func updateContent()
}

protocol SubFoldersDelegate {

}

class FoldersVC: ColoredViewController, FoldersVCProtocol {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var bottomToolbarConstraint: NSLayoutConstraint!
    
    private enum Constants {
        static let footerHeight: CGFloat = 10
        static let footerLeftInset: CGFloat = 22
        static let heightCell: CGFloat = 44
    }
    
    var presenter: FoldersPresenterProtocol
    
    // MARK: Life cycle
    
    required init(title: String, presenter: FoldersPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: R.nib.foldersVC.name, bundle: nil)
        self.title = title
        self.presenter.managedView = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        setupNavBar()
        presenter.viewDidLoad()
        setupToolBar()
    }
    
    private func setupToolBar() {
        let items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil), UIBarButtonItem(title: R.string.localizable.foldersNewFolder(preferredLanguages: [Settings.shared.langRawValue]), style: .plain, target: self, action: #selector(openNewFolderVC))]
        toolbar.items = items
        toolbar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        reloadContent()
        selectMainRows()
        view.backgroundColor = R.color.tableviewBackground()
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelection = true
        tableView.register(AddCell.self)
    }
    
    func reloadContent() {
        setupBackground()
        presenter.viewDidLoad()
        tableView.reloadData()
        selectMainRows()
    }
    
    private func setup() {
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.first
                let bottomPadding = window?.safeAreaInsets.bottom
                bottomToolbarConstraint.constant = bottomPadding ?? 0
            }
    }
    
    private func setupNavBar() {
        navigationItem.title = R.string.localizable.foldersFolders()
        navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        presenter.isEditing.toggle()
        presenter.setFoldersSelected()
        
        if editing == true {
            tabBarController?.tabBar.isHidden = true
            toolbar.isHidden = false
            navigationItem.title = R.string.localizable.foldersEdit()
        } else {
            tabBarController?.tabBar.isHidden = false
            toolbar.isHidden = true
            presenter.changeOrder()
            navigationItem.title = R.string.localizable.foldersFolders()
        }
        presenter.viewDidLoad()
        tableView.reloadSections([0, presenter.numberOfSections() - 1], with: .automatic)
        selectMainRows()
        
    }
    
    
    func pushToVC(vc: UIViewController) {
        pushToViewController(vc: vc)
    }
    
    private func presentTo(vc: UIViewController){
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .automatic
            self.present(navigationController, animated: true)
    }
    
    private func editFolderAction(model: FoldersModelProtocol?) {
        guard let id = model?.id else {return}
        if tableView.isEditing == true && id.uuidString != RealmManager.shared.getBinFolderId() {
            let newVC = NewFolderVC(editMode: true, id: id)
            newVC.foldersVCDelegate = self
            self.presentTo(vc: newVC )
        }
    }
    
    func expand(index: Int, section: Int) {
        tableView.reloadRows(at: [IndexPath(item: index, section: section)], with: .automatic)
        tableView.reloadRows(at: [IndexPath(item: index - 1, section: section)], with: .automatic)
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func selectMainRows() {
        if tableView.isEditing {
            let rowsCount = tableView.numberOfRows(inSection: 0)
            
            for i in 0..<rowsCount  {
                let indexPath = IndexPath(row: i, section: 0)
                if let model = presenter.model(at: indexPath) as? FoldersCellModel, let id = model.id {
                    if model.mainFoldersSelected {
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        presenter.addToSelectedFolders(withId: id)
                    }
                }
            }
            if presenter.selectedFolders.count == 1 {
                if let index = presenter.indexOfLastFolder() {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                        cell.tintColor = R.color.greyColor()
                        cell.isUserInteractionEnabled = false
                    }
                }
            }
        }
        
    }
    
    @objc func openTags() {
        let tagsVC = TagsVC(presenter: TagsPresenter())
        let navigationController = UINavigationController(rootViewController: tagsVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    @objc func openNewFolderVC() {
        let newVC = NewFolderVC()
        newVC.foldersVCDelegate = self
        self.presentTo(vc: newVC )
    }
    
}


extension FoldersVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if tableView.isEditing {
                return  presenter.numberOfItems(section: section) + 1
            }
        }
        return presenter.numberOfItems(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == presenter.numberOfItems(section: indexPath.section) {
                let cell = tableView.dequeueCell(AddCell.self, for: indexPath)
                if let cell = cell as? AddCell {
                    cell.addBtn.addTarget(self, action: #selector(openTags), for: .touchUpInside)
                }
                return cell
            }
        }
        
        guard let model = presenter.model(at: indexPath) as? FoldersCellModel
        else { return UITableViewCell() }
        let cell = FoldersMainCell(style: .subtitle, reuseIdentifier: FoldersMainCell.reuseKey)
        cell.model = model
        cell.contentOffset()
        
        if tableView.isEditing {
            cell.selectionStyle = (model.editable || model.disabled) ? .none : .default
            tableView.isUserInteractionEnabled = true
            let bgColorView = UIView()
            bgColorView.backgroundColor = .clear
            cell.selectedBackgroundView = bgColorView
            cell.tintColor = R.color.darkGreen()
            
            if presenter.selectedFolders.count == 1 {
                if let index = presenter.indexOfLastFolder() {
                    if index == indexPath.row {
                        cell.tintColor = R.color.greyColor()
                    }
                }
            }
        } else {
            cell.selectionStyle = .none
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let text = presenter.footerText(at: section)
        else { return nil }
        
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: Constants.footerHeight))
        let footerLabel = UILabel(frame: CGRect(x: Constants.footerLeftInset, y: 0, width: tableView.frame.size.width, height: Constants.footerHeight))
        footerLabel.text = text
        footerLabel.font = R.font.sfProTextRegular(size: 12)
        footerLabel.textColor = R.color.arrowAccessory()
        viewFooter.addSubview(footerLabel)
        return viewFooter
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let _ = presenter.footerText(at: section)
        else { return 0.1 }
        return Constants.footerHeight
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == presenter.numberOfSections() - 1 {
            guard let model = presenter.model(at: indexPath) as? FoldersCellModel else { return 0 }
            if model.selected {
                return Constants.heightCell
            }
            return 0
        }
        return Constants.heightCell
    }
    
}
extension FoldersVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if presenter.selectedFolders.count == 1 {
            if let index = presenter.indexOfLastFolder() {
                if let cell = tableView.cellForRow(at: IndexPath(row: index, section: indexPath.section)) {
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = .clear
                    cell.backgroundView = bgColorView
                    cell.tintColor = R.color.darkGreen()
                    cell.isUserInteractionEnabled = true
                }
            }
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = presenter.model(at: indexPath) as? FoldersCellModel else { return }

        if tableView.isEditing {
            if model.editable {
                editFolderAction(model: model)
            } else if indexPath.section == 0 {
                    presenter.addToSelectedFolders(with: indexPath.row)
            } else if !model.disabled {
                model.action()
            }
        } else {
            model.action()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if presenter.selectedFolders.count > 1 {
                presenter.removeSelectedFolders(with: indexPath.row)
                
                if presenter.selectedFolders.count == 1 {
                    if let index = presenter.indexOfLastFolder() {
                        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: indexPath.section)) {
                            let bgColorView = UIView()
                            bgColorView.backgroundColor = .clear
                            cell.backgroundView = bgColorView
                            cell.tintColor = R.color.greyColor()
                            cell.isUserInteractionEnabled = false
                        }
                        tableView.selectRow(at: IndexPath(row: index, section: indexPath.section), animated: true, scrollPosition: .none)
                    }
                }
            }
        } else {
            guard let model = presenter.model(at: indexPath) as? FoldersCellModel else { return }
            editFolderAction(model: model)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            if indexPath.row == presenter.numberOfItems(section: indexPath.section) {
                return false
            }
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        presenter.moveCell(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        let numberOfItems = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
        
        if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
            let rowInSourceSection = (sourceIndexPath.section > proposedDestinationIndexPath.section) ? 0 : numberOfItems - 1;
            
            return IndexPath(row: rowInSourceSection, section: sourceIndexPath.section)
        }
        else if (proposedDestinationIndexPath.row >= numberOfItems) {
            
            return IndexPath(row: numberOfItems - 1, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
}

extension FoldersVC: FoldersVCDelegate {
    func updateContent() {
        reloadContent()
    }
    
    func getNewFolder(name: String, nestedIndex: Int?, locationFolderID: UUID?) {
        if let locationFolderID = locationFolderID, var nestedIndex = nestedIndex {
            nestedIndex += 1
            presenter.addNewFolder(FolderRealm(folderName: name, nestedIndex: nestedIndex), locationFolderID: locationFolderID)
        } else {
            presenter.addNewFolder(FolderRealm(folderName: name, nestedIndex: 0))
        }
        reloadContent()
    }
}


extension SubFoldersDelegate {
    func appendSubFolders(_ folder: FolderRealm, allFolders: inout [FolderRealm], editFolderID: String?) {
            let subfolders = folder.subfolders
            if subfolders.count > 0 {
                for subFolder in subfolders {
                    if subFolder.ID == editFolderID {
                        return
                    }
                    allFolders.append(subFolder)
                    appendSubFolders(subFolder, allFolders: &allFolders, editFolderID: editFolderID)
                }
            }
        }
}
