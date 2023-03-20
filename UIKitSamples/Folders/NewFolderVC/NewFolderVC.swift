//
//  NewFolderVC.swift
//  AirBill
//
//  Created by Andrey on 12.08.2022.
//

import UIKit
import RealmSwift

enum Constant {
    static let maxFolderNameLength: Int = 32
    static let maxNestedIndex: Int = 5
}

protocol LocationFolderDelegate: AnyObject {
    func getLocationFolderData(id: UUID?, nestedIndex: Int?)
}

class NewFolderVC: ColoredViewController, LocationFolderDelegate {

    @IBOutlet weak var folderLocationLabel: UILabel!
    @IBOutlet weak var folderTextField: UITextField!
    @IBOutlet weak var folderLocationButton: UIButton!
    @IBOutlet weak var folderDeleteButton: UIButton!
    
    weak var foldersVCDelegate: FoldersVCDelegate?
    private var editMode: Bool = false
    
    private var editFolderID: UUID? = nil
    private var locationFolderID: UUID? = nil
    private var nestedIndex: Int? = 0
    private let allFolders: Results<FolderRealm> = RealmManager.shared.getFolders()
    
    init() {
        super.init(nibName: R.nib.newFolderVC.name, bundle: nil)
    }
    
    init(editMode: Bool, id: UUID) {
        self.editMode = editMode
        self.editFolderID = id
        super.init(nibName: R.nib.newFolderVC.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupLabel()
        setupLocationButton()
        setupDeleteButton()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showHideLocation()
        view.backgroundColor = R.color.tableviewBackground()
        if self.editMode == true, let id = editFolderID {
           guard let editFolder = RealmManager.shared.getFolder(withId: id.uuidString).first else { return }
            navigationItem.rightBarButtonItem?.isEnabled = true
            folderDeleteButton.isHidden = false
            folderTextField.text = editFolder.folderName
            let parentFolder = RealmManager.shared.getRootFolder(child: editFolder)
            
            guard let parentFolderName = parentFolder.first?.folderName, let parentLocationId = parentFolder.first?.ID, locationFolderID == nil  else { return }
            folderLocationButton.setTitle(parentFolderName, for: .normal)
            folderLocationButton.setImage(R.image.defaultFolder(), for: .normal)
            folderLocationButton.setTitleColor(R.color.blackWhiteTheme(), for: .normal)
            locationFolderID = UUID(uuidString: parentLocationId)
        } else {
            folderDeleteButton.isHidden = true
        }
    }

    private func setupTextField() {
        folderTextField.clearButtonMode = .whileEditing
        folderTextField.layer.cornerRadius = 14
        folderTextField.clipsToBounds = true
        folderTextField.borderStyle = .none
        folderTextField.placeholder = R.string.localizable.foldersPlaceholder(preferredLanguages: [Settings.shared.langRawValue])
        folderTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: folderTextField.frame.height))
        folderTextField.leftViewMode = .always
        folderTextField.backgroundColor = R.color.newTagBackground()
        
        folderTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    private func setupLabel() {
        folderLocationLabel.textColor = R.color.greyColor()
        
        folderLocationLabel.text = R.string.localizable.foldersLocation(preferredLanguages: [Settings.shared.langRawValue])
    }
    
    private func setupLocationButton() {
        folderLocationButton.backgroundColor = R.color.newTagBackground()
        folderLocationButton.addTarget(self, action: #selector(locationTapped(_:)), for: .touchUpInside)
        
    }
    
    
    private func setupDeleteButton() {
        folderDeleteButton.backgroundColor = R.color.newTagBackground()
        folderDeleteButton.setTitleColor(R.color.redColor(), for: .normal)
        folderDeleteButton.layer.cornerRadius = 14
        folderDeleteButton.backgroundColor = R.color.newTagBackground()
        folderDeleteButton.addTarget(self, action: #selector(folderDeleteTapped(_:)), for: .touchUpInside)
    }
    
    
    private func showHideLocation() {
        if allFolders.count > 0 {
            folderLocationLabel.isHidden = false
            folderLocationButton.isHidden = false
        } else {
            folderLocationButton.isHidden = true
            folderLocationLabel.isHidden = true
        }
    }
    
    
    private func setupNavBar() {
        navigationItem.title = (editMode == true) ?  R.string.localizable.foldersEditFolder(preferredLanguages: [Settings.shared.langRawValue]) : R.string.localizable.foldersNewFolder(preferredLanguages: [Settings.shared.langRawValue])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: R.string.localizable.foldersCancel(preferredLanguages: [Settings.shared.langRawValue]), style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.foldersSave(preferredLanguages : [Settings.shared.langRawValue]), style: .done, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = folderTextField.text {
            navigationItem.rightBarButtonItem?.isEnabled = text.isEmpty ? false : true
        }
    }
    
    @objc func locationTapped(_ sender: UITapGestureRecognizer) {
        let folderLocationVC = FolderLocationVC(title: "", presenter: FoldersLocationPresenter(), editFolderID: editFolderID?.uuidString)
        folderLocationVC.delegate = self
        folderLocationVC.updateLocationButton = { [weak self] folderName in
            guard let self = self else { return }
            self.folderLocationButton.setTitleColor(R.color.blackWhiteTheme(), for: .normal)
            self.folderLocationButton.setTitle(folderName, for: .normal)
            self.folderLocationButton.setImage(R.image.defaultFolder(), for: .normal)
        }
        
        folderLocationVC.selectedId = locationFolderID
        navigationController?.pushViewController(folderLocationVC, animated: true)
    }
    
    @objc func folderDeleteTapped(_ sender: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: "", message: R.string.localizable.foldersActionSheetMessage(preferredLanguages: [Settings.shared.langRawValue]), preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: R.string.localizable.foldersDelete(preferredLanguages: [Settings.shared.langRawValue]), style: .destructive, handler: { _ in
            
            if let id = self.editFolderID?.uuidString, let editFolder = RealmManager.shared.getFolder(withId: id).first {
                RealmManager.shared.removeFolderWithSubFolders(editFolder)
                self.foldersVCDelegate?.updateContent()
            }
            
            self.dismiss(animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: R.string.localizable.foldersCancel(preferredLanguages: [Settings.shared.langRawValue]), style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func saveTapped() {
        guard let folderName = folderTextField.text, folderName.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
            return
        }
        
        guard validateFolderLevel(nestedIndex) else {
            showAlert(title: R.string.localizable.foldersWarning(preferredLanguages: [Settings.shared.langRawValue]), message: R.string.localizable.foldersLocationLevelAlert(preferredLanguages: [Settings.shared.langRawValue]))
            return
        }
        
        guard validateFolderNameLength(folderName) else {
            showAlert(title: R.string.localizable.foldersWarning(preferredLanguages: [Settings.shared.langRawValue]), message: R.string.localizable.foldersNameLengthAlert(preferredLanguages: [Settings.shared.langRawValue]))
            return
        }
        
        if self.editMode == true, let name = folderTextField.text, let editFolderID = editFolderID {
            guard let editFolder = RealmManager.shared.getFolder(withId: editFolderID.uuidString).first else { return }
            RealmManager.shared.updateFolderData(editFolder, folderName: name, idParentFolder: locationFolderID?.uuidString)
        } else if let name = folderTextField.text {
            foldersVCDelegate?.getNewFolder(name: name, nestedIndex: nestedIndex, locationFolderID: locationFolderID)
        }
        self.foldersVCDelegate?.updateContent()
        self.dismiss(animated: true)
    }
    
    
    
    
    private func validateFolderLevel(_ nestedIndex: Int?) -> Bool {
        return (nestedIndex ?? 0) <= Constant.maxNestedIndex
    }
    
    private func validateFolderNameLength(_ folderName: String) -> Bool {
        return folderName.count <= Constant.maxFolderNameLength
    }
    
    private func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: R.string.localizable.foldersOk(preferredLanguages: [Settings.shared.langRawValue]), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func getLocationFolderData(id: UUID?, nestedIndex: Int?) {
        print("\(id as UUID?)")
        print("\(nestedIndex as Int?)")
        self.locationFolderID = id
        self.nestedIndex = nestedIndex
    }
    
    
}
