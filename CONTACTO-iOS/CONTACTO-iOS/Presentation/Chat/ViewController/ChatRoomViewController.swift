//
//  ChatRoomViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/21/24.
//

import UIKit

import PhotosUI
import SnapKit
import StompClientLib
import Then

final class ChatRoomViewController: BaseViewController, ChatAmplitudeSender {
    
    var content = ""
    var senderId = KeychainHandler.shared.userID
    var otherUserId = 0
    var createdAt = ""
    var isConnected = false
    var socketClient = StompClientLib()
    
    var chatRoomId = 0
    var chatRoomTitle = ""
    var chatRoomThumbnail = ""
    var participants: [Int] = []
    var chatList: [Message] = []
    var isKeyboardShow = false
    let chatRoomView = ChatRoomView()
    
    var isFirstMatch = false
    private var hasNext = true
    private var currentPage = 0
    private let pageSize = 30
    private var isFetching = false
    private var isFirstLoad = true
    
    private var lastScrollLogTime: Date?
    private let scrollLogInterval: TimeInterval = 3.0
    private var isInitializing: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotifications()
        self.setData()
        self.sendAmpliLog(eventName: EventName.VIEW_CHATROOM)
        self.isInitializing = false
        
        // WebSocketManager 델리게이트 등록 및 채팅방 활성화
        WebSocketManager.shared.addDelegate(self, forRoomId: chatRoomId)
        WebSocketManager.shared.setActiveRoom(chatRoomId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
        // WebSocketManager에서 현재 채팅방 해제
        WebSocketManager.shared.removeDelegate(self, forRoomId: chatRoomId)
        WebSocketManager.shared.setActiveRoom(nil)
        
        // 채팅 목록 업데이트를 위한 알림 전송
        NotificationCenter.default.post(name: NSNotification.Name("RefreshChatList"), object: nil)
        print("ChatRoom: RefreshChatList 알림 전송됨")
        
        self.removeKeyboardNotifications()
    }
    
    deinit {
        print("ChatRoomViewController deinit called")
        
        // 메모리에서 해제되기 전에 참조 정리
        chatList.removeAll()
        participants.removeAll()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setAddTarget() {
        chatRoomView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        chatRoomView.profileImageButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        chatRoomView.plusButton.addTarget(self, action: #selector(plusButtonTappped), for: .touchUpInside)
        chatRoomView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    override func setLayout() {
        view.addSubviews(chatRoomView)
        
        chatRoomView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setDelegate() {
        chatRoomView.chatRoomCollectionView.delegate = self
        chatRoomView.chatRoomCollectionView.dataSource = self
        chatRoomView.messageTextView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setCollectionView() {
        chatRoomView.chatRoomCollectionView.register(ChatRoomDateCollectionViewCell.self, forCellWithReuseIdentifier: ChatRoomDateCollectionViewCell.className)
        chatRoomView.chatRoomCollectionView.register(ChatRoomYourCollectionViewCell.self, forCellWithReuseIdentifier: ChatRoomYourCollectionViewCell.className)
        chatRoomView.chatRoomCollectionView.register(ChatRoomMyCollectionViewCell.self, forCellWithReuseIdentifier: ChatRoomMyCollectionViewCell.className)
    }
    
    private func setData() {
        chatRoomView.nameLabel.text = chatRoomTitle
        if !self.chatRoomThumbnail.isEmpty,
           let imageUrl = URL(string: self.chatRoomThumbnail) {
            self.chatRoomView.profileImageButton.kf.setImage(with: imageUrl, for: .normal)
        } else {
            self.chatRoomView.profileImageButton.setImage(UIImage(named: "defaultProfile"), for: .normal)
        }
        
        // 상대 프로필 조회
        detailPort(userId: otherUserId) { _ in }
        
        chatMessages(isFirstLoad: true) { _ in
            self.chatRoomView.chatRoomCollectionView.reloadData()
            self.scrollToBottom()
            self.isFirstLoad = false
        }
    }
    
    private func detailPort(userId: Int, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.detailPort(userId: userId) { [weak self] response in
            guard let self = self else { return }
            var isAvailable = true
            
            switch response {
            case .success:
                isAvailable = true
                completion(true)
            case .failure(let error):
                if error.statusCode == 404 {
                    isAvailable = false
                }
                completion(false)
            default:
                completion(false)
            }
            
            self.chatRoomView.setChatRoomAvailability(isAvailable: isAvailable)
        }
    }
    
    private func chatMessages(isFirstLoad: Bool = false, completion: @escaping (Bool) -> Void) {
        guard !isFetching, hasNext else { return }
        isFetching = true
        
        NetworkService.shared.chatService.chatMessages(roomId: chatRoomId, page: currentPage, size: pageSize) { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .success(let data):
                let sortedMessages = data.content.sorted { $0.createdAt < $1.createdAt }
                
                if isFirstLoad {
                    if !isFirstMatch {
                        self.chatRoomView.isFirstChat = data.content.isEmpty
                    } else {
                        self.chatRoomView.isFirstChat = false
                    }
                    self.chatList = sortedMessages
                    self.chatRoomView.chatRoomCollectionView.reloadData()
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.scrollToBottom()
                        self.isFetching = false
                    }
                } else {
                    let previousContentHeight = chatRoomView.chatRoomCollectionView.contentSize.height
                    let previousContentOffset = chatRoomView.chatRoomCollectionView.contentOffset

                    self.chatList.insert(contentsOf: sortedMessages, at: 0)
                    self.chatRoomView.chatRoomCollectionView.reloadData()
                    chatRoomView.chatRoomCollectionView.layoutIfNeeded()

                    let newContentHeight = chatRoomView.chatRoomCollectionView.contentSize.height
                    let heightDifference = newContentHeight - previousContentHeight

                    let newOffset = CGPoint(x: previousContentOffset.x, y: previousContentOffset.y + heightDifference)
                    chatRoomView.chatRoomCollectionView.setContentOffset(newOffset, animated: false)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.isFetching = false
                    }
                }

                self.hasNext = data.hasNext
                self.currentPage += 1
                completion(true)
            default:
                self.isFetching = false
                completion(false)
            }
        }
    }

    private func sendMessage(_ messageText: String) {
        self.content = messageText
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        let currentDate = Date()
        self.createdAt = formatter.string(from: currentDate)
        
        if let plusRange = createdAt.range(of: "+09:00") {
            self.createdAt.removeSubrange(plusRange)
        }
        
        let newMessage = Message(
            content: content,
            senderId: Int(senderId) ?? 0,
            sendedId: Int(participants.first ?? 0),
            createdAt: createdAt,
            readStatus: false)
        
        // 로컬 UI 업데이트
        chatList.append(newMessage)
        chatRoomView.chatRoomCollectionView.reloadData()
        chatRoomView.messageTextView.text = ""
        scrollToBottom()
          
        // WebSocketManager를 통해 메시지 전송
        WebSocketManager.shared.sendMessage(newMessage, to: chatRoomId)
    }
}

// MARK: - WebSocketManagerDelegate
extension ChatRoomViewController: WebSocketManagerDelegate {
    func didReceiveMessage(_ message: Message, forRoomId: Int) {
        // forRoomId가 현재 채팅방 ID와 일치하는지 확인
        guard forRoomId == self.chatRoomId else { return }
        
        // 현재 사용자가 보낸 메시지는 건너뜀 (에코 방지)
        if message.senderId == Int(KeychainHandler.shared.userID) {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.chatList.append(message)
            self.chatRoomView.chatRoomCollectionView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func didChangeConnectionStatus(isConnected: Bool) {
        // 연결 상태가 변경되었을 때 UI 업데이트
        self.isConnected = isConnected
    }
}

extension ChatRoomViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        if isFirstLoad { return }
        
        if offsetY <= 20, !isFetching, hasNext {
            chatMessages { _ in }
        }
    }
    
    /// 노티피케이션 추가
    func addKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ noti: NSNotification){
        if let userInfo = noti.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            self.chatRoomView.bottomView.snp.remakeConstraints {
                $0.top.equalTo(view.snp.bottom).offset(-(keyboardHeight+62.adjustedHeight))
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(62.adjustedHeight)
            }
            
            if self.isAtBottom() {
                self.chatRoomView.chatRoomCollectionView.snp.remakeConstraints {
                    $0.top.leading.trailing.equalToSuperview()
                    $0.bottom.equalTo(chatRoomView.bottomView.snp.top)
                }
                // 레이아웃 변경 후 스크롤 이동
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }) { _ in
                    self.scrollToBottom()
                }
            }
            
            if !isKeyboardShow {
                UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                self.view.layoutIfNeeded()
            }
            
            isKeyboardShow = true
        }
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification){
        self.chatRoomView.bottomView.snp.remakeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-66.adjustedHeight)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        isKeyboardShow = false
    }
    
    @objc private func backButtonTapped() {
        print("ChatRoom: 뒤로가기 버튼 클릭")
        self.navigationController?.popViewController(animated: true)
        self.sendAmpliLog(eventName: EventName.CLICK_CHATROOM_BACK)
    }
    
    @objc private func profileImageButtonTapped() {
        let detailProfileViewController = DetailProfileViewController(from: .chatroom)
        detailProfileViewController.userId = otherUserId
        detailProfileViewController.isFromChat = true
        self.sendAmpliLog(eventName: EventName.CLICK_CHATROOM_PROFILE)
        self.navigationController?.pushViewController(detailProfileViewController, animated: true)
    }
    
    @objc private func plusButtonTappped() {
        var configuration = PHPickerConfiguration()
        lazy var picker = PHPickerViewController(configuration: configuration)
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        configuration.selection = .default
        self.present(picker, animated: true, completion: nil)
        picker.delegate = self
        self.sendAmpliLog(eventName: EventName.CLICK_CHATROOM_PLUS)
    }
    
    @objc private func sendButtonTapped() {
        guard let messageText = chatRoomView.messageTextView.text, !messageText.isEmpty else { return }
        guard WebSocketManager.shared.isConnected else { return }  // 연결 상태 확인
        
        self.sendAmpliLog(eventName: EventName.CLICK_CHATROOM_SEND)
        sendMessage(messageText)
    }
    
    private func scrollToBottom() {
        let itemCount = chatRoomView.chatRoomCollectionView.numberOfItems(inSection: 0)
        if itemCount > 0 {
            let indexPath = IndexPath(item: itemCount - 1, section: 0)
            if indexPath.item < itemCount {
                chatRoomView.chatRoomCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        }
        if isInitializing { return }
        let currentTime = Date()
        if lastScrollLogTime == nil || currentTime.timeIntervalSince(lastScrollLogTime!) >= scrollLogInterval {
            self.sendAmpliLog(eventName: EventName.SCROLL_CHATROOM)
            lastScrollLogTime = currentTime
        }
    }
    
    private func isAtBottom() -> Bool {
        let offsetY = chatRoomView.chatRoomCollectionView.contentOffset.y
        let contentHeight = chatRoomView.chatRoomCollectionView.contentSize.height
        let height = chatRoomView.chatRoomCollectionView.bounds.height
        
        return offsetY >= contentHeight - height
    }
    
    
    func calculateCellCount() -> Int {
        // 빈 배열 확인
        guard !chatList.isEmpty else { return 0 }
        
        var cellCount = 0
        
        for i in 0..<chatList.count {
            if i == 0 || (i > 0 && chatList[i].createdAt.isDateDifferent(from: chatList[i - 1].createdAt) == true) {
                cellCount += 1
            }
            cellCount += 1
        }
        
        return cellCount
    }
}

extension ChatRoomViewController: UICollectionViewDelegate { }

extension ChatRoomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = calculateCellCount()
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 빈 배열 확인
        guard !chatList.isEmpty else { return UICollectionViewCell() }
        
        var messageIndex = 0
        var cellCount = 0
        
        for i in 0..<chatList.count {
            if i == 0 || (i > 0 && chatList[i].createdAt.isDateDifferent(from: chatList[i - 1].createdAt) == true) {
                if cellCount == indexPath.row {
                    guard let dateCell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ChatRoomDateCollectionViewCell.className,
                        for: indexPath) as? ChatRoomDateCollectionViewCell else { return UICollectionViewCell() }
                    dateCell.configCell(date: chatList[i].createdAt)
                    return dateCell
                }
                cellCount += 1
            }
            if cellCount == indexPath.row {
                messageIndex = i
                break
            }
            cellCount += 1
        }
        
        // 범위 확인
        guard messageIndex < chatList.count else { return UICollectionViewCell() }
        
        if let senderId = chatList[messageIndex].senderId as? Int, participants.contains(senderId) {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatRoomYourCollectionViewCell.className,
                for: indexPath) as? ChatRoomYourCollectionViewCell else { return UICollectionViewCell() }
            cell.configYourChatCell(data: chatList[messageIndex])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatRoomMyCollectionViewCell.className,
                for: indexPath) as? ChatRoomMyCollectionViewCell else { return UICollectionViewCell() }
            cell.configMyChatCell(data: chatList[messageIndex])
            return cell
        }
    }
}

extension ChatRoomViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 빈 배열 확인
        guard !chatList.isEmpty else { return CGSize(width: SizeLiterals.Screen.screenWidth, height: 27) }
        
        var messageIndex = 0
        var cellCount = 0
        
        for i in 0..<chatList.count {
            if i == 0 || (i > 0 && chatList[i].createdAt.isDateDifferent(from: chatList[i - 1].createdAt) == true) {
                if cellCount == indexPath.row {
                    return CGSize(width: SizeLiterals.Screen.screenWidth, height: 28.adjustedHeight)
                }
                cellCount += 1
            }
            if cellCount == indexPath.row {
                messageIndex = i
                break
            }
            cellCount += 1
        }
        return CGSize(width: SizeLiterals.Screen.screenWidth, height: 27)
    }
}

extension ChatRoomViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        // 사진 send 메소드
    }
}

extension ChatRoomViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty, !textView.text.isOnlyWhitespace() {
            chatRoomView.sendButton.isHidden = false
        } else {
            chatRoomView.sendButton.isHidden = true
        }
    }
}

