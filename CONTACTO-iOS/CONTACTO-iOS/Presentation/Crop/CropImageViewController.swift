//
//  CropImageViewController.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/24/25.
//

import Foundation
import SnapKit
import Then
import PhotosUI

// MARK: - CropImageViewControllerDelegate
protocol CropImageViewControllerDelegate: AnyObject {
    func cropImageViewController(_ controller: CropImageViewController, didCrop image: UIImage)
    func cropImageViewControllerDidCancel(_ controller: CropImageViewController)
}

// MARK: - CropImageViewController
/// Controller that manages user interactions for cropping an image
final class CropImageViewController: UIViewController {
    weak var delegate: CropImageViewControllerDelegate?
    var imageToCrop: UIImage!
    var nextImage: UIImage?
    var isLastImage: Bool = true

    private let cropView = CropImageView()
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var imageViewFrame: CGRect = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cropView)
        cropView.snp.makeConstraints { make in make.edges.equalToSuperview() }

        cropView.imageView.image = imageToCrop
        cropView.ratioControl.addTarget(self, action: #selector(ratioChanged), for: .valueChanged)
        cropView.cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cropView.cropButton.addTarget(self, action: #selector(cropTapped), for: .touchUpInside)

        setupGestures()
        cropView.applyRatio(cropView.ratioOptions.first!)
        
        // 이미지 뷰의 프레임 저장
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageViewFrame = self.cropView.imageView.frame
        }
    }

    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        cropView.cropAreaView.addGestureRecognizer(panGesture)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        cropView.cropAreaView.addGestureRecognizer(pinchGesture)
    }

    @objc private func ratioChanged() {
        let ratio = cropView.ratioOptions[cropView.ratioControl.selectedSegmentIndex]
        cropView.applyRatio(ratio)
        
        // Fit 비율 선택 시 이미지 크기에 맞게 초기 크롭 영역 설정
        if ratio == "Fit" {
            let imageSize = imageToCrop.size
            let imageAspectRatio = imageSize.width / imageSize.height
            let viewAspectRatio = imageViewFrame.width / imageViewFrame.height
            
            var cropSize: CGSize
            if imageAspectRatio > viewAspectRatio {
                // 이미지가 뷰보다 가로로 더 긴 경우
                cropSize = CGSize(width: imageViewFrame.height * imageAspectRatio,
                                height: imageViewFrame.height)
            } else {
                // 이미지가 뷰보다 세로로 더 긴 경우
                cropSize = CGSize(width: imageViewFrame.width,
                                height: imageViewFrame.width / imageAspectRatio)
            }
            
            let cropOrigin = CGPoint(x: (imageViewFrame.width - cropSize.width) / 2,
                                   y: (imageViewFrame.height - cropSize.height) / 2)
            cropView.cropAreaView.frame = CGRect(origin: cropOrigin, size: cropSize)
            cropView.updateOverlayMask()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: cropView.imageView)
        let newCenter = CGPoint(x: cropView.cropAreaView.center.x + translation.x,
                              y: cropView.cropAreaView.center.y + translation.y)
        
        // 크롭 영역이 이미지 뷰를 벗어나지 않도록 제한
        let minX = cropView.cropAreaView.frame.width / 2
        let maxX = imageViewFrame.width - cropView.cropAreaView.frame.width / 2
        let minY = cropView.cropAreaView.frame.height / 2
        let maxY = imageViewFrame.height - cropView.cropAreaView.frame.height / 2
        
        let boundedX = min(max(newCenter.x, minX), maxX)
        let boundedY = min(max(newCenter.y, minY), maxY)
        
        cropView.cropAreaView.center = CGPoint(x: boundedX, y: boundedY)
        gesture.setTranslation(.zero, in: cropView.imageView)
        cropView.updateOverlayMask()
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        let newWidth = cropView.cropAreaView.frame.width * scale
        let newHeight = cropView.cropAreaView.frame.height * scale
        
        // 크롭 영역이 이미지 뷰를 벗어나지 않도록 제한
        let maxWidth = imageViewFrame.width
        let maxHeight = imageViewFrame.height
        
        if newWidth <= maxWidth && newHeight <= maxHeight {
            cropView.cropAreaView.transform = cropView.cropAreaView.transform.scaledBy(x: scale, y: scale)
        }
        
        gesture.scale = 1
        cropView.updateOverlayMask()
    }

    @objc private func cancelTapped() {
        delegate?.cropImageViewControllerDidCancel(self)
    }

    @objc private func cropTapped() {
        guard let image = imageToCrop, let cgImage = image.cgImage else { return }
        let frame = cropView.imageView.convert(cropView.cropAreaView.frame, from: cropView)
        let scale = max(cropView.imageView.frame.width / image.size.width,
                       cropView.imageView.frame.height / image.size.height)
        let rect = CGRect(x: (frame.origin.x - cropView.imageView.frame.minX)/scale,
                         y: (frame.origin.y - cropView.imageView.frame.minY)/scale,
                         width: frame.size.width/scale,
                         height: frame.size.height/scale)
        if let croppedCG = cgImage.cropping(to: rect) {
            let cropped = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
            
            // delegate 메서드를 호출하기 전에 dismiss를 먼저 실행
            if !isLastImage {
                dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.cropImageViewController(self, didCrop: cropped)
                }
            } else {
                delegate?.cropImageViewController(self, didCrop: cropped)
            }
        }
    }
    
    
}
