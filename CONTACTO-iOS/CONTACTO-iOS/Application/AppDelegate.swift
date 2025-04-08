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
        let userId = "\(KeychainHandler.shared.userID) - \(KeychainHandler.shared.userName)"
        AmplitudeManager.amplitude.setUserId(userId: userId)
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
        if let meetingID = userInfo["MEETING_ID"] as? String, let userID = userInfo["USER_ID"] as? String {
            switch response.actionIdentifier {
            case "ACCEPT_ACTION":
                print("Accept action - meetingID: \(meetingID), userID: \(userID)")
            case "DECLINE_ACTION":
                print("Decline action - meetingID: \(meetingID), userID: \(userID)")
            default:
                break
            }
        }
        completionHandler()
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
