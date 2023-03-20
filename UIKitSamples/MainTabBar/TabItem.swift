//
//  TabItem.swift
//  AirBill
//
//  Created by Andrey on 07.07.2022.
//

import UIKit

struct TabItem {
    let viewController: UIViewController
    
    init(viewController: UIViewController, icon: UIImage?, title: String, selectedIcon: UIImage?) {
        self.viewController = viewController
        self.viewController.tabBarItem.image = icon
        self.viewController.tabBarItem.title = title
        self.viewController.tabBarItem.selectedImage = selectedIcon
    }
}
