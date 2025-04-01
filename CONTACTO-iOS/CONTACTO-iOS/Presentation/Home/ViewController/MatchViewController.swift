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
    
    var matchData: Match?
    let matchView = MatchView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        matchView.textCollectionView.reloadData()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        view.addSubviews(matchView)
        
        matchView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        matchView.fieldView.addGestureRecognizer(tapGesture)
        matchView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        matchView.popButton.addTarget(self, action: #selector(popButtonTapped), for: .touchUpInside)
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
    
    @objc private func sendButtonTapped() {
        if !greet.isEmpty {
            let selectedGreetings = greet.map { greetMessage[$0] }.joined(separator: " ")
            NotificationCenter.default.post(
                name: Notification.Name("moveToChatRoomFromMatch"),
                object: nil,
                userInfo: [
                    "message": selectedGreetings,
                    "chatRoomId": matchData?.chatRoomId ?? 0,
                    "yourId": matchData?.yourId ?? 0,
                    "yourImageURL": matchData?.yourImageURL ?? "",
                    "yourLabel": matchData?.yourLabel ?? ""
                ]
            )
            self.dismiss(animated: true)
        }
    }
    
    @objc private func popButtonTapped() {
        self.dismiss(animated: true)
    }
    
    private func setData() {
        if let matchData = matchData {
            matchView.myImageView.kf.setImage(with: URL(string: matchData.myImageURL))
            matchView.myLabel.text = matchData.myLabel
            matchView.yourImageView.kf.setImage(with: URL(string: matchData.yourImageURL))
            matchView.yourLabel.text = matchData.yourLabel
        }
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
                HapticService.impact(.light).run()
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
