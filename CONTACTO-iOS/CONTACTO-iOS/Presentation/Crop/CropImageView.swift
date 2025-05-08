//
//  CropImageView.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/24/25.
//
import UIKit
import SnapKit
import Then

// MARK: - CropImageView
final class CropImageView: UIView {
    // MARK: Constants
    private enum Constants {
        static let minCropSize: CGFloat = 50
    }

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
        $0.addTarget(self, action: #selector(ratioChanged(_:)), for: .valueChanged)
    }
    let cancelButton = UIButton(type: .system).then { $0.setTitle("Cancel", for: .normal) }
    let cropButton = UIButton(type: .system).then { $0.setTitle("Crop", for: .normal) }
    let rotateLeftButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "rotate.left"), for: .normal)
        $0.tintColor = .white
    }
    let rotateRightButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "rotate.right"), for: .normal)
        $0.tintColor = .white
    }

    // MARK: State
    private var currentRatio: String = "1:1"

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        addPanGesture()
        addPinchGesture()
        // initial layout
        applyRatio(currentRatio)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        addPanGesture()
        addPinchGesture()
        applyRatio(currentRatio)
    }

    private func setupSubviews() {
        backgroundColor = .black
        addSubviews(imageView, overlayView, cropAreaView,
                    ratioControl, cancelButton, cropButton,
                    rotateLeftButton, rotateRightButton)

        // Static layout with SnapKit
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(ratioControl.snp.top).offset(-16)
        }
        overlayView.snp.makeConstraints { make in make.edges.equalTo(imageView) }
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
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Only update mask here (don't reset frame)
        updateOverlayMask()
    }

    /// Handle ratio change and initial layout
    func applyRatio(_ ratio: String) {
        currentRatio = ratio
        // Recalculate crop frame
        layoutCropArea()
        updateOverlayMask()
    }

    @objc private func ratioChanged(_ sender: UISegmentedControl) {
        let ratio = ratioOptions[sender.selectedSegmentIndex]
        applyRatio(ratio)
    }

    private func layoutCropArea() {
        guard imageView.image != nil else { return }
        let imgFrame = imageDisplayFrame()
        let margin: CGFloat = 8
        let boxSize: CGSize
        switch currentRatio {
        case "1:1":
            let w = imgFrame.width * 0.8
            boxSize = CGSize(width: w, height: w)
        case "3:4":
            let w = imgFrame.width * 0.6
            boxSize = CGSize(width: w, height: w * 4/3)
        case "4:3":
            let w = imgFrame.width * 0.8
            boxSize = CGSize(width: w, height: w * 3/4)
        case "9:16":
            let w = imgFrame.width * 0.5
            boxSize = CGSize(width: w, height: w * 16/9)
        case "16:9":
            let w = imgFrame.width * 0.9
            boxSize = CGSize(width: w, height: w * 9/16)
        case "Fit":
            boxSize = CGSize(width: imgFrame.width - 2 * margin,
                             height: imgFrame.height - 2 * margin)
        default:
            return
        }
        cropAreaView.frame = CGRect(
            x: imgFrame.midX - boxSize.width / 2,
            y: imgFrame.midY - boxSize.height / 2,
            width: boxSize.width,
            height: boxSize.height
        )
    }

    // MARK: - Pan Gesture
    private func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        cropAreaView.addGestureRecognizer(pan)
    }
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        var newCenter = CGPoint(x: cropAreaView.center.x + translation.x,
                                y: cropAreaView.center.y + translation.y)
        let imgFrame = imageDisplayFrame()
        let halfW = cropAreaView.bounds.width / 2
        let halfH = cropAreaView.bounds.height / 2
        newCenter.x = min(max(imgFrame.minX + halfW, newCenter.x),
                          imgFrame.maxX - halfW)
        newCenter.y = min(max(imgFrame.minY + halfH, newCenter.y),
                          imgFrame.maxY - halfH)
        cropAreaView.center = newCenter
        gesture.setTranslation(.zero, in: self)
        updateOverlayMask()
    }

    // MARK: - Pinch Gesture
    private func addPinchGesture() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        cropAreaView.addGestureRecognizer(pinch)
    }
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        let currentFrame = cropAreaView.frame
        let newWidth = currentFrame.width * scale
        let newHeight = currentFrame.height * scale
        let imgFrame = imageDisplayFrame()
        let center = CGPoint(x: currentFrame.midX, y: currentFrame.midY)
        let halfW = newWidth / 2
        let halfH = newHeight / 2
        // Check within bounds and min size
        let isWithinBounds = newWidth >= Constants.minCropSize &&
                             newHeight >= Constants.minCropSize &&
                             center.x - halfW >= imgFrame.minX &&
                             center.x + halfW <= imgFrame.maxX &&
                             center.y - halfH >= imgFrame.minY &&
                             center.y + halfH <= imgFrame.maxY
        if isWithinBounds {
            cropAreaView.frame = CGRect(
                x: center.x - halfW,
                y: center.y - halfH,
                width: newWidth,
                height: newHeight
            )
            updateOverlayMask()
        }
        gesture.scale = 1
    }

    // MARK: - Overlay Mask
    func updateOverlayMask() {
        let path = UIBezierPath(rect: overlayView.bounds)
        let frameInOverlay = overlayView.convert(cropAreaView.frame, from: self)
        path.append(UIBezierPath(rect: frameInOverlay).reversing())
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        overlayView.layer.mask = mask
    }
}

// MARK: - Helpers
extension CropImageView {
    /// 실제로 화면에 그려진 이미지 영역 계산
    func imageDisplayFrame() -> CGRect {
        guard let image = imageView.image else { return .zero }
        let imageSize = image.size
        let viewSize = imageView.bounds.size
        let scale = min(viewSize.width / imageSize.width,
                       viewSize.height / imageSize.height)
        let scaledW = imageSize.width * scale
        let scaledH = imageSize.height * scale
        let x = imageView.frame.minX + (viewSize.width - scaledW) / 2
        let y = imageView.frame.minY + (viewSize.height - scaledH) / 2
        return CGRect(x: x, y: y, width: scaledW, height: scaledH)
    }

    /// 화면 좌표 → 이미지 내부 좌표
    func convertToImageCoordinates(_ point: CGPoint) -> CGPoint {
        let frame = imageDisplayFrame()
        guard let image = imageView.image,
              frame.width > 0, frame.height > 0 else { return .zero }
        let relX = (point.x - frame.minX) / frame.width
        let relY = (point.y - frame.minY) / frame.height
        return CGPoint(x: max(0, min(1, relX)) * image.size.width,
                       y: max(0, min(1, relY)) * image.size.height)
    }
}
