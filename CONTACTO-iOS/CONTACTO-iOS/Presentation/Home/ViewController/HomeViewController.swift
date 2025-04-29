//
//  HomeViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class HomeViewController: BaseViewController, HomeAmplitudeSender {
    
    var isFirst = false /// 튜토리얼 필요 유무
    let tutorialImageDummy: [UIImage] = [.imgTutorial1, .imgTutorial2, .imgTutorial3, .imgTutorial4]
    var tutorialNum = 0
    let tutorialView = UIImageView()
    
    var isFromProfile = false /// 프로필에서 돌아왔는지 여부
    var hasCheckedMyPort = false /// 로그인한 사용자 프로필 조회 여부
    
    var isPreview = false /// edit의 preview 여부
    var previewPortfolioData = MyDetailResponseDTO(id: 0, username: "", description: "", instagramId: "", socialId: 0, loginType: "", email: "", nationality: Nationalities.NONE, webUrl: nil, password: "", userPortfolio: UserPortfolio(portfolioId: 0, userId: 0, portfolioImageUrl: []), userPurposes: [], userTalents: []) /// preview의 내 포폴 데이터
    var previewImages: [UIImage] = []
    
    var isUndo = false /// 재선택 동작 여부
    var lastPortfolioUser = PortfoliosResponseDTO(portfolioId: 0, userId: 0, username: "", portfolioImageUrl: []) {
        didSet {
            self.homeView.undoButton.isEnabled = lastPortfolioUser.userId != 0
        }
    }
    
    init(isPreview: Bool){
        super.init(nibName: nil, bundle: nil)
        self.isPreview = isPreview
    }
    
    var isMatch = false /// 매칭 여부
    var chatRoomId = 0
    
    /// 사용자 추천 목록
    let size = 10 /// 받아올 개수
    var recommendedPortfolios: [PortfoliosResponseDTO] = []
    var recommendedPortfolioIdx = 0 /// 현재 보고 있는 유저 위치
    var currentUserId = 0 /// 현재 보고 있는 유저 아이디
    
    var portfolioImages: [String] = []
    var portfolioImageCount = 0 /// 포트폴리오의 총 개수
    var portfolioImageIdx = 0 { /// 현재 보고 있는 포트폴리오 위치
        didSet {
            setPortImage()
            preloadNextImages()
            homeView.pageCollectionView.reloadData()
        }
    }
    
    var isProcessing = false
    var isAnimating = false
    let oldAnchorPoint = CGPoint(x: 0.5, y: 0.5)
    let newAnchorPoint = CGPoint(x: 0.5, y: -0.5)
    lazy var offsetX = self.homeView.portView.bounds.width * (newAnchorPoint.x - oldAnchorPoint.x)
    lazy var offsetY = self.homeView.portView.bounds.height * (newAnchorPoint.y - oldAnchorPoint.y)
    
    let homeView = HomeView()
    let homeEmptyView = HomeEmptyView()
    
    private var imageCache = NSCache<NSString, UIImage>()
    private var preloadingQueue = DispatchQueue(label: "com.contacto.preloading", qos: .userInitiated)
    private var imageLoadingTasks: [DownloadTask] = []
    private var shouldCancelPreloading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setPanAction()
        setTapGesture()
        setCollectionView()
         // 노티피케이션 옵저버 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMatchChatRoom(_:)),
            name: Notification.Name("moveToChatRoomFromMatch"),
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 진행 중인 이미지 로딩 작업 취소
        imageLoadingTasks.forEach { $0.cancel() }
        imageLoadingTasks.removeAll()
        
        // 프리로딩 작업 취소 플래그 설정
        shouldCancelPreloading = true
        
        ImageManager.shared.cancelAllTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        
        // DetailProfileViewController에서 돌아왔을 경우 데이터 재로드하지 않음
        if isFromProfile {
            isFromProfile = false // 플래그 리셋
            return
        }
        if isPreview == false{
            self.sendAmpliLog(eventName: EventName.VIEW_HOME)
        }

        setData()
        
        // 24시간 이내에 팝업을 닫은 적이 있는지 확인
        if let dismissDate = UserDefaults.standard.object(forKey: "PopupDismissDate") as? Date,
           dismissDate > Date() {
            return
        }
        
        // 프로모션 팝업 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let popupView = PromotionPopupView(frame: self.view.bounds)
            self.view.addSubview(popupView)
        }
        
        // 프리로딩 작업 재개를 위해 플래그 초기화
        shouldCancelPreloading = false
        
        ImageManager.shared.resumePreloading()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // 현재 화면에 표시되지 않는 이미지 캐시 삭제
        imageCache.removeAllObjects()
        
        ImageManager.shared.clearCache()
    }
    
    deinit {
        // 진행 중인 이미지 로딩 작업 취소
        imageLoadingTasks.forEach { $0.cancel() }
        imageLoadingTasks.removeAll()
        
        // 캐시 정리
        imageCache.removeAllObjects()
        
        ImageManager.shared.clearAll()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setStyle() {
        super.setStyle()
        
        tutorialView.do {
            $0.image = tutorialImageDummy[tutorialNum]
            $0.isUserInteractionEnabled = true
        }
        
        homeView.do {
            $0.isHidden = true
        }
        
        homeEmptyView.do {
            $0.isHidden = true
        }
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(homeView)
        view.addSubviews(homeEmptyView)
        UIApplication.shared.keyWindow?.addSubviews(tutorialView)
        
        homeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
        
        homeEmptyView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
        
        tutorialView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.center.equalToSuperview()
        }
    }
    
    override func setAddTarget() {
        homeView.noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        homeView.yesButton.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        homeView.profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        homeView.undoButton.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
    }
    
    override func setDelegate() {
        homeView.pageCollectionView.delegate = self
        homeView.pageCollectionView.dataSource = self
    }
    
    private func setPanAction() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        homeView.portView.addGestureRecognizer(panGesture)
    }
    
    private func setTapGesture() {
        let backTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackTap(_:)))
        let nextTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleNextTap(_:)))
        
        homeView.backView.addGestureRecognizer(backTapGestureRecognizer)
        homeView.nextView.addGestureRecognizer(nextTapGestureRecognizer)
        
        if isFirst {
            let tutorialTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tutorialTap(_:)))
            tutorialView.addGestureRecognizer(tutorialTapGestureRecognizer)
            self.sendAmpliLog(eventName: EventName.VIEW_HOME_TUTORIAL)
        } else {
            homeView.isHidden = false
            tutorialView.removeFromSuperview()
        }
    }
    
    private func setCollectionView() {
        homeView.pageCollectionView.register(PageCollectionViewCell.self, forCellWithReuseIdentifier: PageCollectionViewCell.className)
    }
}

extension HomeViewController {
    @objc private func profileButtonTapped() {
        let detailProfileViewController = DetailProfileViewController(from: .home)
        if isPreview {
            detailProfileViewController.portfolioData = self.previewPortfolioData
            detailProfileViewController.imagePreviewDummy = previewImages
        }
        detailProfileViewController.isPreview = self.isPreview
        detailProfileViewController.userId = self.currentUserId
        self.sendAmpliLog(eventName: EventName.CLICK_HOME_PROFILE)
        self.isFromProfile = true
        detailProfileViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailProfileViewController, animated: true)
    }
    
    @objc private func handleBackTap(_ sender: UITapGestureRecognizer) {
        if isPreview {
            if portfolioImageIdx > 0 { portfolioImageIdx -= 1 }
            else { portfolioImageIdx = portfolioImageCount - 1 }
            self.sendAmpliLog(eventName: EventName.CLICK_HOME_BACK)
            return
        }
        
        guard !(recommendedPortfolios.isEmpty), !(portfolioImages.isEmpty) else { return }
        HapticService.impact(.light).run()
        
        if portfolioImageIdx > 0 { portfolioImageIdx -= 1 }
        else { portfolioImageIdx = portfolioImageCount - 1 }
        self.sendAmpliLog(eventName: EventName.CLICK_HOME_BACK)
    }
    
    @objc private func handleNextTap(_ sender: UITapGestureRecognizer) {
        if isPreview {
            if portfolioImageIdx >= portfolioImageCount - 1 { portfolioImageIdx = 0 }
            else { portfolioImageIdx += 1 }
            self.sendAmpliLog(eventName: EventName.CLICK_HOME_NEXT)
            return
        }
        
        guard !(recommendedPortfolios.isEmpty), !(portfolioImages.isEmpty) else { return }
        HapticService.impact(.light).run()
        
        if portfolioImageIdx >= portfolioImageCount - 1 { portfolioImageIdx = 0 }
        else { portfolioImageIdx += 1 }
        self.sendAmpliLog(eventName: EventName.CLICK_HOME_NEXT)
    }
    
    @objc private func tutorialTap(_ sender: UITapGestureRecognizer) {
        if tutorialNum < 4 {
            tutorialView.image = tutorialImageDummy[tutorialNum]
            tutorialNum += 1
        } else if tutorialNum == 4 {
            tutorialView.removeFromSuperview()
            homeView.isHidden = false
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard !isAnimating else { return }
        
        let translation = gesture.translation(in: self.view)
        let xTranslation = translation.x
        let yTranslation = max(translation.y * 0.2, 0)  // Y축 움직임 제한
        let rotationAngle = min(max(xTranslation / self.view.frame.width * 0.8, -0.4), 0.4)  // 회전 각도 제한
        
        switch gesture.state {
        case .began:
            homeView.portView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
        case .changed:
            // 직접적인 변환 적용
            let transform = CGAffineTransform(translationX: xTranslation, y: yTranslation)
                .rotated(by: rotationAngle)
            
            homeView.portView.transform = transform
            
            // 진행 상태에 따라 버튼 강조 표시
            if xTranslation > 0 {
                let alpha = min(abs(xTranslation) / 100, 1.0)
                homeView.noButton.alpha = 1.0
                homeView.yesButton.alpha = 1.0 - (alpha * 0.5)
            } else if xTranslation < 0 {
                let alpha = min(abs(xTranslation) / 100, 1.0)
                homeView.yesButton.alpha = 1.0
                homeView.noButton.alpha = 1.0 - (alpha * 0.5)
            } else {
                homeView.noButton.alpha = 1.0
                homeView.yesButton.alpha = 1.0
            }
            
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: self.view)
            let shouldDismiss = (abs(xTranslation) > self.view.frame.width * 0.35) || (abs(velocity.x) > 800)
            
            if shouldDismiss {
                // 카드를 화면 밖으로 애니메이션
                let directionMultiplier: CGFloat = xTranslation > 0 ? 1 : -1
                let throwDistance: CGFloat = directionMultiplier * 2 * self.view.frame.width
                let finalTransform = CGAffineTransform(translationX: throwDistance, y: 100)
                    .rotated(by: directionMultiplier * 0.5)
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.homeView.portView.transform = finalTransform
                    // 버튼 알파값 원래대로
                    self.homeView.yesButton.alpha = 1.0
                    self.homeView.noButton.alpha = 1.0
                }, completion: { _ in
                    // 스와이프 방향에 따라 좋아요/싫어요 처리
                    if xTranslation > 0 {
                        self.yesButtonTapped()
                    } else {
                        self.noButtonTapped()
                    }
                })
            } else {
                // 원래 위치로 돌아가기
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.homeView.portView.transform = .identity
                    self.homeView.yesButton.alpha = 1.0
                    self.homeView.noButton.alpha = 1.0
                })
            }
        default:
            break
        }
    }

    @objc private func handleMatchChatRoom(_ notification: Notification) {
        if let message = notification.userInfo?["message"] as? String,
           let chatRoomId = notification.userInfo?["chatRoomId"] as? Int,
           let yourId = notification.userInfo?["yourId"] as? Int,
           let yourImageURL = notification.userInfo?["yourImageURL"] as? String,
           let yourLabel = notification.userInfo?["yourLabel"] as? String {
            
            let chatRoomViewController = ChatRoomViewController()
            chatRoomViewController.chatRoomId = chatRoomId
            chatRoomViewController.otherUserId = yourId
            chatRoomViewController.chatRoomThumbnail = yourImageURL
            chatRoomViewController.chatRoomTitle = yourLabel
            chatRoomViewController.content = message
            chatRoomViewController.isFirstMatch = true
            chatRoomViewController.hidesBottomBarWhenPushed = true
            
            // 채팅방 뷰컨트롤러를 userInfo에 포함시켜 전달
            NotificationCenter.default.post(
                name: Notification.Name("moveToChat"),
                object: nil,
                userInfo: ["chatRoomViewController": chatRoomViewController]
            )
        }
    }
    
    private func setData() {
        homeView.undoButton.isEnabled = false
        if !isPreview {
            if !hasCheckedMyPort {
                checkMyPort()
                hasCheckedMyPort = true
            }
            homeList { _ in
                if self.recommendedPortfolios.count == 0 {
                    self.homeView.isHidden = true
                    self.homeEmptyView.isHidden = false
                    self.sendAmpliLog(eventName: EventName.VIEW_EMPTY)
                    return
                }
                self.recommendedPortfolioIdx = 0
                self.portfolioImageIdx = 0
                self.setProfile()
            }
        } else {
            homeView.profileNameLabel.text = previewPortfolioData.username
            portfolioImageCount = previewPortfolioData.userPortfolio?.portfolioImageUrl.count ?? 0
            portfolioImageIdx = 0
            homeView.isHidden = false
            homeEmptyView.isHidden = true
            setPortImage()
            homeView.pageCollectionView.reloadData()
            self.sendAmpliLog(eventName: EventName.VIEW_PREVIEW)
            return
        }
    }
    
    private func setProfile() {
        self.homeView.isHidden = false
        self.homeEmptyView.isHidden = true
        if !isPreview {
            if !isUndo {
                if recommendedPortfolioIdx >= recommendedPortfolios.count {
                    homeList { _ in
                        if self.recommendedPortfolios.count == 0 {
                            self.homeView.isHidden = true
                            self.homeEmptyView.isHidden = false
                            self.sendAmpliLog(eventName: EventName.VIEW_HOME_EMPTY)
                            return
                        }
                    }
                    self.recommendedPortfolioIdx = 0
                }
                self.currentUserId = Int(recommendedPortfolios[recommendedPortfolioIdx].userId)
                self.homeView.profileNameLabel.text = recommendedPortfolios[recommendedPortfolioIdx].username
                self.portfolioImages = recommendedPortfolios[recommendedPortfolioIdx].portfolioImageUrl
            } else {
                self.currentUserId = Int(lastPortfolioUser.userId)
                self.homeView.profileNameLabel.text = lastPortfolioUser.username
                self.portfolioImages = lastPortfolioUser.portfolioImageUrl
            }
        }
        self.portfolioImageCount = portfolioImages.count
        self.portfolioImageIdx = 0
        self.homeView.pageCollectionView.reloadData()
    }
    
    private func setPortImage() {
        if !isPreview {
            if portfolioImageIdx < portfolioImageCount {
                let imageUrl = portfolioImages[portfolioImageIdx]
                ImageManager.shared.loadImage(url: imageUrl, into: homeView.portImageView)
            }
        } else {
            if portfolioImageIdx < portfolioImageCount {
                homeView.portImageView.image = previewImages[portfolioImageIdx]
            }
        }
    }
    
    private func preloadNextImages() {
        guard !isPreview, portfolioImageCount > 0 else { return }
        ImageManager.shared.preloadImages(urls: portfolioImages, startIndex: portfolioImageIdx)
    }
    
    private func homeList(completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.homeList { [weak self] response in
            switch response {
            case .success(let data):
                self?.recommendedPortfolios = data
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    private func likeOrDislike(bodyDTO: LikeRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.likeOrDislike(bodyDTO: bodyDTO) { [weak self] response in
            switch response {
            case .success(let data):
                self?.isMatch = data.matched
                self?.chatRoomId = data.chatRoomId ?? 0
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    private func checkMyPort() {
        NetworkService.shared.editService.checkMyPort { [weak self] response in
            switch response {
            case .success(let data):
                self?.previewPortfolioData = data
                KeychainHandler.shared.userName = data.username
                KeychainHandler.shared.userID = String(data.id)
                UserIdentityManager.myDetailProperty(data: data)

            default:
                #if DEBUG
                print("내 포트폴리오 데이터를 가져오지 못함")
                #endif
            }
        }
    }
    
    @objc private func yesButtonTapped() {
        guard !isProcessing else { return }
        if !isPreview {
            guard !(recommendedPortfolios.isEmpty) else { return }
            isProcessing = true
            
            if !isUndo {
                lastPortfolioUser = recommendedPortfolios[recommendedPortfolioIdx]
            }
            
            // UI 업데이트를 즉시 수행
            self.animateImage(status: true)
            
            // 백그라운드에서 네트워크 요청 처리
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                likeOrDislike(bodyDTO: LikeRequestBodyDTO(likedUserId: currentUserId, status: LikeStatus.like.rawValue)) { _ in
                    if self.isMatch {
                        DispatchQueue.main.async {
                            self.pushToMatch()
                        }
                    }
                }
            }
            
            UserIdentityManager.homeYes()
            self.sendAmpliLog(eventName: EventName.CLICK_HOME_YES)
        } else {
            isProcessing = true
            self.animateImage(status: true)
        }
    }
    
    @objc private func noButtonTapped() {
        guard !isProcessing else { return }
        if !isPreview {
            guard !(recommendedPortfolios.isEmpty) else { return }
            isProcessing = true
            
            if !isUndo {
                lastPortfolioUser = recommendedPortfolios[recommendedPortfolioIdx]
            }
            
            // UI 업데이트를 즉시 수행
            self.animateImage(status: false)
            
            // 백그라운드에서 네트워크 요청 처리
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                likeOrDislike(bodyDTO: LikeRequestBodyDTO(likedUserId: currentUserId, status: LikeStatus.dislike.rawValue)) { _ in
                    if self.isMatch {
                        DispatchQueue.main.async {
                            self.pushToMatch()
                        }
                    }
                }
            }
            
            UserIdentityManager.homeNo()
            self.sendAmpliLog(eventName: EventName.CLICK_HOME_NO)
        } else {
            isProcessing = true
            self.animateImage(status: false)
        }
    }
    
    @objc private func undoButtonTapped() {
        guard !isProcessing else { return }
        if !isPreview {
            guard !(recommendedPortfolios.isEmpty) else { return }
            isProcessing = true
            
            isUndo = true
            self.animateImage(status: false)
            self.sendAmpliLog(eventName: EventName.CLICK_HOME_REVERT)
        } else {
            // 프리뷰 모드에서는 undo 동작 없음
            return
        }
    }
    
    private func animateImage(status: Bool) {
        guard !isAnimating else { return }
        isAnimating = true
        
        HapticService.impact(.heavy).run()
        
        // 버튼을 통한 선택 시 카드 애니메이션
        let directionMultiplier: CGFloat = status ? 1 : -1
        let throwDistance: CGFloat = directionMultiplier * 1.5 * self.view.frame.width
        let finalTransform = CGAffineTransform(translationX: throwDistance, y: 100)
            .rotated(by: directionMultiplier * 0.5)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.homeView.portView.transform = finalTransform
        }, completion: { _ in
            // 다음 카드를 위한 초기화
            self.homeView.portView.transform = .identity
            
            if self.isPreview {
                // 프리뷰인 경우 애니메이션 이후 다시 초기 상태로만 돌리고 종료
                self.isAnimating = false
                self.isProcessing = false
                return
            }
            
            if !self.isUndo {
                self.recommendedPortfolioIdx += 1
                self.setProfile()
            } else {
                // 되돌리기 시 이전 프로필 복원
                self.recommendedPortfolioIdx = max(0, self.recommendedPortfolioIdx - 1)
                self.currentUserId = Int(self.recommendedPortfolios[self.recommendedPortfolioIdx].userId)
                self.homeView.profileNameLabel.text = self.recommendedPortfolios[self.recommendedPortfolioIdx].username
                self.portfolioImages = self.recommendedPortfolios[self.recommendedPortfolioIdx].portfolioImageUrl
                self.portfolioImageCount = self.portfolioImages.count
                self.portfolioImageIdx = 0
                self.setPortImage()
                self.homeView.pageCollectionView.reloadData()
            }
            
            self.isMatch = false
            if self.isUndo {
                self.lastPortfolioUser = PortfoliosResponseDTO(portfolioId: 0, userId: 0, username: "", portfolioImageUrl: [])
            }
            self.isUndo = false
            self.isAnimating = false
            self.isProcessing = false
        })
    }
    
    /// 쌍 방 매칭 되었을 때
    private func pushToMatch() {
        if self.isMatch, !self.isPreview {
            HapticService.notification(.error).run()
            
            let matchViewController = MatchViewController()
            matchViewController.modalPresentationStyle = .overFullScreen
            matchViewController.modalTransitionStyle = .crossDissolve
            matchViewController.modalPresentationCapturesStatusBarAppearance = false
            
            matchViewController.matchData = Match(
                myId: previewPortfolioData.id,
                myLabel: previewPortfolioData.username,
                myImageURL: previewPortfolioData.userPortfolio?.portfolioImageUrl.first ?? "",
                yourId: recommendedPortfolios[recommendedPortfolioIdx].userId,
                yourLabel: recommendedPortfolios[recommendedPortfolioIdx].username,
                yourImageURL: recommendedPortfolios[recommendedPortfolioIdx].portfolioImageUrl.first ?? "",
                chatRoomId: chatRoomId
            )
            UserIdentityManager.chatroom()
            self.present(matchViewController, animated: true)
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate { }

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return portfolioImageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PageCollectionViewCell.className,
            for: indexPath) as? PageCollectionViewCell else { return UICollectionViewCell() }
        if (indexPath.row == self.portfolioImageIdx) {
            cell.selectedView()
        } else {
            cell.unselectedView()
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalItems = portfolioImageCount
        
        let collectionViewWidth = collectionView.frame.width
        let spacing: CGFloat = 5.adjustedWidth
        
        let cellWidth = (collectionViewWidth - CGFloat(totalItems - 1) * spacing) / CGFloat(totalItems)
        return CGSize(width: cellWidth, height: 2)
    }
}
