//
//  MatchViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class MatchViewController: BaseViewController {
    var greet: [Int] = [] {
        didSet {
            matchView.textCollectionView.reloadData()
        }
    }
    var greetMessage = [StringLiterals.Home.Match.hello,
                        StringLiterals.Home.Match.nice,
                        StringLiterals.Home.Match.hi,
                        StringLiterals.Home.Match.oh]
    let matchView = MatchView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(matchView)
        
        matchView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
    
    override func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        matchView.fieldView.addGestureRecognizer(tapGesture)
    }
    
    override func setDelegate() {
        matchView.greetCollectionView.delegate = self
        matchView.greetCollectionView.dataSource = self
        matchView.textCollectionView.delegate = self
        matchView.textCollectionView.dataSource = self
    }
    
    private func setCollectionView() {
        matchView.greetCollectionView.register(GreetCollectionViewCell.self, forCellWithReuseIdentifier: GreetCollectionViewCell.className)
        matchView.textCollectionView.register(GreetCollectionViewCell.self, forCellWithReuseIdentifier: GreetCollectionViewCell.className)
    }
}

extension MatchViewController {
    @objc private func tapAction() {
        matchView.descriptionLabel.isHidden = true
        matchView.greetCollectionView.isHidden = false
        matchView.textCollectionView.isHidden = false
    }
}

extension MatchViewController: UICollectionViewDelegate { }

extension MatchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return 4
        case 1:
            return greet.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GreetCollectionViewCell.className,
                for: indexPath) as? GreetCollectionViewCell else { return UICollectionViewCell() }
            cell.greetLabel.text = greetMessage[indexPath.row]
            cell.num = indexPath.row
            cell.selectButtonAction = {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
                self.greet.append(cell.num)
            }
            cell.deleteButton.isHidden = true
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GreetCollectionViewCell.className,
                for: indexPath) as? GreetCollectionViewCell else { return UICollectionViewCell() }
            cell.greetLabel.text = greetMessage[greet[indexPath.row]]
            cell.layoutIfNeeded()
            cell.deleteButton.isHidden = false
            cell.deleteButtonAction = {
                self.greet.remove(at: indexPath.row)
                cell.stopShaking()
            }
            cell.shake()
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
