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

final class HomeViewController: BaseViewController {
    
    var isFirst = false /// 튜토리얼 필요 유무
    var isPreview = false /// edit의 preview인지
    var portUserId = 0 /// 현재 보고 있는 유저의 id
    var isMatch = false /// 지금 매칭이 되었는지 response
    var num = 0 { /// 현재 보고 있는 포트폴리오가 몇 번째 장인지 (0부터)
        didSet {
            homeView.pageCollectionView.reloadData()
            setPortImage()
        }
    }
    var maxNum = 0 /// 포트폴리오의 총 장 수 (1장부터)
    var isAnimating = false
    
    /// 현재 포폴이 리스트의 몇 번째인지
    var nowCount = 0 {
        didSet {
            setData()
        }
    }
    var portfolioData: [PortfoliosResponseDTO] = []
    
    /// preview의 내 포폴 데이터
    var previewPortfolioData = MyDetailResponseDTO(id: 0, username: "", description: "", instagramId: "", socialId: 0, loginType: "", email: "", webUrl: nil, password: "", userPortfolio: UserPortfolio(portfolioId: 0, userId: 0, portfolioImages: []), userPurposes: [], userTalents: [])

    let oldAnchorPoint = CGPoint(x: 0.5, y: 0.5)
    let newAnchorPoint = CGPoint(x: 0.5, y: -0.5)
    lazy var offsetX = self.homeView.portView.bounds.width * (newAnchorPoint.x - oldAnchorPoint.x)
    lazy var offsetY = self.homeView.portView.bounds.height * (newAnchorPoint.y - oldAnchorPoint.y)
    
    var imageDummy: [UIImage] = []
    let homeView = HomeView()
    let homeEmptyView = HomeEmptyView()
    
    let tutorialImageDummy: [UIImage] = [.imgTutorial1, .imgTutorial2, .imgTutorial3, .imgTutorial4]
    var tutorialNum = 0
    let tutorialView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPanAction()
        setTapGesture()
        setCollectionView()
        setPortImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        setData()
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
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(homeView)
        UIApplication.shared.keyWindow?.addSubviews(tutorialView)
        
        homeView.snp.makeConstraints {
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
        let detailProfileViewController = DetailProfileViewController()
        detailProfileViewController.portfolioData = self.previewPortfolioData
        detailProfileViewController.imageArray = self.imageDummy
        detailProfileViewController.isPreview = self.isPreview
        detailProfileViewController.userId = self.portUserId
        self.navigationController?.pushViewController(detailProfileViewController, animated: true)
    }
    
    @objc private func handleBackTap(_ sender: UITapGestureRecognizer) {
        HapticService.impact(.light).run()
        
        if num == 0 {
            num = maxNum
        } else {
            num -= 1
        }
    }
    
    @objc private func handleNextTap(_ sender: UITapGestureRecognizer) {
        HapticService.impact(.light).run()
        
        if num == maxNum {
            num = 0
        } else {
            num += 1
        }
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
        
        let translation = gesture.translation(in: self.homeView.portView)
        var transform = CGAffineTransform(translationX: offsetX, y: offsetY)
        let rotationAngle = -translation.x * .pi / (180 * 10)
        
        self.homeView.portView.layer.anchorPoint = CGPoint(x: 0.5, y: -0.5)
        transform = transform.rotated(by: rotationAngle)
        self.homeView.portView.transform = transform
        
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: self.view)
            if velocity.x > 500 {
                yesButtonTapped()
            } else if velocity.x < -500 {
                noButtonTapped()
            } else {
                if rotationAngle < -0.1 {
                    yesButtonTapped()
                } else if rotationAngle > 0.1 {
                    noButtonTapped()
                } else {
                    UIView.animate(withDuration: 1) {
                        self.homeView.portView.layer.anchorPoint = self.oldAnchorPoint
                        self.homeView.portView.transform = .identity
                    }
                }
            }
        }
    }
    
    private func setData() {
        if !isPreview {
            homeList { _ in
                self.maxNum = self.imageDummy.count - 1
                self.setNewPortfolio()
            }
        } else {
            homeView.profileNameLabel.text = previewPortfolioData.username
            maxNum = imageDummy.count - 1
        }
    }
    
    private func setPortImage() {
        if num < imageDummy.count {
            homeView.portImageView.image = imageDummy[self.num]
        }
    }
    
    private func homeList(completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.homeList { [weak self] response in
            switch response {
            case .success(let data):
                self?.portfolioData = data
                print(data)
                completion(true)
            default:
                completion(false)
                print("error")
            }
        }
    }
    
    private func likeOrDislike(bodyDTO: LikeRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.likeOrDislike(bodyDTO: bodyDTO) { [weak self] response in
            switch response {
            case .success(let data):
                print(data)
                self?.isMatch = data.matched
                completion(true)
            default:
                completion(false)
                print("error")
            }
        }
    }
    
    @objc private func yesButtonTapped() {
        if !isPreview {
            likeOrDislike(bodyDTO: LikeRequestBodyDTO(likedUserId: portUserId, status: LikeStatus.like.rawValue)) { _ in
                self.animateImage(status: true)
            }
        } else {
            self.animateImage(status: true)
        }
    }
    
    @objc private func noButtonTapped() {
        if !isPreview {
            likeOrDislike(bodyDTO: LikeRequestBodyDTO(likedUserId: portUserId, status: LikeStatus.dislike.rawValue)) { _ in
                self.animateImage(status: false)
            }
        } else {
            self.animateImage(status: false)
        }
    }
    
    private func animateImage(status: Bool) {
        guard !isAnimating else { return }  // 애니메이션 중이면 함수 실행 중단
        isAnimating = true
        
        HapticService.impact(.heavy).run()
        
        var transform = CGAffineTransform(translationX: offsetX, y: offsetY)
        
        UIView.animate(withDuration: 1) {
            transform = transform.rotated(by: status ? -(CGFloat.pi * 0.5) : (CGFloat.pi * 0.5))
            self.homeView.portView.layer.anchorPoint = self.newAnchorPoint
            self.homeView.portView.transform = transform
        } completion: { _ in
            // 추후 쌍방 매칭 됐을 때로 변경, 강한 햅틱 추가
            self.pushToMatch()
            
            self.homeView.portView.layer.anchorPoint = self.oldAnchorPoint
            self.homeView.portView.transform = .identity
            self.num = 0
            self.isAnimating = false
            self.isMatch = false
            self.nowCount += 1
        }
    }
    
    /// 쌍 방 매칭 되었을 때
    private func pushToMatch() {
        if self.isMatch, !self.isPreview {
            HapticService.notification(.error).run()
            
            let matchViewController = MatchViewController()
            matchViewController.modalPresentationStyle = .overFullScreen
            matchViewController.modalTransitionStyle = .crossDissolve
            matchViewController.modalPresentationCapturesStatusBarAppearance = false
            self.present(matchViewController, animated: true)
        }
    }
    
    /// 새 포트폴리오(다음 사람)로 넘길 때
    private func setNewPortfolio() {
        if self.nowCount < self.portfolioData.count {
            self.homeView.isHidden = false
            self.homeEmptyView.isHidden = true
            self.portUserId = Int(portfolioData[nowCount].userId)
            self.homeView.profileNameLabel.text = portfolioData[nowCount].username
            let dispatchGroup = DispatchGroup()
            
            portfolioData[nowCount].portfolioImages.forEach { url in
                guard let imageUrl = URL(string: url) else { return }
                
                dispatchGroup.enter() // 작업 시작
                KingfisherManager.shared.downloader.downloadImage(with: imageUrl) { [weak self] result in
                    switch result {
                    case .success(let value):
                        DispatchQueue.main.async {
                            let images = [value.image]
                            self?.imageDummy = images
                        }
                    case .failure(let error):
                        print("Failed to load image: \(error.localizedDescription)")
                    }
                    dispatchGroup.leave() // 작업 완료
                }
            }
            
            dispatchGroup.notify(queue: .main) {

            }
            
        } else {
            self.homeView.isHidden = true
            self.homeEmptyView.isHidden = false
        }
    }
}

extension HomeViewController: UICollectionViewDelegate { }

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxNum + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PageCollectionViewCell.className,
            for: indexPath) as? PageCollectionViewCell else { return UICollectionViewCell() }
        if (indexPath.row == self.num) {
            cell.selectedView()
        } else {
            cell.unselectedView()
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalItems = maxNum + 1
        
        let collectionViewWidth = collectionView.frame.width
        let spacing: CGFloat = 5.adjustedWidth
        
        let cellWidth = (collectionViewWidth - CGFloat(totalItems - 1) * spacing) / CGFloat(totalItems)
        return CGSize(width: cellWidth, height: 2)
    }
}
