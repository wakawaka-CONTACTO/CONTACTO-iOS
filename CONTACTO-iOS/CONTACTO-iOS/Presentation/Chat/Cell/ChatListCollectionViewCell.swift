//
//  ChatListCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class ChatListCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: ChatListCollectionViewCellDelegate?
    var chatRoomId: Int?
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let messageLabel = UILabel()
    let newLabel = UILabel()
    let divideLine = UIView()
    
    // 나가기 배경 뷰 및 아이콘/텍스트
    private let leaveBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 254/255, green: 56/255, blue: 67/255, alpha: 1) // #FE3843
        view.isHidden = true  // 기본적으로 숨김 상태
        return view
    }()
    private let leaveLabel: UILabel = {
        let label = UILabel()
        label.text = "LEAVE"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 4
        return label
    }()
    private let leaveWidth: CGFloat = 80 // 붉은 영역 고정 너비
    
    private var isShowingLeave: Bool = false  // 현재 LEAVE 버튼 표시 상태
    private let swipeThreshold: CGFloat = 0.4  // LEAVE 표시 임계값 (40%)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setupSwipeGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        setStyle()
        setLayout()
        setupLeaveButtonAction()
    }
    
    private func setStyle() {
        profileImageView.do {
            $0.setRoundBorder(borderColor: .clear, borderWidth: 0, cornerRadius: 35)
            $0.backgroundColor = .ctblack
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        nameLabel.do {
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button4)
            $0.textAlignment = .left
        }
        
        messageLabel.do {
            $0.textColor = .ctblack
            $0.font = .fontContacto(.caption7)
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        newLabel.do {            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1, cornerRadius: 0)
            $0.backgroundColor = .ctmainblue
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button4)
            $0.textAlignment = .center
        }
        
        divideLine.do {
            $0.backgroundColor = .ctblack
        }
    }
    
    private func setLayout() {
        // contentView에 요소 추가
        self.contentView.addSubviews(profileImageView,
                                    nameLabel,
                                    messageLabel,
                                    newLabel,
                                    divideLine)
        
        // leaveBackgroundView 추가
        self.addSubview(leaveBackgroundView)
        leaveBackgroundView.addSubview(leaveLabel)
        
        // 전체 셀 크기 고정
        self.snp.makeConstraints {
            $0.width.equalTo(SizeLiterals.Screen.screenWidth)
        }
        
        // contentView 크기 고정 - 전체 화면 너비로 고정
        self.contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(70)
            $0.leading.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(22)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(1)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        newLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(11)
            $0.height.equalTo(24)
            $0.width.equalTo(30)
            $0.trailing.equalToSuperview().inset(26)
        }
        
        divideLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(13)
            $0.bottom.equalToSuperview()
        }
        
        leaveBackgroundView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(leaveWidth)
        }
        
        leaveLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupSwipeGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(pan)
    }
    
    private func setupLeaveButtonAction() {
        // LEAVE 버튼에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLeaveTap))
        leaveBackgroundView.addGestureRecognizer(tapGesture)
        leaveBackgroundView.isUserInteractionEnabled = true
    }
    
    @objc private func handleLeaveTap() {
        if isShowingLeave, let id = self.chatRoomId {
            delegate?.chatListCellDidRequestLeave(self, chatRoomId: id)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            // 스와이프 시작할 때 배경 준비
            self.bringSubviewToFront(leaveBackgroundView)
            leaveBackgroundView.bringSubviewToFront(leaveLabel)
            if translation.x < 0 {
                leaveBackgroundView.isHidden = false
            }
        case .changed:
            if translation.x < 0 {
                // 최대 LEAVE 너비만큼만 드래그 허용
                let limitedDragX = max(translation.x, -leaveWidth)
                contentView.transform = CGAffineTransform(translationX: limitedDragX, y: 0)
                
                // 스와이프 중에는 항상 LEAVE 버튼 표시
                leaveBackgroundView.isHidden = false
                
                // 스와이프 비율 계산
                let swipeRatio = min(abs(translation.x) / leaveWidth, 1.0)
                
                // 너비에 따라 투명도 조절
                leaveBackgroundView.alpha = swipeRatio
            }
        case .ended, .cancelled:
            // 임계값을 넘었는지 확인 (leaveWidth의 40% 이상 스와이프)
            let swipeDistance = abs(translation.x)
            let threshold = leaveWidth * swipeThreshold
            
            if swipeDistance > threshold {
                // 임계값 이상으로 스와이프했을 때 LEAVE 영역 표시
                UIView.animate(withDuration: 0.2) {
                    self.contentView.transform = CGAffineTransform(translationX: -self.leaveWidth, y: 0)
                    self.leaveBackgroundView.alpha = 1.0
                } completion: { _ in
                    self.isShowingLeave = true
                }
            } else {
                // 임계값보다 적게 스와이프했을 때 복귀
                UIView.animate(withDuration: 0.2) {
                    self.contentView.transform = .identity
                    self.leaveBackgroundView.alpha = 0.0
                } completion: { _ in
                    self.isShowingLeave = false
                    self.leaveBackgroundView.isHidden = true
                }
            }
        default:
            break
        }
    }
    
    func configCell(data: ChatListResponseDTO) {
        nameLabel.text = data.title
        messageLabel.text = data.latestMessageContent
        profileImageView.kfSetImage(url: data.chatRoomThumbnail, width: 150)
        chatRoomId = data.id // id 저장
        
        // 셀이 재사용될 때 LEAVE 상태 초기화
        resetLeaveState()
        
        switch data.unreadMessageCount {
        case 0:
            newLabel.isHidden = true
        case 1...99:
            newLabel.isHidden = false
            newLabel.text = "+\(data.unreadMessageCount)"
        default:
            newLabel.isHidden = false
            newLabel.text = "+99"
        }
    }
    
    private func resetLeaveState() {
        isShowingLeave = false
        contentView.transform = .identity
        leaveBackgroundView.isHidden = true
        leaveBackgroundView.alpha = 0
    }
    
    private func showLeaveState() {
        isShowingLeave = true
        contentView.transform = CGAffineTransform(translationX: -leaveWidth, y: 0)
        self.bringSubviewToFront(leaveBackgroundView)
        leaveBackgroundView.isHidden = false
        leaveBackgroundView.alpha = 1
        leaveBackgroundView.bringSubviewToFront(leaveLabel)
    }
    
    // 외부에서 leave 아이콘 탭 감지용 메서드
    func setLeaveAction(target: Any?, action: Selector) {
        leaveLabel.isUserInteractionEnabled = true
        leaveLabel.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
}

// MARK: - Delegate 프로토콜 정의
protocol ChatListCollectionViewCellDelegate: AnyObject {
    func chatListCellDidRequestLeave(_ cell: ChatListCollectionViewCell, chatRoomId: Int)
}
