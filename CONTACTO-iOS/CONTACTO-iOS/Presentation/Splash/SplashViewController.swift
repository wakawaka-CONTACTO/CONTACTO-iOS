//
//  SplashViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/28/24.
//

import UIKit

import SnapKit
import Then

final class SplashViewController: UIViewController {
    
    let logoImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        changeColor()
        checkVersionTask()
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        self.view.do {
            $0.backgroundColor = .ctmainblue
        }
        
        logoImageView.do {
            $0.image = .imgSplash
        }
    }
    
    private func setLayout() {
        self.view.addSubviews(logoImageView)
        
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func changeColor() {
        UIView.animate(withDuration: 2, animations: {
            self.view.backgroundColor = .ctblack
        })
    }
    
    func checkVersionTask() {
        _ = try? AppVersionCheck.isUpdateAvailable { [weak self] (update, error) in
            guard let self = self else { return }
            if let error = error {
                debugPrint("checkVersionTask err : \(error)")
                // 에러 발생 시 2.5초 후 다음 화면으로 전환
                self.navigateToNextScreen()
                return
            } else if let update = update {
                if update {
                    debugPrint("This App is old version")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "업데이트가 필요합니다", message: "", preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "확인", style: .default, handler : { _ in
                            AppVersionCheck.appUpdate()
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                } else {
                    debugPrint("This App is latest version")
                    // 최신 버전일 경우 2.5초 후 다음 화면으로 전환
                    self.navigateToNextScreen()
                    return
                }
            }
        }
    }
    
    /// 다음 화면으로 전환하는 메서드
    private func navigateToNextScreen() {
        // 애니메이션이 완료될 시점(2초)에 맞춰 화면 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            var nextViewController: UIViewController
            
            if KeychainHandler.shared.accessToken.isEmpty {
                nextViewController = LoginViewController()
            } else {
                nextViewController = MainTabBarViewController()
            }
            
            let navigationController = UINavigationController(rootViewController: nextViewController)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
