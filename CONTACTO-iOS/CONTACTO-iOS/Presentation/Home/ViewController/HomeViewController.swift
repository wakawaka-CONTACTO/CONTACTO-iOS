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
    
    var imageDummy: [UIImage] = []
    let homeView = HomeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeAction()
        setTapGesture()
        setCollectionView()
        setData()
        setPortImage()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        setSwipeAction()
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
    }
    
    override func setDelegate() {
        homeView.pageCollectionView.delegate = self
        homeView.pageCollectionView.dataSource = self
    }
    
    
    private func setSwipeAction() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipeGestureRecognizer.direction = .left
        rightSwipeGestureRecognizer.direction = .right
        
        homeView.portView.addGestureRecognizer(leftSwipeGestureRecognizer)
        homeView.portView.addGestureRecognizer(rightSwipeGestureRecognizer)
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
    @objc private func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            print("left")
            animateImage(isMatch: false)
        case .right:
            print("right")
            animateImage(isMatch: true)
        default:
            print("check the direction")
        }
    }
    
    @objc private func handleBackTap(_ sender: UITapGestureRecognizer) {
        if num == 0 {
            num = maxNum
        } else {
            num -= 1
        }
    }
    
    @objc private func handleNextTap(_ sender: UITapGestureRecognizer) {
        if num == maxNum {
            num = 0
        } else {
            num += 1
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
        
        let oldAnchorPoint = CGPoint(x: 0.5, y: 0.5)
        let newAnchorPoint = CGPoint(x: 0.5, y: -0.5)
        let offsetX = self.homeView.portView.bounds.width * (newAnchorPoint.x - oldAnchorPoint.x)
        let offsetY = self.homeView.portView.bounds.height * (newAnchorPoint.y - oldAnchorPoint.y)
        
        var transform = CGAffineTransform(translationX: offsetX, y: offsetY)
        
        UIView.animate(withDuration: 1) {
            transform = transform.rotated(by: isMatch ? -(CGFloat.pi * 0.5) : (CGFloat.pi * 0.5))
            self.homeView.portView.layer.anchorPoint = newAnchorPoint
            self.homeView.portView.transform = transform
        } completion: { _ in
            self.homeView.portView.layer.anchorPoint = oldAnchorPoint
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
        return 4
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
