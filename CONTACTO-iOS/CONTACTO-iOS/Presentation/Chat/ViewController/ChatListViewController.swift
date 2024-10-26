//
//  ChatListViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class ChatListViewController: BaseViewController {
    var chatRoomList: [ChatList] = [
        ChatList(profile: "", name: "Contacto message", message: "Welcome to Contacto! If you have a problem using contacto, please let me know. Also, we relly", new: 3),
        ChatList(profile: "", name: "chaentopia", message: "Welcome to chaentopia!", new: 99),
        ChatList(profile: "", name: "chaentopia", message: "Welcome to chaentopia! If you have a problem using co...", new: 0),
        ChatList(profile: "", name: "Contacto message", message: "Welcome to Contacto! If you have a problem using co...", new: 3),
        ChatList(profile: "", name: "chaentopia", message: "Welcome to chaentopia! If you have a problem using co...", new: 99),
        ChatList(profile: "", name: "chaentopia", message: "Welcome to chaentopia! If you have a problem using co...", new: 0),
        ChatList(profile: "", name: "Contacto message", message: "Welcome to Contacto! If you have a problem using co...", new: 3),
        ChatList(profile: "", name: "chaentopia", message: "Welcome to chaentopia! If you have a problem using co...", new: 99),
        ChatList(profile: "", name: "chaentopia", message: "Welcome to chaentopia! If you have a problem using co...", new: 0),
        ChatList(profile: "", name: "Contacto message", message: "Welcome to Contacto! If you have a problem using co...", new: 3),
        ChatList(profile: "", name: "chaentopia", message: "Welcome to chaentopia! If you have a problem using co...", new: 99),
        ChatList(profile: "", name: "chaentopia", message: "Welcome to chaentopia! If you have a problem using co...", new: 0)
    ]
    let chatListView = ChatListView()
    let chatEmptyView = ChatEmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setData()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(chatListView,
                         chatEmptyView)
        
        chatListView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
        
        chatEmptyView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
    
    override func setDelegate() {
        chatListView.chatListCollectionView.delegate = self
        chatListView.chatListCollectionView.dataSource = self
    }
    
    private func setCollectionView() {
        chatListView.chatListCollectionView.register(ChatListCollectionViewCell.self, forCellWithReuseIdentifier: ChatListCollectionViewCell.className)
    }
    
    private func setData() {
        // data 받는 곳
        chatListView.isHidden = chatRoomList.isEmpty
        chatEmptyView.isHidden = !chatRoomList.isEmpty
    }
    
    @objc private func pushToChatRoom() {
        let chatRoomViewController = ChatRoomViewController()
        chatRoomViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}

extension ChatListViewController: UICollectionViewDelegate { }

extension ChatListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatRoomList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatListCollectionViewCell.className,
            for: indexPath) as? ChatListCollectionViewCell else { return UICollectionViewCell() }
        cell.configCell(data: chatRoomList[indexPath.row])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToChatRoom))
        cell.addGestureRecognizer(tapGesture)
        return cell
    }
}
