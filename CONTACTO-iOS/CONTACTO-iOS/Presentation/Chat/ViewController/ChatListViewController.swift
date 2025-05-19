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
        #if DEBUG
        print("ChatList: viewDidAppear - 채팅 리스트 화면 표시됨")
        #endif
        
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
        #if DEBUG
        print("ChatList: UI 업데이트 시작 - 시간: \(startTime)")
        #endif
        
        // 이미 데이터를 가져오는 중이면 중복 호출 방지
        guard !isFetching else {
            #if DEBUG
            print("ChatList: 이미 데이터 로딩 중입니다.")
            #endif
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
            #if DEBUG
            print("ChatList: UI 렌더링 완료 - 렌더링 시간: \(String(format: "%.3f", renderTimeInterval))초, 총 소요시간: \(String(format: "%.3f", totalTimeInterval))초")
            #endif
            
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
        #if DEBUG
        print("🔍 [Chat] 캐시 데이터 조회 시작 - 시간: \(startTime)")
        #endif
        
        guard let url = URL(string: "https://api.contacto.site/v1/users/me/chatroom") else {
            #if DEBUG
            print("❌ [Chat] URL 생성 실패")
            #endif
            return nil
        }
        
        let request = URLRequest(url: url)
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(PageableResponse<[ChatListResponseDTO]>.self, from: cachedResponse.data)
                let endTime = Date()
                #if DEBUG
                print("✅ [Chat] 캐시 데이터 조회 성공 - 시간: \(endTime)")
                print("⏱️ [Chat] 캐시 데이터 조회 소요시간: \(endTime.timeIntervalSince(startTime))초")
                #endif
                return data
            } catch {
                #if DEBUG
                print("❌ [Chat] 캐시된 채팅방 리스트 디코딩 실패: \(error)")
                #endif
                return nil
            }
        }
        #if DEBUG
        print("ℹ️ [Chat] 캐시된 데이터 없음")
        #endif
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
        #if DEBUG
        print("ChatList: refreshChatList 호출됨")
        #endif
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
        #if DEBUG
        print("ChatList: API 호출 시작 - page: \(currentPage), 시간: \(startTime)")
        #endif
        NetworkService.shared.chatService.chatRoomList(page: currentPage, size: pageSize) { [weak self] response in
            guard let self = self else { return }
            
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)
            #if DEBUG
            print("ChatList: API 응답 완료 - page: \(self.currentPage), 소요시간: \(String(format: "%.3f", timeInterval))초")
            #endif

            switch response {
            case .success(let data):
                let dataProcessingStartTime = Date()
                
                // page가 0일 때는 기존 데이터를 완전히 교체
                if self.currentPage == 0 {
                    self.chatRoomListData = data.content
                    #if DEBUG
                    print("ChatList: 첫 로드 데이터 개수 - \(data.content.count)")
                    #endif
                } else {
                    // 중복 데이터 체크 후 추가
                    let newContent = data.content.filter { newItem in
                        !self.chatRoomListData.contains { existingItem in
                            existingItem.id == newItem.id
                        }
                    }
                    self.chatRoomListData.append(contentsOf: newContent)
                    #if DEBUG
                    print("ChatList: 추가 로드 데이터 개수 - \(newContent.count)")
                    #endif
                }

                self.hasNext = data.hasNext
                
                let dataProcessingEndTime = Date()
                let dataProcessingTime = dataProcessingEndTime.timeIntervalSince(dataProcessingStartTime)
                #if DEBUG
                print("ChatList: 데이터 처리 시간 - \(String(format: "%.3f", dataProcessingTime))초")
                #endif
                
                self.isFetching = false
                completion(true)
            case .failure(let error):
                #if DEBUG
                print("ChatList: API 호출 실패 - 에러: \(error)")
                #endif
                self.isFetching = false
                completion(false)
            case .pathErr:
                #if DEBUG
                print("ChatList: API 호출 실패 - pathErr")
                #endif
                self.isFetching = false
                completion(false)
            case .serverErr:
                #if DEBUG
                print("ChatList: API 호출 실패 - serverErr")
                #endif
                self.isFetching = false
                completion(false)
            case .networkErr:
                #if DEBUG
                print("ChatList: API 호출 실패 - networkErr")
                #endif
                self.isFetching = false
                completion(false)
            case .requestErr(let data):
                #if DEBUG
                print("ChatList: API 호출 실패 - requestErr: \(data)")
                #endif
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
            #if DEBUG
            print("ChatList: 초기화 중이므로 스크롤 이벤트 무시")
            #endif
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
            #if DEBUG
            print("ChatList: 다음 페이지 로드 시작 - page: \(currentPage)")
            #endif
            
            chatRoomList { [weak self] success in
                guard let self = self else { return }
                if !success {
                    // 실패 시 페이지 롤백
                    self.currentPage = previousPage
                    #if DEBUG
                    print("ChatList: API 호출 실패로 페이지 롤백 - page: \(self.currentPage)")
                    #endif
                }
                if success {
                    DispatchQueue.main.async {
                        self.chatListView.chatListCollectionView.reloadData()
                        #if DEBUG
                        print("ChatList: 다음 페이지 로드 완료 - 현재 데이터 개수: \(self.chatRoomListData.count)")
                        #endif
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
        cell.delegate = self
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToChatRoom(_:)))
        
        // 길게 누르기 제스처 추가
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        
        cell.addGestureRecognizer(tapGesture)
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
}

// MARK: - 채팅방 나가기 관련 메소드
extension ChatListViewController {
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let cell = gesture.view as? ChatListCollectionViewCell,
                  let indexPath = chatListView.chatListCollectionView.indexPath(for: cell) else { return }
            
            let chatRoom = chatRoomListData[indexPath.row]
            showLeaveChatRoomConfirmation(for: chatRoom, at: indexPath)
        }
    }
    
    private func showLeaveChatRoomConfirmation(for chatRoom: ChatListResponseDTO, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Leave chatroom",
            message: "Do you want to leave Chatroom?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.leaveChatRoom(chatRoom.id, at: indexPath)
        }
        let noAction = UIAlertAction(title: "No", style: .destructive)
        
        // Yes(파랑)가 왼쪽, No(빨강)가 오른쪽
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    
    private func leaveChatRoom(_ roomId: Int, at indexPath: IndexPath) {
        // 로딩 표시
        let loadingAlert = UIAlertController(title: nil, message: "Leaving...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        NetworkService.shared.chatService.leaveChatRoom(roomId: roomId) { [weak self] result in
            guard let self = self else { return }
            
            // 로딩 얼럿 닫기
            self.dismiss(animated: true) {
                switch result {
                case .success(let response):
                    if response.success {
                        #if DEBUG
                        print("ChatList: 채팅방 나가기 성공 - roomId: \(roomId)")
                        #endif
                        
                        // 성공 시 UI 업데이트
                        DispatchQueue.main.async {
                            // 데이터에서 해당 채팅방 제거
                            self.chatRoomListData.remove(at: indexPath.row)
                            
                            // 컬렉션뷰 업데이트
                            self.chatListView.chatListCollectionView.deleteItems(at: [indexPath])
                            
                            // 빈 상태 처리
                            self.chatListView.isHidden = self.chatRoomListData.isEmpty
                            self.chatEmptyView.isHidden = !self.chatRoomListData.isEmpty
                            
                            // 탭바 아이콘 업데이트
                            self.updateTabBarIcon()
                            
                            // 채팅방 목록 갱신을 위한 노티피케이션 전송
                            NotificationCenter.default.post(name: NSNotification.Name("RefreshChatList"), object: nil)
                            
                            // 성공 토스트 메시지 표시
                            self.showToast(message: "채팅방에서 나갔습니다.")
                        }
                    } else {
                        #if DEBUG
                        print("ChatList: 채팅방 나가기 실패 - roomId: \(roomId)")
                        #endif
                        self.showErrorAlert(message: "채팅방 나가기에 실패했습니다. 다시 시도해주세요.")
                    }
                    return // 추가: 성공 또는 실패 처리 후 여기서 종료
                case .failure(let error):
                    #if DEBUG
                    print("ChatList: 채팅방 나가기 실패 - roomId: \(roomId), 오류: \(error)")
                    #endif
                    self.showErrorAlert(message: "채팅방 나가기에 실패했습니다. 다시 시도해주세요.")
                    
                case .pathErr, .serverErr, .networkErr:
                    #if DEBUG
                    print("ChatList: 채팅방 나가기 실패 - roomId: \(roomId), 서버 또는 네트워크 오류")
                    #endif
                    self.showErrorAlert(message: "서버 연결에 문제가 있습니다. 잠시 후 다시 시도해주세요.")
                    
                case .requestErr(let data):
                    #if DEBUG
                    print("ChatList: 채팅방 나가기 실패 - roomId: \(roomId), 요청 오류: \(data)")
                    #endif
                    self.showErrorAlert(message: "채팅방 나가기에 실패했습니다. 다시 시도해주세요.")
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - ChatListCollectionViewCellDelegate 구현
extension ChatListViewController: ChatListCollectionViewCellDelegate {
    func chatListCellDidRequestLeave(_ cell: ChatListCollectionViewCell, chatRoomId: Int) {
        guard let indexPath = chatListView.chatListCollectionView.indexPath(for: cell) else { return }
        let chatRoom = chatRoomListData[indexPath.row]
        // 기존과 동일하게 나가기 처리
        showLeaveChatRoomConfirmation(for: chatRoom, at: indexPath)
    }
}
