//
//  FolderLocationVC.swift
//  AirBill
//
//  Created by Andrey on 21.08.2022.
//

import UIKit

class FolderLocationVC: ColoredViewController, FolderLocationVCProtocol {

    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: FoldersLocationPresenterProtocol
    weak var delegate: LocationFolderDelegate?
    var updateLocationButton: ((String?)->Void)?
    var selectedId: UUID? = nil
    
    // MARK: Life cycle
    
    required init(title: String, presenter: FoldersLocationPresenterProtocol, editFolderID: String?) {
        self.presenter = presenter
        super.init(nibName: R.nib.folderLocationVC.name, bundle: nil)
        self.title = title
        self.presenter.editFolderID = editFolderID
        self.presenter.managedView = self
        navigationItem.largeTitleDisplayMode = .never
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        setup()
        presenter.viewDidLoad()
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.tableHeaderView = UIView()
        tableView.separatorStyle = .singleLine
    }
    
    private func setup() {
        navigationItem.title = R.string.localizable.foldersChooseFolder()
    }
}

extension FolderLocationVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfItems(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = presenter.model(at: indexPath) as? FoldersCellModel
        else { return UITableViewCell() }
        let cell = FolderLocationCell(style: .subtitle, reuseIdentifier: FolderLocationCell.reuseKey)
        cell.model = model
        cell.layoutMargins = UIEdgeInsets(top: 0, left: (CGFloat(model.nestedIndex ?? 0)+1) * FoldersMainCell.Constant.inset, bottom: 0, right: 0)
        
        if let selectedId = selectedId {
            if selectedId == model.id {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
     
}

extension FolderLocationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = presenter.model(at: indexPath) as? FoldersCellModel else { return }
        self.selectedId = model.id
        model.action()
        
        guard let delegate = delegate else { return }
        delegate.getLocationFolderData(id: model.id, nestedIndex: model.nestedIndex)
        self.updateLocationButton?("   " + model.title)
        navigationController?.popViewController(animated: true)
    }
}
