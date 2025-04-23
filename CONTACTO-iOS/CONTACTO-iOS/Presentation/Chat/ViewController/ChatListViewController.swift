//
//  ChatListViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class ChatListViewController: BaseViewController, ChatAmplitudeSender {
    var chatRoomListData: [ChatListResponseDTO] = []
    let chatListView = ChatListView()
    let chatEmptyView = ChatEmptyView()
    
    private var lastScrollLogTime: Date?
    private let scrollLogInterval: TimeInterval = 3.0
    
    private var hasNext = true
    private var currentPage = 0
    private let pageSize = 10
    private var isFetching = false
    private var isFirstLoad = true
    private var isInitializing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        
        // 채팅방에서 돌아올 때 업데이트를 위한 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(refreshChatList), name: NSNotification.Name("RefreshChatList"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 0
        chatRoomListData = []
        hasNext = true
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ChatList: viewDidAppear - 채팅 리스트 화면 표시됨")
        // 화면이 나타날 때마다 데이터 새로 로드
        refreshChatList()
        isInitializing = false
        self.sendAmpliLog(eventName: EventName.VIEW_CHAT)
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
        let startTime = Date()
        print("ChatList: UI 업데이트 시작 - 시간: \(startTime)")
        self.chatRoomList(isFirstLoad: true) { [weak self] _ in
            guard let self = self else { return }
            
            let renderStartTime = Date()
            self.chatListView.chatListCollectionView.reloadData()
            self.chatListView.isHidden = self.chatRoomListData.isEmpty
            self.chatEmptyView.isHidden = !self.chatRoomListData.isEmpty
            self.isFirstLoad = false
            
            let renderEndTime = Date()
            let renderTimeInterval = renderEndTime.timeIntervalSince(renderStartTime)
            let totalTimeInterval = renderEndTime.timeIntervalSince(startTime)
            print("ChatList: UI 렌더링 완료 - 렌더링 시간: \(String(format: "%.3f", renderTimeInterval))초, 총 소요시간: \(String(format: "%.3f", totalTimeInterval))초")
            
            if self.chatRoomListData.isEmpty {
                self.sendAmpliLog(eventName: EventName.VIEW_EMPTY)
            }
            
            // 읽지 않은 메시지가 있는지 확인하고 탭바 아이콘 업데이트
            self.updateTabBarIcon()
        }
    }
    
    private func updateTabBarIcon() {
        let hasUnreadMessages = chatRoomListData.contains { $0.unreadMessageCount > 0 }
        
        // 상태 변경을 메인 탭바에 알림
        NotificationCenter.default.post(
            name: NSNotification.Name("newChatNotification"),
            object: nil,
            userInfo: ["hasUnreadMessages": hasUnreadMessages]
        )
    }
    
    @objc private func pushToChatRoom() {
        let chatRoomViewController = ChatRoomViewController()
        chatRoomViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
    
    @objc private func pushToChatRoom(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? ChatListCollectionViewCell,
        let indexPath = chatListView.chatListCollectionView.indexPath(for: cell) else { return }
        let id = chatRoomListData[indexPath.row].id
        let chatRoomViewController = ChatRoomViewController()
        chatRoomViewController.hidesBottomBarWhenPushed = true
        chatRoomViewController.chatRoomId = id
        chatRoomViewController.otherUserId = chatRoomListData[indexPath.row].participants[0]
        chatRoomViewController.participants = chatRoomListData[indexPath.row].participants
        chatRoomViewController.chatRoomTitle = chatRoomListData[indexPath.row].title
        chatRoomViewController.chatRoomThumbnail = chatRoomListData[indexPath.row].chatRoomThumbnail ?? ""
        self.navigationController?.pushViewController(chatRoomViewController, animated: true)
        self.sendAmpliLog(eventName: EventName.CLICK_CHAT)
    }
    
    @objc private func refreshChatList() {
        print("ChatList: refreshChatList 호출됨")
        currentPage = 0
        chatRoomListData = []
        hasNext = true
        setData()
    }

    private func chatRoomList(isFirstLoad: Bool = false, completion: @escaping (Bool) -> Void) {
        guard !isFetching, hasNext else { 
            completion(false)
            return 
        }
        isFetching = true

        let startTime = Date()
        print("ChatList: API 호출 시작 - page: \(currentPage), 시간: \(startTime)")
        NetworkService.shared.chatService.chatRoomList(page: currentPage, size: pageSize) { [weak self] response in
            guard let self = self else { return }
            
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)
            print("ChatList: API 응답 완료 - page: \(currentPage), 소요시간: \(String(format: "%.3f", timeInterval))초")

            switch response {
            case .success(let data):
                let dataProcessingStartTime = Date()
                if isFirstLoad {
                    self.chatRoomListData = data.content
                    print("ChatList: 첫 로드 데이터 개수 - \(data.content.count)")
                } else {
                    self.chatRoomListData.append(contentsOf: data.content)
                    print("ChatList: 추가 로드 데이터 개수 - \(data.content.count)")
                }

                self.hasNext = data.hasNext
                self.currentPage += 1
                self.isFetching = false
                
                let dataProcessingEndTime = Date()
                let dataProcessingTime = dataProcessingEndTime.timeIntervalSince(dataProcessingStartTime)
                print("ChatList: 데이터 처리 시간 - \(String(format: "%.3f", dataProcessingTime))초")
                
                completion(true)
            default:
                print("ChatList: API 호출 실패")
                self.isFetching = false
                completion(false)
            }
        }
    }
}

extension ChatListViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - scrollViewHeight - 50 {
            chatRoomList { success in
                if success {
                    DispatchQueue.main.async {
                        self.chatListView.chatListCollectionView.reloadData()
                    }
                }
            }
        }
        if isInitializing { return }
        let currentTime = Date()
        if lastScrollLogTime == nil || currentTime.timeIntervalSince(lastScrollLogTime!) >= scrollLogInterval {
            self.sendAmpliLog(eventName: EventName.SCROLL_CHAT)
            lastScrollLogTime = currentTime
        }
    }
}

extension ChatListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatRoomListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatListCollectionViewCell.className,
            for: indexPath) as? ChatListCollectionViewCell else { return UICollectionViewCell() }
        cell.configCell(data: chatRoomListData[indexPath.row])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToChatRoom(_:)))
        cell.addGestureRecognizer(tapGesture)
        return cell
    }
}
