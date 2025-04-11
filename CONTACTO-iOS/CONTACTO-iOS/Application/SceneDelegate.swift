//
//  SceneDelegate.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let rootViewController = SplashViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        if let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo {
                handleNotification(userInfo)
        }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }

        if type == "chat", let chatRoomId = userInfo["chatRoomId"] as? String {
            navigateToChatRoom(chatRoomId)
        }
    }

    func navigateToChatRoom(_ chatRoomId: String) {
        guard let roomId = Int(chatRoomId) else { return }
        
        NetworkService.shared.chatService.chatRoomMessage(roomId: roomId) { [weak self] response in
            switch response {
            case .success(let data):
                DispatchQueue.main.async {
                    let chatRoomViewController = ChatRoomViewController()
                    chatRoomViewController.chatRoomId = data.id
                    chatRoomViewController.chatRoomTitle = data.title
                    chatRoomViewController.chatRoomThumbnail = data.chatRoomThumbnail
                    chatRoomViewController.participants = data.participants
                    chatRoomViewController.chatList = data.messages
                    
                    if let tabBarController = self?.window?.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 1 // 채팅 탭으로 이동
                        if let navigationController = tabBarController.selectedViewController as? UINavigationController {
                            navigationController.pushViewController(chatRoomViewController, animated: true)
                        }
                    }
                }
            default:
                print("채팅방 데이터를 가져오는데 실패했습니다.")
            }
        }
    }


}

