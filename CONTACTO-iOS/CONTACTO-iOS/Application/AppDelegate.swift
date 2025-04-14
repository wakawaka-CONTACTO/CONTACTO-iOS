//
//  AppDelegate.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import FirebaseAnalytics
import AmplitudeSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Analytics.logEvent("button_click", parameters: [
            "button_name": "main_button" as NSObject
        ])
        
        UNUserNotificationCenter.current().delegate = self
        
        Messaging.messaging().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter
          .current()
          .requestAuthorization(
            options: authOptions,completionHandler: { (_, _) in }
          )
        
        UIApplication.shared.registerForRemoteNotifications()
        let configuration = Configuration(apiKey: Config.amplitudeApiKey)
        AmplitudeManager.amplitude = Amplitude(configuration: configuration)
        UserIdentityManager.setUserId()
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isPushAgreed = settings.authorizationStatus == .authorized
            
            UserIdentityManager.agreePushNotification(isAgree: isPushAgreed)
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.handleNotification(userInfo)
        completionHandler()
    }
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }

        switch type {
        case "chat":
            if let chatRoomId = userInfo["chatRoomId"] as? String {
                navigateToChatRoom(chatRoomId)
            }
        default:
            break
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
                    
                    // 현재 활성화된 Scene 찾기
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                    
                    // SceneDelegate 찾기
                    guard let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                    
                    // Window 찾기
                    guard let window = sceneDelegate.window else { return }
                    
                    // RootViewController 찾기
                    guard let rootViewController = window.rootViewController else { return }
                    
                    // TabBarController 찾기
                    var tabBarController: UITabBarController?
                    
                    // 현재 rootViewController가 TabBarController인 경우
                    if let tabBar = rootViewController as? UITabBarController {
                        tabBarController = tabBar
                    }
                    // NavigationController 안에 TabBarController가 있는 경우
                    else if let navigationController = rootViewController as? UINavigationController,
                            let tabBar = navigationController.viewControllers.first as? UITabBarController {
                        tabBarController = tabBar
                    }
                    
                    guard let tabBar = tabBarController else { return }
                    
                    tabBar.selectedIndex = 1 // 채팅 탭으로 이동
                    
                    // NavigationController 찾기
                    guard let navigationController = tabBar.selectedViewController as? UINavigationController else { return }
                    
                    // TabBar 숨기기
                    tabBar.tabBar.isHidden = true
                    
                    navigationController.pushViewController(chatRoomViewController, animated: true)
                }
            default:
                print("채팅방 데이터를 가져오는데 실패했습니다.")
            }
        }
    }

}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase Token: \(String(describing: fcmToken))")
        
        guard let token = fcmToken else { return }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = UIDevice.current.model
        
        // 서버에 디바이스 토큰 업데이트 요청
        NetworkService.shared.alarmService.updateDeviceToken(bodyDTO: DeviceTokenRequestDTO(
            deviceId: deviceId,
            deviceType: deviceType,
            firebaseToken: token
        )) { response in
            switch response {
            case .success:
                print("Device token updated successfully")
            case .requestErr:
                print("Request error while updating device token")
            case .pathErr:
                print("Path error while updating device token")
            case .serverErr:
                print("Server error while updating device token")
            case .networkErr:
                print("Network error while updating device token")
            case .failure(let error):
                print("Failure error while updating device token: \(error)")
            }
        }
    }
}
