//
//  HomeViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit

import SnapKit
import Then

final class HomeViewController: BaseViewController {
    
    var num = 0 {
        didSet {
            homeView.pageCollectionView.reloadData()
            setPortImage()
        }
    }
    var maxNum = 0
    var isAnimating = false
    
    let oldAnchorPoint = CGPoint(x: 0.5, y: 0.5)
    let newAnchorPoint = CGPoint(x: 0.5, y: -0.5)
    lazy var offsetX = self.homeView.portView.bounds.width * (newAnchorPoint.x - oldAnchorPoint.x)
    lazy var offsetY = self.homeView.portView.bounds.height * (newAnchorPoint.y - oldAnchorPoint.y)
    
    var imageDummy: [UIImage] = []
    let homeView = HomeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPanAction()
        setTapGesture()
        setCollectionView()
        setData()
        setPortImage()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(homeView)
        
        homeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
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
    }
    
    private func setCollectionView() {
        homeView.pageCollectionView.register(PageCollectionViewCell.self, forCellWithReuseIdentifier: PageCollectionViewCell.className)
    }
}

extension HomeViewController {
    @objc private func profileButtonTapped() {
        // 추후 수정 예정
        let detailProfileViewController = DetailProfileViewController()
//        detailProfileViewController.modalPresentationStyle = .fullScreen
//        detailProfileViewController.modalTransitionStyle = .coverVertical
//        self.present(detailProfileViewController, animated: true)
        self.navigationController?.pushViewController(detailProfileViewController, animated: true)
    }
    
    @objc private func handleBackTap(_ sender: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        if num == 0 {
            num = maxNum
        } else {
            num -= 1
        }
    }
    
    @objc private func handleNextTap(_ sender: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        if num == maxNum {
            num = 0
        } else {
            num += 1
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
                animateImage(isMatch: true)
            } else if velocity.x < -500 {
                animateImage(isMatch: false)
            } else {
                if rotationAngle < -0.1 {
                    animateImage(isMatch: true)
                } else if rotationAngle > 0.1 {
                    animateImage(isMatch: false)
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
        imageDummy = [.imgex1, .imgex2, .imgex3, .imgex4]
        maxNum = imageDummy.count - 1
    }
    
    private func setPortImage() {
        homeView.portImageView.image = imageDummy[self.num]
    }
    
    @objc private func yesButtonTapped() {
        animateImage(isMatch: true)
    }
    
    @objc private func noButtonTapped() {
        animateImage(isMatch: false)
    }
    
    private func animateImage(isMatch: Bool) {
        guard !isAnimating else { return }  // 애니메이션 중이면 함수 실행 중단
        isAnimating = true
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        
        var transform = CGAffineTransform(translationX: offsetX, y: offsetY)
        
        UIView.animate(withDuration: 1) {
            transform = transform.rotated(by: isMatch ? -(CGFloat.pi * 0.5) : (CGFloat.pi * 0.5))
            self.homeView.portView.layer.anchorPoint = self.newAnchorPoint
            self.homeView.portView.transform = transform
        } completion: { _ in
            // 추후 쌍방 매칭 됐을 때로 변경
            if isMatch {
                let matchViewController = MatchViewController()
                self.navigationController?.pushViewController(matchViewController, animated: false)
            }
            self.homeView.portView.layer.anchorPoint = self.oldAnchorPoint
            self.homeView.portView.transform = .identity
            self.num = 0
            self.isAnimating = false
            // 다음 유저로 넘기는 작업 수행
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
        let spacing: CGFloat = 13.adjustedWidth
        
        let cellWidth = (collectionViewWidth - CGFloat(totalItems - 1) * spacing) / CGFloat(totalItems)
        return CGSize(width: cellWidth, height: 2)
    }
}
