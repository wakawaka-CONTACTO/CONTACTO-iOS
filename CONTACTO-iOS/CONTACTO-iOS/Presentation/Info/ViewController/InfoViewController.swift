//
//  InfoViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/20/24.
//

import UIKit

import SafariServices
import SnapKit
import Then

final class InfoViewController: BaseViewController, InfoAmplitudeSender {
    private let infoView = InfoView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkMyPort { _ in }
        self.sendAmpliLog(eventName: EventName.VIEW_INFO)
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(infoView)
        
        infoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
    
    override func setAddTarget() {
        infoView.helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        infoView.guidelinesButton.addTarget(self, action: #selector(guidelinesTapped), for: .touchUpInside)
        infoView.cookieButton.addTarget(self, action: #selector(cookieButtonTapped), for: .touchUpInside)
        infoView.logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        infoView.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    private func checkMyPort(completion: @escaping (Bool) -> Void) {
        NetworkService.shared.editService.checkMyPort { [weak self] response in
            switch response {
            case .success(let data):
                self?.infoView.emailLabel.text = data.email
                completion(true)
            default:
                completion(false)
            }
        }
    }
}

extension InfoViewController {
    @objc private func helpButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.insta) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        self.sendAmpliLog(eventName: EventName.CLICK_INFO_HELP)
    }
    
    @objc private func guidelinesTapped() {
        guard let url = URL(string: StringLiterals.URL.guidelines) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
        self.sendAmpliLog(eventName: EventName.CLICK_INFO_COMMUNITY)
    }
    
    @objc private func cookieButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.privacy) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
        self.sendAmpliLog(eventName: EventName.CLICK_INFO_PRIVACY)
    }
    
    @objc private func logoutButtonTapped() {
        self.setLogoutAlertController()
        self.sendAmpliLog(eventName: EventName.CLICK_INFO_LOGOUT)
    }
    
    @objc private func deleteButtonTapped() {
        self.setDeleteAlertController()
        self.sendAmpliLog(eventName: EventName.CLICK_INFO_DELETE)
    }
    
    private func setLogoutAlertController() {
        let title = StringLiterals.Info.Alert.Logout.logoutTitle
        let description = StringLiterals.Info.Alert.Logout.logoutDescription
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: StringLiterals.Info.Alert.Logout.no, style: .cancel){ cancel in
            self.sendAmpliLog(eventName: EventName.CLICK_INFO_LOGOUT_NO)
        }
        
        let success = UIAlertAction(title: StringLiterals.Info.Alert.Logout.yes, style: .default){ [weak self] action in
            guard let self = self else { return }
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            
            NetworkService.shared.infoService.logout(deviceId: deviceId) { response in
                switch response {
                case .success:
                    KeychainHandler.shared.accessToken.removeAll()
                    KeychainHandler.shared.refreshToken.removeAll()

                    AmplitudeManager.amplitude.flush()
                    AmplitudeManager.amplitude.reset()
                    self.sendAmpliLog(eventName: EventName.CLICK_INFO_LOGOUT_YES)
                  
                    guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                    sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
                default:
                    self.view.showToast(message: "로그아웃에 실패했습니다.")
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(success)
        present(alert, animated: true)
    }
    
    private func setDeleteAlertController() {
        let title = StringLiterals.Info.Alert.Delete.deleteTitle
        let description = StringLiterals.Info.Alert.Delete.deleteDescription
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let notYet = UIAlertAction(title: StringLiterals.Info.Alert.Delete.notYet, style: .default){ action in
            self.sendAmpliLog(eventName: EventName.CLICK_INFO_DELETE1_NO)
        }
        
        let yes = UIAlertAction(title: StringLiterals.Info.Alert.Delete.yes, style: .destructive){ cancel in
            self.showFinalDeleteConfirmation()
            self.sendAmpliLog(eventName: EventName.CLICK_INFO_DELETE1_YES)
        }
        
        alert.addAction(notYet)
        alert.addAction(yes)
        present(alert, animated: true)
    }
    
    private func showFinalDeleteConfirmation() {
        let title = StringLiterals.Info.Alert.Delete.finalTitle
        let description = StringLiterals.Info.Alert.Delete.finalDescription
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: StringLiterals.Info.Alert.Delete.delete, style: .destructive) { _ in
            self.sendAmpliLog(eventName: EventName.CLICK_INFO_DELETE2_YES)
            self.deleteMe { _ in
                KeychainHandler.shared.accessToken.removeAll()
                KeychainHandler.shared.refreshToken.removeAll()
                AmplitudeManager.amplitude.flush()
                AmplitudeManager.amplitude.reset()
                guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
            }
        }
        
        let cancle = UIAlertAction(title: StringLiterals.Info.Alert.Delete.cancel, style: .cancel){ action in
            self.sendAmpliLog(eventName: EventName.CLICK_INFO_DELETE2_NO)
        }
        
        alert.addAction(delete)
        alert.addAction(cancle)
        present(alert, animated: true)
    }
    
    private func deleteMe(completion: @escaping (Bool) -> Void) {
        NetworkService.shared.infoService.deleteMe() { response in
            switch response {
            case .success(_):
                completion(true)
            default:
                completion(false)
            }
        }
    }
}
