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
        view.isHidden = true
        return view
    }()
    private let leaveLabel: UILabel = {
        let label = UILabel()
        label.text = "LEAVE"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)
        label.alpha = 0
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 4
        return label
    }()
    private var originalCenter: CGPoint = .zero
    private var isShowingLeave: Bool = false
    private var dragX: CGFloat = 0 // 드래그 상태 저장
    private let leaveWidth: CGFloat = 80 // 붉은 영역 고정 너비
    private let leaveTriggerRatio: CGFloat = 0.7 // 나가기 트리거 비율
    private let leaveMinAlphaRatio: CGFloat = 0.2 // alpha 시작 비율
    private let dragDamping: CGFloat = 1.0 // 드래그 감쇠 비율 (0.4 → 1.0)
    private var isLeaveHighlighting: Bool = false // leaveLabel 강조 상태
    
    private var currentLeaveWidth: CGFloat = 0 // 드래그한 만큼만 넓어짐 (최대 leaveWidth)
    
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
            $0.edges.equalToSuperview()
        }
        leaveLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(32)
        }
    }
    
    private func setupSwipeGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(pan)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLeaveBackgroundLayout()
    }
    
    private func updateLeaveBackgroundLayout() {
        // 셀 전체 높이 확인
        let cellHeight = self.bounds.height
        
        // leaveBackgroundView는 드래그한 만큼만 넓어짐 (최대 leaveWidth)
        // x 좌표를 계산하여 항상 오른쪽에 위치하도록 함
        leaveBackgroundView.frame = CGRect(
            x: bounds.width - currentLeaveWidth,  // 오른쪽에서부터 드래그된 만큼 영역 확보
            y: 0,
            width: currentLeaveWidth,            // 드래그된 만큼의 너비
            height: cellHeight                   // 셀의 전체 높이와 동일하게
        )
        
        // leaveLabel 크기 및 위치 최적화
        leaveLabel.sizeToFit()
        
        // LEAVE 텍스트를 leaveBackgroundView 중앙에 배치
        let centerX = leaveBackgroundView.bounds.width * 0.5
        leaveLabel.center = CGPoint(x: centerX, y: leaveBackgroundView.bounds.midY)
        
        // 항상 leaveLabel이 위에 보이도록
        leaveBackgroundView.bringSubviewToFront(leaveLabel)
        
        // Z-index 최종 확인
        self.bringSubviewToFront(leaveBackgroundView)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let width = self.bounds.width
        let maxLeaveWidth = leaveWidth
        let dragAmount = min(-translation.x, maxLeaveWidth)
        let leavePercent = dragAmount / maxLeaveWidth
        let leaveHighlight = leavePercent > leaveTriggerRatio
        
        switch gesture.state {
        case .began:
            originalCenter = self.center
            leaveBackgroundView.isHidden = false
            leaveBackgroundView.alpha = 1
            leaveLabel.alpha = 0 // 처음에는 안 보이게 시작
            dragX = 0
            isLeaveHighlighting = false
            // Z-index 조정 - 붉은 배경은 contentView 위에 표시되어야 함
            self.bringSubviewToFront(leaveBackgroundView)
        case .changed:
            if translation.x < 0 {
                dragX = translation.x
                // contentView는 LEAVE 영역 너비만큼만 정확히 이동하도록 제한
                let maxAllowedDrag = -leaveWidth // 정확히 LEAVE 너비만큼만 이동
                let limitedDragX = max(translation.x, maxAllowedDrag)
                contentView.transform = CGAffineTransform(translationX: limitedDragX * dragDamping, y: 0)
                
                // leaveBackgroundView 표시 설정 - 항상 뷰 뒤에 위치하도록
                leaveBackgroundView.isHidden = false
                currentLeaveWidth = dragAmount
                leaveBackgroundView.alpha = 1
                
                // Z-index 확인 - 레이블이 배경 위에 있도록
                leaveBackgroundView.bringSubviewToFront(leaveLabel)
                
                // 드래그 정도에 따라 alpha 조절 (20% 이상 드래그부터 점점 나타남)
                let alphaRatio = max(0, min(1, (leavePercent - leaveMinAlphaRatio) / (1 - leaveMinAlphaRatio)))
                leaveLabel.alpha = alphaRatio
                
                // 레이아웃 즉시 업데이트
                updateLeaveBackgroundLayout()
                
                // 노란색 강조 효과 제거
                isLeaveHighlighting = leaveHighlight
            }
        case .ended, .cancelled:
            // 스와이프 임계값 체크
            let didPassThreshold = leaveHighlight
            
            // 항상 원래 위치로 돌아가는 애니메이션
            UIView.animate(withDuration: 0.2, animations: {
                // contentView를 원래 위치로 복원
                self.contentView.transform = .identity
                self.leaveLabel.alpha = 0
                self.dragX = 0
                self.currentLeaveWidth = 0
                self.updateLeaveBackgroundLayout()
            }) { _ in
                // 애니메이션 완료 후 배경 숨김
                self.leaveBackgroundView.isHidden = true
                self.leaveBackgroundView.alpha = 0
                
                // 임계값을 넘었다면 채팅방 나가기 액션 실행
                if didPassThreshold, let id = self.chatRoomId {
                    self.delegate?.chatListCellDidRequestLeave(self, chatRoomId: id)
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
