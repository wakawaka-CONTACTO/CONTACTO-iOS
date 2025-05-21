//
//  DetailProfileViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class DetailProfileViewController: BaseViewController, DetailAmplitudeSender {
    
    enum From {
        case home
        case chatroom
    }
    
    private var from: From = .home
    
    convenience init(from: From) {
        self.init()
        self.from = from
    }
    
    var imageArray: [String] = []
    var imagePreviewDummy: [UIImage] = []
    var currentNum = 0 {
        didSet {
            detailProfileView.pageCollectionView.reloadData()
        }
    }
    var userId = 0
    var isPreview = false
    var isFromChat = false
    
    let detailProfileView = DetailProfileView()
    var portfolioData = MyDetailResponseDTO(id: 0, username: "", description: "", instagramId: "", socialId: 0, loginType: "", email: "", nationality: Nationalities.NONE, webUrl: nil, password: "", userPortfolio: UserPortfolio(portfolioId: 0, userId: 0, portfolioImageUrl: []), userPurposes: [], userTalents: [])
    private var talentData: [TalentInfo] = []
    private var lastScrollLogTime: Date?
    private let scrollLogInterval: TimeInterval = 3.0
    private var isInitializing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setData()
        self.sendAmpliLog(eventName: EventName.VIEW_DETAIL, properties: ["from": from == .home ? "home" : "chatroom"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sendAmpliLog(eventName: EventName.CLICK_DETAIL_CANCEL)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isInitializing = false
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        view.addSubviews(detailProfileView)

        detailProfileView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            
            if isFromChat {
                $0.bottom.leading.trailing.equalToSuperview()
            } else {
                let safeAreaHeight = view.safeAreaInsets.bottom
                let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
                $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
            }
        }
    }
    
    override func setAddTarget() {
        detailProfileView.popButton.addTarget(self, action: #selector(popButtonTapped), for: .touchUpInside)
        detailProfileView.instaButton.addTarget(self, action: #selector(instaButtonTapped), for: .touchUpInside)
        detailProfileView.webButton.addTarget(self, action: #selector(webButtonTapped), for: .touchUpInside)
        detailProfileView.blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        detailProfileView.reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    override func setDelegate() {
        detailProfileView.portImageCollectionView.delegate = self
        detailProfileView.portImageCollectionView.dataSource = self
        detailProfileView.pageCollectionView.delegate = self
        detailProfileView.pageCollectionView.dataSource = self
        detailProfileView.talentCollectionView.delegate = self
        detailProfileView.talentCollectionView.dataSource = self
        detailProfileView.purposeCollectionView.delegate = self
        detailProfileView.purposeCollectionView.dataSource = self
        detailProfileView.scrollView.delegate = self
    }
    
    private func setCollectionView() {
        detailProfileView.talentCollectionView.register(ProfileTalentCollectionViewCell.self, forCellWithReuseIdentifier: ProfileTalentCollectionViewCell.className)
        detailProfileView.purposeCollectionView.register(ProfilePurposeCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePurposeCollectionViewCell.className)
        detailProfileView.portImageCollectionView.register(ProfileImageCollectionViewCell.self, forCellWithReuseIdentifier: ProfileImageCollectionViewCell.className)
        detailProfileView.pageCollectionView.register(PageCollectionViewCell.self, forCellWithReuseIdentifier: PageCollectionViewCell.className)
    }
    
    // MARK: - Server Function
    private func detailPort(userId: Int, completion: @escaping (Bool) -> Void) {
        if isPreview {
            handlePreviewMode()
            completion(true)
            return
        }
        
        NetworkService.shared.homeService.detailPort(userId: userId) { [weak self] response in
            guard let self = self else {
                completion(false)
                return
            }
            
            switch response {
            case .success(let data):
                self.handleSuccess(data: data)
                completion(true)
            case .failure(let error):
                self.handleFailure(error: error)
                completion(false)
            default:
                completion(false)
            }
        }
    }
    
    private func handlePreviewMode() {
        detailProfileView.hideSkeleton()
        updatePortfolio()
    }
    
    private func handleSuccess(data: MyDetailResponseDTO) {
        portfolioData = data
        updatePortfolio()
    }
    
    private func handleFailure(error: NetworkError) {
        if error.statusCode == 404 {
            showUserNotFoundAlert()
        }
    }
    
    private func showUserNotFoundAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: StringLiterals.Chat.Profile.notFoundUserTitle,
                message: StringLiterals.Chat.Profile.notFoundUserDesc,
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            
            alert.addAction(okAction)
            self?.present(alert, animated: true)
        }
    }
    
    private func blockUser(blockedUserId: Int, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.blockUser(blockedUserId: portfolioData.id) { response in
            switch response {
            case .success(let data):
                print(data)
                completion(true)
            default:
                completion(false)
                print("error")
            
            }
        }
    }
    
    private func reportUser(bodyDTO: ReportRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.reportUser(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
                print(data)
                completion(true)
            default:
                completion(false)
                print("error")
            
            }
        }
    }
    
    private func setData() {
        if isPreview {
            self.detailProfileView.blockButton.isEnabled = false
            self.detailProfileView.reportButton.isEnabled = false
        }
        // 데이터 로딩 시작 시 스켈레톤 효과 표시
        detailProfileView.showSkeleton()
        
        detailPort(userId: userId) { [weak self] success in
            guard let self = self else { return }
            // 데이터 로딩 완료 시 스켈레톤 효과 숨김
            self.detailProfileView.hideSkeleton()
        }
    }
    
    private func updatePortfolio() {
        self.talentData = self.portfolioData.userTalents.compactMap { userTalent in
            if self.isPreview {
                return Talent.allCases.first(where: { $0.info.displayName == userTalent.talentType })?.info
            } else {
                return Talent.allCases.first(where: { $0.info.koreanName == userTalent.talentType })?.info
            }
        }
        
        if !isPreview {
            self.imageArray = portfolioData.userPortfolio?.portfolioImageUrl ?? []
            self.detailProfileView.portImageCollectionView.reloadData()
            self.detailProfileView.pageCollectionView.reloadData()
        }
        
        self.detailProfileView.nameLabel.text = self.portfolioData.username
        self.detailProfileView.nationalityLabel.text = self.portfolioData.nationality.displayName
        self.detailProfileView.descriptionLabel.text = self.portfolioData.description
        if let webUrl = self.portfolioData.webUrl, !webUrl.isEmpty {
            self.detailProfileView.webButton.isHidden = false
        } else {
            self.detailProfileView.webButton.isHidden = true
        }
        
        self.detailProfileView.talentCollectionView.reloadData()
        self.detailProfileView.purposeCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.resetCollectionViewLayout()
        }
    }
    
    private func resetCollectionViewLayout() {
        self.detailProfileView.talentCollectionView.layoutIfNeeded()
        self.detailProfileView.purposeCollectionView.layoutIfNeeded()
        
        let talentHeight = self.detailProfileView.talentCollectionView.collectionViewLayout.collectionViewContentSize.height
        self.detailProfileView.talentCollectionView.snp.remakeConstraints {
            $0.top.equalTo(self.detailProfileView.nationalityLabel.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(talentHeight + 10)
        }
        
        self.detailProfileView.purposeCollectionView.snp.remakeConstraints {
            $0.top.equalTo(self.detailProfileView.purposeLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(self.detailProfileView.purposeCollectionView.contentSize.height)
        }
    }
    
    @objc private func instaButtonTapped() {
        let id = portfolioData.instagramId
        let url = URL(string: "https://www.instagram.com/\(id)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        self.sendAmpliLog(eventName: EventName.CLICK_DETAIL_INSTA)
    }
    
    // MARK: - URL Handling
    private enum URLValidationError: Error {
        case invalidURL
        case invalidScheme
        
        var message: String {
            switch self {
            case .invalidURL:
                return "유효하지 않은 URL입니다."
            case .invalidScheme:
                return "지원하지 않는 URL 형식입니다."
            }
        }
    }
    
    private func validateAndOpenURL(_ urlString: String?) {
        do {
            let url = try createValidURL(from: urlString)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.sendAmpliLog(eventName: EventName.CLICK_DETAIL_WEB)
        } catch let error as URLValidationError {
            showAlert(
                title: "에러",
                message: error.message,
                actions: [UIAlertAction(title: "확인", style: .default)]
            )
        } catch {
            showAlert(
                title: "에러",
                message: "알 수 없는 오류가 발생했습니다.",
                actions: [UIAlertAction(title: "확인", style: .default)]
            )
        }
    }
    
    private func createValidURL(from urlString: String?) throws -> URL {
        guard let urlString = urlString, !urlString.isEmpty else {
            throw URLValidationError.invalidURL
        }
        
        // URL이 이미 http:// 또는 https://로 시작하는지 확인
        if let url = URL(string: urlString), ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            return url
        }
        
        // URL이 스키마를 포함하지 않는 경우 https:// 추가
        guard let url = URL(string: "https://\(urlString)") else {
            throw URLValidationError.invalidURL
        }
        
        return url
    }
    
    @objc private func webButtonTapped() {
        validateAndOpenURL(portfolioData.webUrl)
    }
    
    @objc private func popButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Alert Handling
    private func showAlert(title: String?, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    private func showActionSheet(title: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    private func handleBlockSuccess() {
        let successAlert = UIAlertController(
            title: nil,
            message: StringLiterals.Home.Block.result,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        successAlert.addAction(okAction)
        present(successAlert, animated: true)
    }
    
    private func handleBlockFailure() {
        showAlert(
            title: "Error",
            message: "사용자 차단에 실패했습니다.",
            actions: [UIAlertAction(title: "OK", style: .default)]
        )
    }
    
    private func handleReportSuccess() {
        showAlert(
            title: nil,
            message: StringLiterals.Home.Report.result,
            actions: [UIAlertAction(title: "OK", style: .default)]
        )
    }
    
    private func handleReportFailure() {
        showAlert(
            title: "Error",
            message: "신고 처리에 실패했습니다.",
            actions: [UIAlertAction(title: "OK", style: .default)]
        )
    }
    
    @objc private func blockButtonTapped() {
        guard !isPreview else { return }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.sendAmpliLog(eventName: EventName.CLICK_DETAIL_BLOCK_NO)
        }
        
        let blockAction = UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.sendAmpliLog(eventName: EventName.CLICK_DETAIL_BLOCK_YES)
            
            self.blockUser(blockedUserId: self.portfolioData.id) { success in
                DispatchQueue.main.async {
                    if success {
                        self.handleBlockSuccess()
                    } else {
                        self.handleBlockFailure()
                    }
                }
            }
        }
        
        showAlert(
            title: StringLiterals.Home.Block.title,
            message: StringLiterals.Home.Block.message,
            actions: [blockAction, cancelAction]
        )
    }
    
    @objc private func reportButtonTapped() {
        let reportActions = StringLiterals.Home.Report.ReportReasons.allCases.enumerated().map { index, reason in
            UIAlertAction(title: reason, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.sendAmpliLog(eventName: EventName.CLICK_DETAIL_REPORT_YES, properties: ["report_name": reason])
                
                self.reportUser(bodyDTO: ReportRequestBodyDTO(reportedUserId: self.portfolioData.id, reportReasonIdx: index)) { success in
                    DispatchQueue.main.async {
                        if success {
                            self.handleReportSuccess()
                        } else {
                            self.handleReportFailure()
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.sendAmpliLog(eventName: EventName.CLICK_DETAIL_REPORT_NO)
        }
        
        showActionSheet(
            title: StringLiterals.Home.Report.title,
            actions: reportActions + [cancelAction]
        )
    }
    
    // MARK: - Image Handling
    private func loadImagesFromURLs(_ urls: [String], completion: @escaping ([UIImage]) -> Void) {
        var uiImages: [UIImage?] = Array(repeating: nil, count: urls.count)
        let group = DispatchGroup()
        
        for (i, urlStr) in urls.enumerated() {
            guard let url = URL(string: urlStr) else { continue }
            group.enter()
            
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    uiImages[i] = value.image
                case .failure:
                    uiImages[i] = UIImage()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let validImages = uiImages.compactMap { $0 }
            completion(validImages)
        }
    }
    
    private func handleImageTap(at index: Int) {
        if isPreview {
            presentFullscreenImageViewer(images: imagePreviewDummy, startIndex: index)
        } else {
            // 먼저 빈 이미지 배열로 뷰어를 표시
            let emptyImages = Array(repeating: UIImage(), count: imageArray.count)
            let fullscreenVC = FullscreenImagePagingViewController()
            fullscreenVC.modalPresentationStyle = .fullScreen
            fullscreenVC.images = emptyImages
            fullscreenVC.startIndex = index
            fullscreenVC.isLoading = true
            self.navigationController?.pushViewController(fullscreenVC, animated: true)
            
            // 이미지 로딩 시작
            loadImagesFromURLs(imageArray) { [weak fullscreenVC] images in
                guard let fullscreenVC = fullscreenVC else { return }
                DispatchQueue.main.async {
                    fullscreenVC.images = images
                    fullscreenVC.isLoading = false
                    fullscreenVC.reloadImages()
                }
            }
        }
    }
    
    @objc private func imageTapped(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view,
              let index = imageView.tag as Int? else { return }
        handleImageTap(at: index)
    }
}

extension DetailProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == detailProfileView.portImageCollectionView else { return }

        handleImageTap(at: indexPath.row)
    }
}

extension DetailProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0, 1:
            return isPreview ? imagePreviewDummy.count : imageArray.count
        case 2:
            return talentData.count
        case 3:
            return portfolioData.userPurposes.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileImageCollectionViewCell.className,
                for: indexPath) as? ProfileImageCollectionViewCell else { return UICollectionViewCell() }

            if !isPreview {
                cell.portImageView.kfSetImage(url: imageArray[indexPath.row], width: Int(SizeLiterals.Screen.screenWidth))
            } else {
                cell.portImageView.image = imagePreviewDummy[indexPath.row]
            }

            // 탭 제스처 추가
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            cell.portImageView.isUserInteractionEnabled = true
            cell.portImageView.addGestureRecognizer(tapGesture)
            cell.portImageView.tag = indexPath.row

            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PageCollectionViewCell.className,
                for: indexPath) as? PageCollectionViewCell else { return UICollectionViewCell() }
            if indexPath.row == currentNum {
                cell.selectedView()
            } else {
                cell.unselectedView()
            }
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileTalentCollectionViewCell.className,
                for: indexPath) as? ProfileTalentCollectionViewCell else { return UICollectionViewCell() }
            
            cell.talentLabel.text = talentData[indexPath.row].displayName.uppercased()
            cell.backgroundColor = talentData[indexPath.row].category.color
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfilePurposeCollectionViewCell.className,
                for: indexPath) as? ProfilePurposeCollectionViewCell else { return UICollectionViewCell() }
            cell.isTapped = true
            cell.config(purpose: ProfilePurpose.allCases[isPreview ? portfolioData.userPurposes[indexPath.row] : portfolioData.userPurposes[indexPath.row]])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
extension DetailProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView.tag {
        case 0:
            return CGSize(width: SizeLiterals.Screen.screenWidth, height: 432)
        case 1:
            let totalItems = isPreview ? imagePreviewDummy.count : imageArray.count
            
            let collectionViewWidth = SizeLiterals.Screen.screenWidth - 34.adjustedWidth
            let spacing: CGFloat = 5.adjustedWidth
            
            let cellWidth = (collectionViewWidth - CGFloat(totalItems - 1) * spacing) / CGFloat(totalItems)
            return CGSize(width: cellWidth, height: collectionView.frame.height)
        case 2:
            let talent = talentData[indexPath.row].displayName.uppercased()
            let font = UIFont.systemFont(ofSize: 12, weight: .medium)
            let attributes = [NSAttributedString.Key.font: font]
            let textSize = (talent as NSString).size(withAttributes: attributes)
            return CGSize(width: textSize.width + 16, height: 19)
        case 3:
            return CGSize(width: 168.adjustedWidth, height: 28)
        default:
            return .zero
        }
    }
}

extension DetailProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView, collectionView.tag == 0 {
            let pageWidth = scrollView.frame.width
            let currentPage = Int(scrollView.contentOffset.x / pageWidth)
            currentNum = currentPage
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isInitializing { return }
        let currentTime = Date()
        if lastScrollLogTime == nil || currentTime.timeIntervalSince(lastScrollLogTime!) >= scrollLogInterval {
            self.sendAmpliLog(eventName: EventName.SCROLL_DETAIL)
            lastScrollLogTime = currentTime
        }
    }
}

extension DetailProfileViewController {
    func presentFullscreenImageViewer(images: [UIImage], startIndex: Int) {
        let fullscreenVC = FullscreenImagePagingViewController()
        fullscreenVC.modalPresentationStyle = .fullScreen
        fullscreenVC.images = images
        fullscreenVC.startIndex = startIndex
        self.navigationController?.pushViewController(fullscreenVC, animated: true)
    }
}
