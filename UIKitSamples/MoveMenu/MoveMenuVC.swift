//
//  MoveMenuVC.swift
//  AirBill
//
//  Created by Andrey on 19.08.2022.
//

import UIKit

class MoveMenuVC: ColoredViewController, MoveMenuVCProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var billImageView: UIImageView!
    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet weak var billInfoLabel: UILabel!
    @IBOutlet weak var newFolderButton: UIBarButtonItem!
    
    var presenter: MoveMenuPresenterProtocol
    var moveAlongPath: CAAnimation!
    
    weak var openBillDelegate: OpenBillVCDelegate?
    weak var dataDelegate: DataVCDelegate?
    
    enum Constants {
        static let duration = 0.5
        static let startXPosition: CGFloat = 50
        static let controlXPosition: CGFloat = 150
        static let footerHeight: CGFloat = 30
        static let footerLeftInset: CGFloat = 0
        static let heightCell: CGFloat = 44
    }
    
    required init(presenter: MoveMenuPresenter){
        self.presenter = presenter
        super.init(nibName: R.nib.moveMenuVC.name, bundle: nil)
        self.presenter.managedView = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        prepareView()
        prepareNavVC()
        presenter.createData()
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    func prepareNavVC(){
        title = R.string.localizable.moveMenuMoveTo(preferredLanguages: [Settings.shared.langRawValue])
        let backBtn = MainInboxHelper().leftBackNavBarButton(text: presenter.backButtonTitle)
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.foldersCancel(preferredLanguages: [Settings.shared.langRawValue]), style: .done, target: self, action: #selector(cancelTapped))
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func prepareView(){
        
        billNameLabel.font = R.font.sfProTextSemibold(size: 17)
        billInfoLabel.font = R.font.sfProTextRegular(size: 15)
        billImageView.backgroundColor = R.color.greyColor()
        billImageView.roundCorners(radius: 8)
        billImageView.contentMode = .scaleAspectFill
        newFolderButton.title = R.string.localizable.foldersNewFolder(preferredLanguages: [Settings.shared.langRawValue])
    }
    
    // MARK: Анимация готова, нужно только раскоментить и выставить задержку - pulseAnimation.beginTime
    func moveTo(index: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
            let rect = tableView.rectForRow(at: IndexPath(row: index, section: 0))
            let rectInScreen = tableView.convert(rect, to: tableView.superview)
            addAnimation(position: rectInScreen.origin)
            addCellAnimation(cell: cell, delete: false)
            initiateAnimation()
        }
    }
    
    func expand(index: Int) {
        tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        tableView.reloadRows(at: [IndexPath(item: index - 1, section: 0)], with: .automatic)
    }
    
    @objc func backTapped() {
        self.dismiss(animated: true) {
            self.openBillDelegate?.returnBack()
            self.dataDelegate?.returnBack()
        }
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func reloadView(image: UIImage, titleInfo: String, textInfo: String) {
        billInfoLabel.text = textInfo
        billNameLabel.text = titleInfo
        billImageView.image = image
    }
    
    func closeVC() {
        backTapped()
    }
    // MARK: Анимация готова, нужно только раскоментить и выставить задержку - pulseAnimation.beginTime
    func removeWith(_ index: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
            let rect = tableView.rectForRow(at: IndexPath(row: index, section: 0))
            let rectInScreen = tableView.convert(rect, to: tableView.superview)
            addAnimation(position: rectInScreen.origin)
            addCellAnimation(cell: cell, delete: true)
            initiateAnimation()
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    @IBAction func addFolder(_ sender: Any) {
        Router.shared.presentNewFolderVC(vc: self)
    }
}

extension MoveMenuVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = presenter.getItem(at: indexPath.row)
        else { return UITableViewCell() }
        let cell = MoveMenuCell(style: .subtitle, reuseIdentifier: MoveMenuCell.reuseKey)
        cell.model = model
        cell.layoutMargins = UIEdgeInsets(top: 0, left: (CGFloat(model.nestedIndex ?? 0)+1) * FoldersMainCell.Constant.inset, bottom: 0, right: 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().createHeaderView(frame: CGRect(x: 20, y: -3, width: tableView.frame.size.width, height: 16), text: R.string.localizable.moveMenuSelectFolderToMove(preferredLanguages: [Settings.shared.langRawValue]))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Constants.footerHeight
    }
    // MARK: EXPAND LOGIC
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let model = presenter.getItem(at: indexPath.row) else { return 0 }
        if model.selected {
            return Constants.heightCell
        }
        return 0
    }
}
extension MoveMenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = presenter.getItem(at: indexPath.row) else { return }
        model.action()
    }
}
// MARK: Animation
extension MoveMenuVC {
    
    func addCellAnimation(cell: UITableViewCell, delete: Bool = false){
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let self = self else { return }
            if delete {
                self.presenter.deleteWithRealm()
            }else{
                self.closeVC()
            }
            self.view.isUserInteractionEnabled = true
        }
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.2
        pulseAnimation.beginTime = CACurrentMediaTime() + Constants.duration //
        pulseAnimation.fromValue = NSNumber(value: 0.95)
        pulseAnimation.toValue = NSNumber(value: 1.0)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = false
        pulseAnimation.repeatCount = 0
        cell.contentView.layer.add(pulseAnimation, forKey: nil)
        CATransaction.commit()
    }
    
    func curevedPath(position: CGPoint) -> UIBezierPath {
        
        let path = createCurvePath(position: position)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        //shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        //shapeLayer.lineWidth = 1.0
        self.view.layer.addSublayer(shapeLayer)
        return path
    }
    
    
    func addAnimation(position: CGPoint) {
        let moveAlongPath = CAKeyframeAnimation(keyPath: "position")
        moveAlongPath.path = curevedPath(position: position).cgPath
        moveAlongPath.duration = Constants.duration
        moveAlongPath.repeatCount = 0
        moveAlongPath.calculationMode = CAAnimationCalculationMode.paced
        moveAlongPath.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]
        self.moveAlongPath = moveAlongPath
    }
    
    func initiateAnimation() {
        let layer = createLayer()
        layer.add(moveAlongPath, forKey: "animate along Path")
    }
    
    //MARK:- Custom View Path
    func createLayer() -> CALayer {
        let customView = UIImageView(frame: billImageView.frame)
        customView.backgroundColor = R.color.greyColor()
        customView.roundCorners(radius: 8)
        customView.image = billImageView.image
        customView.contentMode = .scaleAspectFill
        view.addSubview(customView)
        customView.rotate(duration: Constants.duration, degree: 1)
        
        let customlayer = customView.layer
        customlayer.bounds = customView.frame
        customlayer.position = customView.center
        return customlayer
    }
    
    //MARK:- Custom Curve Path
    func createCurvePath(position: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: billImageView.center)
        let y = position.y + billImageView.frame.height
        path.addQuadCurve(to: CGPoint(x: Constants.startXPosition, y: position.y + billImageView.frame.height/2), controlPoint: CGPoint(x: Constants.controlXPosition, y: y) )
        return path
    }
}

extension MoveMenuVC: FoldersVCDelegate {
    func updateContent() {
        presenter.updateFolders()
    }
    
    func getNewFolder(name: String, nestedIndex: Int?, locationFolderID: UUID?) {
        if let locationFolderID = locationFolderID, var nestedIndex = nestedIndex {
            nestedIndex += 1
            presenter.addNewFolder(FolderRealm(folderName: name, nestedIndex: nestedIndex), locationFolderID: locationFolderID)
        } else {
            presenter.addNewFolder(FolderRealm(folderName: name, nestedIndex: 0), locationFolderID: nil)
        }
        presenter.updateFolders()
    }
}
