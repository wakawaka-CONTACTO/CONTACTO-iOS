//
//  AppVersionCheck.swift
//  CONTACTO-iOS
//
//  Created by hana on 4/7/25.
//

import Foundation

import UIKit

enum VersionError: Error {
  case invalidResponse, invalidBundleInfo
}

class AppVersionCheck {
    
    static let shared = AppVersionCheck()
    private init() { }
    
    static func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/kr/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
            }
        #if DEBUG
        print("현재 설치된 앱 버전: \(currentVersion)")
        #endif
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                } // 앱스토어 버전 가져오기
                #if DEBUG
                print("앱스토어 버전: \(version)")
                #endif
                
                // 앱스토어의 버전을 .을 기준으로 나눈 것
                let splitMarketingVersion = version.split(separator: ".").map { Int($0) ?? 0 }
                
                // 현재 기기의 버전을 .을 기준으로 나눈 것
                let splitCurrentProjectVersion = currentVersion.split(separator: ".").map { Int($0) ?? 0 }
                
                if splitCurrentProjectVersion.count > 1 && splitMarketingVersion.count > 1 {
                    // 현재 기기의 Major 버전이 앱스토어의 Major 버전보다 낮다면 업데이트 필요
                    if splitCurrentProjectVersion[0] < splitMarketingVersion[0] {
                        completion(true, nil)
                    // 현재 기기의 Minor 버전이 앱스토어의 Minor 버전보다 낮다면 업데이트 필요
                    } else if splitCurrentProjectVersion[1] < splitMarketingVersion[1] {
                        completion(true, nil)
                    // Patch의 버전이 다르거나 최신 버전이라면 업데이트 불필요
                    } else {
                        #if DEBUG
                        print("현재 최신 버전입니다.")
                        #endif
                        completion(false, nil)
                    }
                } else {
                    completion(false, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    // AppStore 이동
   static func appUpdate() {
        let appId = "id6736873767"
        // UIApplication 은 Main Thread 에서 처리
        DispatchQueue.main.async {
            if let url = URL(string: "https://apps.apple.com/kr/app/\(appId)"), UIApplication.shared.canOpenURL(url) {
                #if DEBUG
                print("앱스토어 url: \(url)")
                #endif
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: {_ in
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    })
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
