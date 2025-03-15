//
//  TabBarItems.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/17/24.
//

import UIKit

enum TabBarItems: Int, CaseIterable {
    case home
    case chat
    case profile
    case likeList
}

extension TabBarItems {
    var Icon: UIImage? {
        switch self {
        case .home:         return UIImage(resource: .home)
        case .chat:         return UIImage(resource: .chat)
        case .profile:      return UIImage(resource: .profile)
        case .likeList:     return UIImage(resource: .likelist)
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .home:         return UIImage(resource: .homeSelected).withRenderingMode(.alwaysOriginal)
        case .chat:         return UIImage(resource: .chatSelected).withRenderingMode(.alwaysOriginal)
        case .profile:      return UIImage(resource: .profileSelected).withRenderingMode(.alwaysOriginal)
        case .likeList:     return UIImage(resource: .likelistSelected).withRenderingMode(.alwaysOriginal)
        }
    }
}

extension TabBarItems {
    public func asTabBarItem() -> UITabBarItem {
        let tabBarItem = UITabBarItem(
            title: nil,
            image: Icon,
            selectedImage: selectedIcon
        )
        
        tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -5, right: 0)
        
        return tabBarItem
    }
}
