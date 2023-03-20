//
//  MainTabBarVC.swift
//  AirBill
//
//  Created by Andrey on 07.07.2022.
//

import UIKit

class MainTabBarVC: UITabBarController, UITabBarControllerDelegate {
    
    convenience init(index: Int) {
        self.init()
        selectedIndex = index
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateTabBar()
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Settings.shared.onboardingShowed {
            present(OnboardingVC(), animated: false)
        }
    }
    
    private func generateTabBar() {
        
        viewControllers = [
            generateViewController(TabItem(viewController: NavigationVC(rootViewController: MainInboxScreenVC(presenter: MainInboxPresenter(type: .inbox, screenType: .inbox)), title: "", prefersLargeTitles: false), icon: R.image.unselectedInboxImage(), title: R.string.localizable.tabBarInbox(preferredLanguages: [Settings.shared.langRawValue]), selectedIcon: R.image.selectedInboxImage())),
            generateViewController(TabItem(viewController: NavigationVC(rootViewController: FoldersVC(title: R.string.localizable.foldersFolders(), presenter: FoldersPresenter()), title: R.string.localizable.foldersFolders(), prefersLargeTitles: false, backgroundColor: .clear), icon: R.image.unselectedFoldersImage(), title: R.string.localizable.tabBarFolders(preferredLanguages: [Settings.shared.langRawValue]), selectedIcon: R.image.selectedFoldersImage())),
            generateViewController(TabItem(viewController: TVC(), icon: R.image.addBillImage(), title: R.string.localizable.tabBarAddBill(preferredLanguages: [Settings.shared.langRawValue]), selectedIcon: R.image.addBillImage())),
            generateViewController(TabItem(viewController: NavigationVC(rootViewController: SettingsVC(title: R.string.localizable.settingsSettings(), presenter: SettingsPresenter(type: .main)), title: R.string.localizable.settingsSettings(), prefersLargeTitles: true, backgroundColor: .clear), icon: R.image.unselectedSettingsImage(), title: R.string.localizable.tabBarSettings(preferredLanguages: [Settings.shared.langRawValue]), selectedIcon: R.image.selectedSettingsImage()))
        ]
        UITabBar.appearance().tintColor = R.color.darkGreen()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let controllers = viewControllers, viewController == controllers.first(where: { $0.isKind(of: TVC.self) }) {
            showAddBill()
            return false
        }
        return true
    }
    
    private func generateViewController(_ item: TabItem) -> UIViewController {
        return item.viewController
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let rootView = self.viewControllers![self.selectedIndex] as! UINavigationController
        rootView.popToRootViewController(animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) { }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabbarFadeTransition()
    }
    
    private func showAddBill(){
        if let navVC = navigationController {
            navVC.pushViewController(CameraBillVC(title: ""), animated: true)
        }
    }
}

class TVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}
