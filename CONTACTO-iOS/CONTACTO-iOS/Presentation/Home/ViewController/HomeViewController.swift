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
    
    override func setDelegate() {
        homeView.pageCollectionView.delegate = self
        homeView.pageCollectionView.dataSource = self
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
        case .right:
            print("right")
        default:
            print("기타")
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
