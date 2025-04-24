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
    let ratioOptions = ["1:1", "3:4", "4:3", "9:16", "16:9", "Fit", "Free"]
    lazy var ratioControl = UISegmentedControl(items: ratioOptions).then {
        $0.selectedSegmentIndex = 0
    }
    let cancelButton = UIButton(type: .system).then { $0.setTitle("Cancel", for: .normal) }
    let cropButton = UIButton(type: .system).then { $0.setTitle("Crop", for: .normal) }

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
        addSubviews(imageView, overlayView, cropAreaView, ratioControl, cancelButton, cropButton)
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
            case "Free":
                make.size.equalTo(cropAreaView.frame.size)
            default:
                break
            }
        }
        layoutIfNeeded()
        updateOverlayMask()
    }
}
