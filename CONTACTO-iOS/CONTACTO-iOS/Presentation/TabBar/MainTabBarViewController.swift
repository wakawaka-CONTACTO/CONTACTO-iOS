//
//  MainTabBarViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit

import SnapKit
import Then

final class MainTabBarViewController: UITabBarController {
    
    private var tabs: [UIViewController] = []
    
    let homeViewController = HomeViewController()
    let chatViewController = UIViewController()
    let profileViewController = UIViewController()
    let listViewController = UIViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        setTabBarAppearance()
        setNotification()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight: CGFloat = 85
        tabBar.frame.size.height = tabBarHeight + safeAreaHeight
        tabBar.frame.origin.y = view.frame.height - tabBarHeight - safeAreaHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        setTabs()
        setTabBarItems()
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(moveToChat(_:)),
            name: NSNotification.Name("moveToChat"),
            object: nil
        )

    }
    
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .ctblack
        self.tabBar.itemPositioning = .fill
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setTabs() {
        tabs = [
            UINavigationController(rootViewController: homeViewController),
            UINavigationController(rootViewController: chatViewController),
            UINavigationController(rootViewController: profileViewController),
            UINavigationController(rootViewController: listViewController)
        ]
    }
    
    private func setDelegate() {
        self.delegate = self
    }
    
    private func setTabBarItems() {
        self.setViewControllers(tabs, animated: true)
        
        let tabBar: UITabBar = self.tabBar
        tabBar.backgroundColor = .ctblack
        tabBar.barStyle = UIBarStyle.default
        tabBar.barTintColor = .ctblack
        
        TabBarItems.allCases.forEach {
            tabs[$0.rawValue].tabBarItem = $0.asTabBarItem()
            tabs[$0.rawValue].tabBarItem.tag = $0.rawValue
        }
    }
    
    @objc private func moveToChat(_ notification: Notification) {
        self.selectedIndex = 1
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
}
