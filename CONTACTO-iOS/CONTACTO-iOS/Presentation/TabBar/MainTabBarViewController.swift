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
    
    private var tabsList: [UIViewController] = []
    
    let homeViewController = HomeViewController()
    let chatViewController = ChatListViewController()
    let editViewController = EditViewController()
    let infoViewController = InfoViewController()
    
    private var hasChatNotification: Bool = false {
        didSet {
            updateChatTabIcon()
        }
    }

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
        updateChatTabIcon()
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(moveToChat(_:)),
            name: NSNotification.Name("moveToChat"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChatNotification(_:)),
            name: NSNotification.Name("newChatNotification"),
            object: nil
        )
    }
    
    private func updateChatTabIcon() {
        guard let chatTab = tabsList[1].tabBarItem else { return }
        
        if hasChatNotification {
            chatTab.image = .chatnew
            chatTab.selectedImage = .chatnewSelected
        } else {
            chatTab.image = .chat
            chatTab.selectedImage = .chatSelected
        }
    }
    
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .ctblack
        self.tabBar.itemPositioning = .fill
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setTabs() {
        tabsList = [
            UINavigationController(rootViewController: homeViewController),
            UINavigationController(rootViewController: chatViewController),
            UINavigationController(rootViewController: editViewController),
            UINavigationController(rootViewController: infoViewController)
        ]
    }
    
    private func setDelegate() {
        self.delegate = self
    }
    
    private func setTabBarItems() {
        self.setViewControllers(tabsList, animated: true)
        
        let tabBar: UITabBar = self.tabBar
        tabBar.backgroundColor = .ctblack
        tabBar.barStyle = UIBarStyle.default
        tabBar.barTintColor = .ctblack
        
        TabBarItems.allCases.forEach {
            tabsList[$0.rawValue].tabBarItem = $0.asTabBarItem()
            tabsList[$0.rawValue].tabBarItem.tag = $0.rawValue
        }
    }
    
    @objc private func moveToChat(_ notification: Notification) {
        self.selectedIndex = 1
    }
    
    @objc private func handleChatNotification(_ notification: Notification) {
        if let unreadCount = notification.userInfo?["hasUnreadMessages"] as? Bool {
            hasChatNotification = unreadCount
        }
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
}
