//
//  PortfolioOnboardingViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import PhotosUI
import SnapKit
import Then
import FirebaseMessaging

final class PortfolioOnboardingViewController: BaseViewController, OnboadingAmplitudeSender, CropImageViewControllerDelegate {
    
    private let portfolioOnboardingView = PortfolioOnboardingView()
    private var isLoading = false
    private var pendingImages: [UIImage] = []
    
    // 로딩 인디케이터 추가
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = UIColor(white: 0, alpha: 0.3)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    var portfolioItems: [UIImage] = [] {
        didSet {
            portfolioOnboardingView.nextButton.isEnabled = (!portfolioItems.isEmpty)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        self.sendAmpliLog(eventName: EventName.VIEW_ONBOARDING6)
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func setDelegate() {
        portfolioOnboardingView.portfolioCollectionView.delegate = self
        portfolioOnboardingView.portfolioCollectionView.dataSource = self
    }
    
    override func setAddTarget() {
        portfolioOnboardingView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func setLayout() {
        view.addSubviews(portfolioOnboardingView)
        
        portfolioOnboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 로딩 인디케이터 레이아웃 추가
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalTo: view.widthAnchor),
            activityIndicator.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    // 로딩 인디케이터 제어 메서드 추가
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    @objc private func nextButtonTapped() {
        showLoadingIndicator()
        isLoading = true
        portfolioOnboardingView.nextButton.isEnabled = false
        UserInfo.shared.portfolioImageUrl = self.portfolioItems.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = UIDevice.current.model
        let portfolio_count = UserInfo.shared.portfolioImageUrl.count
        let totalImageSizeBytes = UserInfo.shared.portfolioImageUrl.reduce(0) { $0 + $1.count }
        
        sendAmpliLog(eventName: EventName.CLICK_ONBOARDING6_NEXT, properties: [
            "portfolio_count": portfolio_count,
            "portfolio_total_size_bytes": totalImageSizeBytes
        ])
        
        
        Messaging.messaging().token { [weak self] firebaseToken, error in
            guard let self = self else { return }
            guard let firebaseToken = firebaseToken else {
                print("❌ FCM 토큰 가져오기 실패")
                self.hideLoadingIndicator()
                return
            }

            let bodyData = SignUpRequestBodyDTO(
                userSignUpReq: UserSignUpRequest(
                    name: UserInfo.shared.name,
                    email: UserInfo.shared.email,
                    description: UserInfo.shared.description,
                    instagramId: UserInfo.shared.instagramId,
                    password: UserInfo.shared.password,
                    loginType: "LOCAL",
                    nationality: UserInfo.shared.nationality,
                    webUrl: UserInfo.shared.webUrl,
                    firebaseToken: firebaseToken,
                    deviceId: deviceId,
                    deviceType: deviceType),
                purpose: UserInfo.shared.userPurposes.map { Purpose(purposeType: $0) },
                talent: UserInfo.shared.userTalents.map { TalentType(talentType: $0) },
                images: UserInfo.shared.portfolioImageUrl)

            self.signup(bodyDTO: bodyData) { [weak self] success, errorMessage in
                guard let self = self else { return }

                self.isLoading = false
                self.hideLoadingIndicator()
                if success {
                    let mainTabBarViewController = MainTabBarViewController()
                    mainTabBarViewController.homeViewController.isFirst = true
                    self.navigationController?.pushViewController(mainTabBarViewController, animated: true)
                    
                } else {
                    AlertManager.showAlert(
                        on: self,
                        title: "Error",
                        message: errorMessage ?? "잠시 후 다시 시도해주세요."
                    )
                    // todo, bodyData logs
                    self.sendAmpliLog(eventName: EventName.ERROR, properties:
                                        [
                                            "email": UserInfo.shared.email,
                                            "name": UserInfo.shared.name,
                                            "description": UserInfo.shared.description,
                                            "instagramId": UserInfo.shared.instagramId,
                                            "nationality": UserInfo.shared.nationality,
                                            "webUrl": UserInfo.shared.webUrl,
                                            "userPurposes": UserInfo.shared.userPurposes,
                                            "userTalents": UserInfo.shared.userTalents
                                        ]
                    )
                }
                self.portfolioOnboardingView.nextButton.isEnabled = true
            }
        }
    }
    
    private func setCollectionView() {
        portfolioOnboardingView.portfolioCollectionView.register(PortfolioCollectionViewCell.self, forCellWithReuseIdentifier: PortfolioCollectionViewCell.className)
    }
    
    func setPortfolio() {
        guard !isLoading else { return }
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10 - portfolioItems.count
        configuration.filter = .any(of: [.images])
        configuration.selection = .ordered
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func cropImageViewController(_ controller: CropImageViewController, didCrop image: UIImage) {
        let screenSize = UIScreen.main.bounds.size
        let targetSize = CGSize(
            width: screenSize.width * 1.5,
            height: screenSize.height * 1.5
        )
        
        // 크롭된 이미지를 리사이징
        let resizedImage: UIImage
        if image.needsResizing(targetSize: targetSize),
           let tempResizedImage = image.resized(to: targetSize) {
            resizedImage = tempResizedImage
        } else {
            resizedImage = image
        }
        
        // 리사이징된 이미지를 포트폴리오에 추가
        if canAddImage(resizedImage) {
            portfolioItems.append(resizedImage)
            portfolioOnboardingView.portfolioCollectionView.reloadData()
        }
        
        // 다음 이미지가 있으면 크롭 화면 표시
        if !pendingImages.isEmpty {
            let nextImage = pendingImages.removeFirst()
            let cropVC = CropImageViewController()
            cropVC.delegate = self
            cropVC.imagesToCrop = [nextImage]
            
            // 현재 뷰 컨트롤러가 이미 dismiss된 상태이므로, 새로운 크롭 화면을 표시
            DispatchQueue.main.async { [weak self] in
                self?.present(cropVC, animated: true)
            }
        } else {
            // 모든 이미지 크롭이 완료되면 현재 크롭 화면을 닫음
            controller.dismiss(animated: true)
        }
    }
    
    func cropImageViewControllerDidCancel(_ controller: CropImageViewController) {
        // 크롭 취소 시 이미지 선택 화면으로 돌아가기
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.setPortfolio()
        }
    }
    
    private func canAddImage(_ image: UIImage) -> Bool {
        return !portfolioItems.contains(where: { $0.isEqualTo(image) }) && portfolioItems.count < 10
    }
    
    private func signup(bodyDTO: SignUpRequestBodyDTO,completion: @escaping (Bool, String?) -> Void) {
        NetworkService.shared.onboardingService.signup(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
                KeychainHandler.shared.userID = String(data.userId)
                KeychainHandler.shared.accessToken = data.accessToken
                KeychainHandler.shared.refreshToken = data.refreshToken
                completion(true, nil)
            case .failure(let error):
                // 서버에서 온 에러 메시지 추출
                let reason = self.extractFirstErrorReason(from: error.data!)
                completion(false, reason)
            default:
                completion(false, "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    private func extractFirstErrorReason(from data: Data) -> String? {
        do {
            let decoder = JSONDecoder()
            let serverError = try decoder.decode(ServerErrorResponse.self, from: data)
            return serverError.errors?.first?.reason ?? serverError.message
        } catch {
            print("Error decoding server error: \(error)")
            return "오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}

extension PortfolioOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PortfolioOnboardingViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentWidth = scrollView.contentSize.width
        let visibleWidth = scrollView.bounds.width
        let contentOffsetX = scrollView.contentOffset.x
        
        let maxOffsetX = contentWidth - visibleWidth
        let indicatorWidth = 45.0
        let indicatorX = contentOffsetX / maxOffsetX * (portfolioOnboardingView.indicatorView.bounds.width - indicatorWidth)
        
        portfolioOnboardingView.indicatorView.trackTintView.snp.remakeConstraints {
            $0.width.equalTo(45)
            $0.top.bottom.height.equalTo(portfolioOnboardingView.indicatorView.trackView)
            $0.leading.equalToSuperview().offset(indicatorX)
            $0.leading.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension PortfolioOnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PortfolioCollectionViewCell.className,
            for: indexPath) as? PortfolioCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.row < portfolioItems.count {
            cell.isFilled = true
            cell.backgroundImageView.image = portfolioItems[indexPath.row]
        } else {
            cell.isFilled = false
            cell.backgroundImageView.image = nil
        }
        
        cell.uploadAction = {
            self.setPortfolio()
        }
        
        cell.cancelAction = {
            self.portfolioItems.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        return cell
    }
}

extension PortfolioOnboardingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let currentCount = portfolioItems.count
        let availableSlots = max(0, 10 - currentCount)
        
        if results.count > availableSlots {
            AlertManager.showAlert(on: self, message: "이미지는 최대 10장까지 업로드 가능합니다.")
            return
        }
        
        let group = DispatchGroup()
        pendingImages.removeAll()
        
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                defer { group.leave() }
                if let image = image as? UIImage {
                    self?.pendingImages.append(image)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self, !self.pendingImages.isEmpty else { return }
            let firstImage = self.pendingImages.removeFirst()
            let cropVC = CropImageViewController()
            cropVC.delegate = self
            cropVC.imagesToCrop = [firstImage]
            self.present(cropVC, animated: true)
        }
    }
}
