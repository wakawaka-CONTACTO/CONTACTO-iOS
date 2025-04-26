//
//  CropImageView.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/24/25.
//

import Foundation
import UIKit

// MARK: - CropImageView
/// UIView responsible for displaying image, overlay, crop area, and ratio controls.
final class CropImageView: UIView {
    // MARK: UI Elements
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
    }
    private let overlayView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        $0.isUserInteractionEnabled = false
    }
    let cropAreaView = UIView().then {
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 2
        $0.isUserInteractionEnabled = true
    }
    let ratioOptions = ["1:1", "3:4", "4:3", "9:16", "16:9", "Fit"]
    lazy var ratioControl = UISegmentedControl(items: ratioOptions).then {
        $0.selectedSegmentIndex = 0
    }
    let cancelButton = UIButton(type: .system).then { $0.setTitle("Cancel", for: .normal) }
    let cropButton = UIButton(type: .system).then { $0.setTitle("Crop", for: .normal) }
    
    // 회전 버튼들
    let rotateLeftButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "rotate.left"), for: .normal)
        $0.tintColor = .white
    }
    let rotateRightButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "rotate.right"), for: .normal)
        $0.tintColor = .white
    }

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        backgroundColor = .black
        addSubviews(imageView, overlayView, cropAreaView, ratioControl, cancelButton, cropButton, rotateLeftButton, rotateRightButton)
        setupConstraints()
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(ratioControl.snp.top).offset(-16)
        }
        overlayView.snp.makeConstraints { make in make.edges.equalTo(imageView) }
        cropAreaView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.width.equalTo(imageView.snp.width).multipliedBy(0.8)
            make.height.equalTo(cropAreaView.snp.width)
        }
        ratioControl.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(cancelButton.snp.top).offset(-12)
            make.height.equalTo(32)
        }
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            make.height.equalTo(44)
        }
        cropButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(cancelButton)
            make.height.equalTo(44)
        }
        rotateLeftButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(safeAreaLayoutGuide).inset(16)
            make.size.equalTo(44)
        }
        rotateRightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(safeAreaLayoutGuide).inset(16)
            make.size.equalTo(44)
        }
        
        layoutIfNeeded()
        updateOverlayMask()
    }
    
    /// 화면 레이아웃이 끝난 직후에 호출됩니다.
    override func layoutSubviews() {
        super.layoutSubviews()
        // Autolayout 결과가 반영된 후 각 뷰의 frame이 확정되므로
        overlayView.layoutIfNeeded()
        cropAreaView.layoutIfNeeded()
        updateOverlayMask()
    }

    /// Updates the mask overlay around the crop area
    func updateOverlayMask() {
        let path = UIBezierPath(rect: overlayView.bounds)
        let frameInOverlay = overlayView.convert(cropAreaView.frame, from: cropAreaView.superview)
        path.append(UIBezierPath(rect: frameInOverlay).reversing())
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        overlayView.layer.mask = mask
    }

    /// Applies the given aspect ratio selection to crop area constraints
    func applyRatio(_ ratio: String) {
        cropAreaView.snp.remakeConstraints { make in
            make.center.equalTo(imageView)
            switch ratio {
            case "1:1":
                make.width.equalTo(imageView.snp.width).multipliedBy(0.8)
                make.height.equalTo(cropAreaView.snp.width)
            case "3:4":
                make.width.equalTo(imageView.snp.width).multipliedBy(0.6)
                make.height.equalTo(cropAreaView.snp.width).multipliedBy(4.0/3.0)
            case "4:3":
                make.width.equalTo(imageView.snp.width).multipliedBy(0.8)
                make.height.equalTo(cropAreaView.snp.width).multipliedBy(3.0/4.0)
            case "9:16":
                make.width.equalTo(imageView.snp.width).multipliedBy(0.5)
                make.height.equalTo(cropAreaView.snp.width).multipliedBy(16.0/9.0)
            case "16:9":
                make.width.equalTo(imageView.snp.width).multipliedBy(0.9)
                make.height.equalTo(cropAreaView.snp.width).multipliedBy(9.0/16.0)
            case "Fit":
                make.edges.equalTo(imageView).inset(8)
//            case "Free":
//                make.size.equalTo(cropAreaView.frame.size)
            default:
                break
            }
        }
        layoutIfNeeded()
        updateOverlayMask()
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//        guard ratioControl.selectedSegmentIndex == ratioOptions.firstIndex(of: "Free") else { return }
        
        let translation = gesture.translation(in: self)
        let newCenter = CGPoint(x: cropAreaView.center.x + translation.x,
                              y: cropAreaView.center.y + translation.y)
        
        // 이미지의 실제 표시 영역 가져오기
        let imageFrame = imageDisplayFrame()
        
        // 크롭 영역이 이미지 표시 영역을 벗어나지 않도록 제한
        let minX = imageFrame.minX + cropAreaView.frame.width/2
        let maxX = imageFrame.maxX - cropAreaView.frame.width/2
        let minY = imageFrame.minY + cropAreaView.frame.height/2
        let maxY = imageFrame.maxY - cropAreaView.frame.height/2
        
        // 새로운 중심점이 이미지 표시 영역 내에 있도록 제한
        let constrainedCenter = CGPoint(
            x: min(maxX, max(minX, newCenter.x)),
            y: min(maxY, max(minY, newCenter.y))
        )
        
        cropAreaView.center = constrainedCenter
        gesture.setTranslation(.zero, in: self)
        updateOverlayMask()
    }
}

// CropImageView.swift 에 추가
extension CropImageView {
  /// aspectFit된 이미지가 실제로 차지하는 CGRect를 반환
  func imageContentFrame() -> CGRect {
    guard let img = imageView.image else { return .zero }
    let ivSize  = imageView.bounds.size
    let imgSize = img.size
    // 화면에 완전히 들어가도록 하는 스케일
    let scale = min(ivSize.width / imgSize.width,
                    ivSize.height / imgSize.height)
    let w = imgSize.width  * scale
    let h = imgSize.height * scale
    // imageView.frame 기준으로 좌표 보정
    let x = imageView.frame.minX + (ivSize.width  - w) / 2
    let y = imageView.frame.minY + (ivSize.height - h) / 2
    return CGRect(x: x, y: y, width: w, height: h)
  }
}

extension CropImageView {
    /// 이미지가 실제로 표시되는 영역의 CGRect를 반환
    func imageDisplayFrame() -> CGRect {
        guard let image = imageView.image else { return .zero }
        
        let imageSize = image.size
        let viewSize = imageView.bounds.size
        
        // 이미지의 실제 표시 크기 계산
        let scale = min(viewSize.width / imageSize.width,
                       viewSize.height / imageSize.height)
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        // 이미지가 중앙에 표시되도록 좌표 계산
        let x = imageView.frame.minX + (viewSize.width - scaledWidth) / 2
        let y = imageView.frame.minY + (viewSize.height - scaledHeight) / 2
        
        return CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
    }
    
    /// 주어진 좌표가 이미지 표시 영역 내에 있는지 확인
    func isPointInImage(_ point: CGPoint) -> Bool {
        return imageDisplayFrame().contains(point)
    }
    
    /// 이미지 표시 영역 내의 좌표를 이미지 좌표계로 변환
    func convertToImageCoordinates(_ point: CGPoint) -> CGPoint {
        let displayFrame = imageDisplayFrame()
        guard let image = imageView.image else { return .zero }
        
        // 이미지 표시 영역 내의 상대적 위치 계산
        let relativeX = (point.x - displayFrame.minX) / displayFrame.width
        let relativeY = (point.y - displayFrame.minY) / displayFrame.height
        
        // 이미지 좌표계로 변환
        return CGPoint(
            x: relativeX * image.size.width,
            y: relativeY * image.size.height
        )
    }
}
