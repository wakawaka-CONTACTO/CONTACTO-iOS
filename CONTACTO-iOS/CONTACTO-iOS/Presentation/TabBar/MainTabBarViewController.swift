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
    
    let homeViewController = HomeViewController(isPreview: false)
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
            print("TabBar: 채팅 아이콘 변경 - 읽지 않은 메시지 있음 (chatnew)")
            chatTab.image = UIImage(resource: .chatnew)
            chatTab.selectedImage = UIImage(resource: .chatnewSelected).withRenderingMode(.alwaysOriginal)
        } else {
            print("TabBar: 채팅 아이콘 변경 - 읽지 않은 메시지 없음 (chat)")
            chatTab.image = UIImage(resource: .chat)
            chatTab.selectedImage = UIImage(resource: .chatSelected).withRenderingMode(.alwaysOriginal)
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

        // 채팅방 뷰컨트롤러가 있다면 채팅방으로 이동
        if let chatRoomViewController = notification.userInfo?["chatRoomViewController"] as? ChatRoomViewController,
        let navigationController = self.viewControllers?[1] as? UINavigationController {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                navigationController.pushViewController(chatRoomViewController, animated: true)
            }
        }
    }
    
    @objc private func handleChatNotification(_ notification: Notification) {
        if let unreadCount = notification.userInfo?["hasUnreadMessages"] as? Bool {
            hasChatNotification = unreadCount
        }
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // 채팅 탭(인덱스 1)이 선택되었을 때 데이터 새로고침
        if tabBarController.selectedIndex == 1, let navController = viewController as? UINavigationController,
           let chatListVC = navController.topViewController as? ChatListViewController {
            print("TabBar: 채팅 탭 선택됨 - 새로고침 요청")
            NotificationCenter.default.post(name: NSNotification.Name("RefreshChatList"), object: nil)
        }
    }
}
