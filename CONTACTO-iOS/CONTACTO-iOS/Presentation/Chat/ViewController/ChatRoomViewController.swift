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

final class ChatRoomViewController: BaseViewController {
    
    var content = ""
    var senderId = KeychainHandler.shared.userID
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
    
    private var hasNext = true
    private var currentPage = 0
    private let pageSize = 30
    private var isFetching = false
    private var isFirstLoad = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotifications()
        self.setData()
        self.registerSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        self.closeSocket()
        self.socketClient.disconnect()
        self.removeKeyboardNotifications()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setAddTarget() {
        chatRoomView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        chatRoomView.profileImageButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
//        chatRoomView.plusButton.addTarget(self, action: #selector(plusButtonTappped), for: .touchUpInside)
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
    
    private func setCollectionView() {
        chatRoomView.chatRoomCollectionView.register(ChatRoomDateCollectionViewCell.self, forCellWithReuseIdentifier: ChatRoomDateCollectionViewCell.className)
        chatRoomView.chatRoomCollectionView.register(ChatRoomYourCollectionViewCell.self, forCellWithReuseIdentifier: ChatRoomYourCollectionViewCell.className)
        chatRoomView.chatRoomCollectionView.register(ChatRoomMyCollectionViewCell.self, forCellWithReuseIdentifier: ChatRoomMyCollectionViewCell.className)
    }
    
    private func setData() {
        chatRoomView.nameLabel.text = chatRoomTitle
        if !self.chatRoomThumbnail.isEmpty,
           let imageUrl = URL(string: self.chatRoomThumbnail) {
            self.chatRoomView.profileImageButton.kf.setBackgroundImage(with: imageUrl, for: .normal)
        } else {
            self.chatRoomView.profileImageButton.setBackgroundImage(UIImage(named: "defaultProfile"), for: .normal)
        }
        chatMessages(isFirstLoad: true) { _ in
            self.chatRoomView.chatRoomCollectionView.reloadData()
            self.scrollToBottom()
            self.isFirstLoad = false
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
    
    func registerSocket() {
        guard let url = URL(string: "\(Config.chatBaseURL)?userId=\(KeychainHandler.shared.userID)&accessToken=\(KeychainHandler.shared.accessToken)") else { return }
        let request = NSMutableURLRequest(url: url)
        request.setValue(KeychainHandler.shared.accessToken, forHTTPHeaderField: "Authorization")
        socketClient.openSocketWithURLRequest(
            request: NSURLRequest(url: url),
            delegate: self
        )
    }
}

extension ChatRoomViewController: StompClientLibDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        if isFirstLoad { return }
        
        if offsetY <= 20, !isFetching, hasNext {
            chatMessages { _ in }
        }
    }
    
    func serverDidSendReceipt(client: StompClientLib, withReceiptId receiptId: String) {
        print("Receipt : \(receiptId)")
    }
    
    func serverDidSendPing() {
        print("Server ping")
    }
    
    
    func stompClient(client: StompClientLib,
                     didReceiveMessageWithJSONBody jsonBody: AnyObject?,
                     akaStringBody stringBody: String?,
                     withHeader header: [String : String]?,
                     withDestination destination: String) {
        print("Destination : \(destination)")
        print("JSON Body : \(String(describing: jsonBody))")
        
        guard let messageString = stringBody,
              let data = messageString.data(using: .utf8),
              let message = try? JSONDecoder().decode(Message.self, from: data) else {
            print("No valid message string or data received.")
            return
        }
        
        if message.senderId == Int(KeychainHandler.shared.userID) {
            print("Received echo message from self, ignoring.")
            return
        }
        DispatchQueue.main.async {
            self.chatList.append(message)
            self.chatRoomView.chatRoomCollectionView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func stompClientDidDisconnect(client: StompClientLib) {
        print("Socket is Disconnected")
        isConnected = false
    }
    
    func stompClientDidConnect(client: StompClientLib) {
        print("Socket is connected")
        isConnected = true
        
        // 연결 성공 시 구독 설정
        var headers = ["Authorization": KeychainHandler.shared.accessToken]
        headers["id"] = "sub-\(chatRoomId)"
        socketClient.subscribeWithHeader(destination: "/topic/\(chatRoomId)", withHeader: headers)
    }
    
    func serverDidSendError(client: StompClientLib, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("Error Send : \(String(describing: message))")
    }
}

extension ChatRoomViewController {
    
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func profileImageButtonTapped() {
        print("프로필을 누름")
        let detailProfileViewController = DetailProfileViewController()
        detailProfileViewController.userId = self.participants[0]
        detailProfileViewController.isFromChat = true
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
    }
    
    @objc private func sendButtonTapped() {
        guard let messageText = chatRoomView.messageTextView.text, !messageText.isEmpty else { return }
        
        self.content = messageText
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST 설정
        
        let currentDate = Date()
        self.createdAt = formatter.string(from: currentDate)
        
        if let plusRange = createdAt.range(of: "+09:00") { // "+09:00" 오프셋 제거
            self.createdAt.removeSubrange(plusRange)
        }
        
        let newMessage = Message(
            content: content,
            senderId: Int(senderId) ?? 0,
            sendedId: Int(participants[0]),
            createdAt: createdAt,
            readStatus: false)
        chatList.append(newMessage)
          
        if let messageData = try? JSONEncoder().encode(newMessage) {
            var headers = ["Authorization": KeychainHandler.shared.accessToken]
            headers["content-type"] = "application/json"
            socketClient.sendMessage(
                message: String(data: messageData, encoding: .utf8) ?? "",
                toDestination: "/app/chat.send/\(chatRoomId)",
                withHeaders: headers,
                withReceipt: nil
            )
        }
        chatRoomView.chatRoomCollectionView.reloadData()
        chatRoomView.messageTextView.text = ""
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        let itemCount = chatRoomView.chatRoomCollectionView.numberOfItems(inSection: 0)
        if itemCount > 0 {
            let indexPath = IndexPath(item: itemCount - 1, section: 0)
            chatRoomView.chatRoomCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func isAtBottom() -> Bool {
        let offsetY = chatRoomView.chatRoomCollectionView.contentOffset.y
        let contentHeight = chatRoomView.chatRoomCollectionView.contentSize.height
        let height = chatRoomView.chatRoomCollectionView.bounds.height
        
        return offsetY >= contentHeight - height
    }
    
    
    func calculateCellCount() -> Int {
        var cellCount = 0
        
        for i in 0..<chatList.count {
            if i == 0 || (chatList[i].createdAt.isDateDifferent(from: chatList[i - 1].createdAt) == true) {
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
        print(calculateCellCount())
        return calculateCellCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var messageIndex = 0
        var cellCount = 0
        
        for i in 0..<chatList.count {
            if i == 0 || (chatList[i].createdAt.isDateDifferent(from: chatList[i - 1].createdAt) == true) {
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
        
        if participants.contains(chatList[messageIndex].senderId) {
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
        var messageIndex = 0
        var cellCount = 0
        
        for i in 0..<chatList.count {
            if i == 0 || (chatList[i].createdAt.isDateDifferent(from: chatList[i - 1].createdAt) == true) {
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

