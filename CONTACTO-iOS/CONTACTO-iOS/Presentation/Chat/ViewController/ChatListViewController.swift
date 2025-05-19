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
        // 화면에 진입할 때마다 데이터 초기화
        currentPage = 0
        chatRoomListData = []
        hasNext = true
        isInitializing = true
        
        // 초기 데이터 로딩
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        // 이미 데이터를 가져오는 중이면 중복 호출 방지
        guard !isFetching else {
            return
        }
        
        // 데이터 초기화
        if currentPage == 0 {
            chatRoomListData = []
            
            // 캐시된 데이터가 있으면 먼저 표시
            if let cachedData = getCachedChatRoomList() {
                chatRoomListData = cachedData.content
                chatListView.chatListCollectionView.reloadData()
                chatListView.isHidden = chatRoomListData.isEmpty
                chatEmptyView.isHidden = !chatRoomListData.isEmpty
                #if DEBUG
                print("ChatList: 캐시된 데이터 표시 - 데이터 개수: \(cachedData.content.count)")
                #endif
            }
        }
        
        self.chatRoomList { [weak self] _ in
            guard let self = self else { return }
            
            let renderStartTime = Date()
            self.chatListView.chatListCollectionView.reloadData()
            self.chatListView.isHidden = self.chatRoomListData.isEmpty
            self.chatEmptyView.isHidden = !self.chatRoomListData.isEmpty
            
            let renderEndTime = Date()
            let renderTimeInterval = renderEndTime.timeIntervalSince(renderStartTime)
            let totalTimeInterval = renderEndTime.timeIntervalSince(startTime)
            
            if self.chatRoomListData.isEmpty {
                self.sendAmpliLog(eventName: EventName.VIEW_EMPTY)
            }
            
            // 읽지 않은 메시지가 있는지 확인하고 탭바 아이콘 업데이트
            self.updateTabBarIcon()
            
            // 초기화 완료 표시
            self.isInitializing = false
        }
    }
    
    private func getCachedChatRoomList() -> PageableResponse<[ChatListResponseDTO]>? {
        let startTime = Date()
        
        guard let url = URL(string: "https://api.contacto.site/v1/users/me/chatroom") else {
            return nil
        }
        
        let request = URLRequest(url: url)
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(PageableResponse<[ChatListResponseDTO]>.self, from: cachedResponse.data)
                let endTime = Date()
                return data
            } catch {
                return nil
            }
        }
        return nil
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
        currentPage = 0
        chatRoomListData = []
        hasNext = true
        isInitializing = true
        setData()
    }

    private func chatRoomList(completion: @escaping (Bool) -> Void) {
        guard !isFetching, hasNext else { 
            completion(false)
            return 
        }
        isFetching = true

        let startTime = Date()
        NetworkService.shared.chatService.chatRoomList(page: currentPage, size: pageSize) { [weak self] response in
            guard let self = self else { return }
            
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)

            switch response {
            case .success(let data):
                let dataProcessingStartTime = Date()
                
                // page가 0일 때는 기존 데이터를 완전히 교체
                if self.currentPage == 0 {
                    self.chatRoomListData = data.content
                } else {
                    // 중복 데이터 체크 후 추가
                    let newContent = data.content.filter { newItem in
                        !self.chatRoomListData.contains { existingItem in
                            existingItem.id == newItem.id
                        }
                    }
                    self.chatRoomListData.append(contentsOf: newContent)
                }

                self.hasNext = data.hasNext
                
                let dataProcessingEndTime = Date()
                let dataProcessingTime = dataProcessingEndTime.timeIntervalSince(dataProcessingStartTime)
                
                self.isFetching = false
                completion(true)
            case .failure(let error):
                self.isFetching = false
                completion(false)
            case .pathErr:
                self.isFetching = false
                completion(false)
            case .serverErr:
                self.isFetching = false
                completion(false)
            case .networkErr:
                self.isFetching = false
                completion(false)
            case .requestErr(let data):
                self.isFetching = false
                completion(false)
            }
        }
    }
}

extension ChatListViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 초기화 중이면 스크롤 이벤트 무시
        if isInitializing {
            return 
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        // 스크롤이 하단에서 30포인트 이내로 왔을 때 다음 페이지 로드
        if offsetY > contentHeight - scrollViewHeight - 30 {
            guard !isFetching && hasNext else { return }
            
            // 다음 페이지 요청 전에 currentPage 증가
            let previousPage = currentPage
            currentPage += 1
            
            chatRoomList { [weak self] success in
                guard let self = self else { return }
                if !success {
                    // 실패 시 페이지 롤백
                    self.currentPage = previousPage
                }
                if success {
                    DispatchQueue.main.async {
                        self.chatListView.chatListCollectionView.reloadData()
                    }
                }
            }
        }
        
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
