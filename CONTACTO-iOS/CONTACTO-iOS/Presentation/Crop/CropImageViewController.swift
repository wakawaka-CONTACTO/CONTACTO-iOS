//
//  CropImageViewController.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/24/25.
//

import UIKit
import SnapKit
import Then
import PhotosUI

// MARK: - CropImageViewControllerDelegate
protocol CropImageViewControllerDelegate: AnyObject {
    func cropImageViewController(_ controller: CropImageViewController, didCrop image: UIImage)
    func cropImageViewControllerDidCancel(_ controller: CropImageViewController)
}

// MARK: - Constants
private enum Constants {
    static let minCropSize: CGFloat = 50
    static let rotationStep: CGFloat = 90
    static let fullRotation: CGFloat = 360
}

// MARK: - ImageProcessor
private final class ImageProcessor {
    static func crop(image: UIImage, cropFrame: CGRect, contentFrame: CGRect) -> UIImage {
        // 1) 이미지뷰 좌표계 → 이미지 내부 좌표계 변환
        let relativeFrame = CGRect(
            x: cropFrame.minX - contentFrame.minX,
            y: cropFrame.minY - contentFrame.minY,
            width: cropFrame.width,
            height: cropFrame.height
        )
        
        // 2) 원본 이미지 픽셀 단위로 매핑하기 위한 스케일
        let scaleX = image.size.width / contentFrame.width
        let scaleY = image.size.height / contentFrame.height
        
        // 3) 픽셀 좌표계로 변환된 크롭 영역
        let pixelCropRect = CGRect(
            x: relativeFrame.minX * scaleX,
            y: relativeFrame.minY * scaleY,
            width: relativeFrame.width * scaleX,
            height: relativeFrame.height * scaleY
        )
        
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale            // 원본 이미지 스케일 유지
        let pointSize = CGSize(
            width:  pixelCropRect.size.width  / image.scale,
            height: pixelCropRect.size.height / image.scale
        )
        let renderer = UIGraphicsImageRenderer(size: pointSize, format: format)

        let cropped = renderer.image { _ in
            let drawOrigin = CGPoint(
                x: -pixelCropRect.minX / image.scale,
                y: -pixelCropRect.minY / image.scale
            )
            image.draw(at: drawOrigin)
        }
        
        return cropped
        }
    }

// MARK: - GestureHandler
private final class GestureHandler {
    private let cropView: CropImageView
    private let imageViewFrame: CGRect
    
    init(cropView: CropImageView, imageViewFrame: CGRect) {
        self.cropView = cropView
        self.imageViewFrame = imageViewFrame
    }
    
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: cropView)
        let newCenter = CGPoint(
            x: cropView.cropAreaView.center.x + translation.x,
            y: cropView.cropAreaView.center.y + translation.y
        )
        
        let imageFrame = cropView.imageDisplayFrame()
        let constrainedCenter = constrainCenter(
            newCenter: newCenter,
            imageFrame: imageFrame,
            cropAreaSize: cropView.cropAreaView.frame.size
        )
        
        cropView.cropAreaView.center = constrainedCenter
        gesture.setTranslation(.zero, in: cropView)
        cropView.updateOverlayMask()
    }
    
    func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        let area = cropView.cropAreaView
        
        let newSize = calculateNewSize(
            currentSize: area.frame.size,
            scale: scale
        )
        
        let imageFrame = cropView.imageDisplayFrame()
        let center = area.center
        
        let newFrame = CGRect(
            x: center.x - newSize.width/2,
            y: center.y - newSize.height/2,
            width: newSize.width,
            height: newSize.height
        )
        
        if shouldApplyScale(
            scale: scale,
            newFrame: newFrame,
            imageFrame: imageFrame,
            minSize: Constants.minCropSize
        ) {
            area.transform = area.transform.scaledBy(x: scale, y: scale)
        }
        
        gesture.scale = 1
        cropView.updateOverlayMask()
    }
    
    private func constrainCenter(
        newCenter: CGPoint,
        imageFrame: CGRect,
        cropAreaSize: CGSize
    ) -> CGPoint {
        let minX = imageFrame.minX + cropAreaSize.width/2
        let maxX = imageFrame.maxX - cropAreaSize.width/2
        let minY = imageFrame.minY + cropAreaSize.height/2
        let maxY = imageFrame.maxY - cropAreaSize.height/2
        
        return CGPoint(
            x: min(maxX, max(minX, newCenter.x)),
            y: min(maxY, max(minY, newCenter.y))
        )
    }
    
    private func calculateNewSize(currentSize: CGSize, scale: CGFloat) -> CGSize {
        return CGSize(
            width: currentSize.width * scale,
            height: currentSize.height * scale
        )
    }
    
    private func shouldApplyScale(
        scale: CGFloat,
        newFrame: CGRect,
        imageFrame: CGRect,
        minSize: CGFloat
    ) -> Bool {
        let isOutOfBounds = newFrame.minX < imageFrame.minX ||
                           newFrame.maxX > imageFrame.maxX ||
                           newFrame.minY < imageFrame.minY ||
                           newFrame.maxY > imageFrame.maxY
        
        return (scale < 1.0 || !isOutOfBounds) &&
               newFrame.width >= minSize &&
               newFrame.height >= minSize
    }
}

// MARK: - CropImageViewController
/// 여러 장의 이미지를 순차적으로 크롭해서 델리게이트로 전달하는 컨트롤러
final class CropImageViewController: UIViewController {
    weak var delegate: CropImageViewControllerDelegate?
    
    var imagesToCrop: [UIImage] = []
    private var currentIndex = 0
    
    var imageToCrop: UIImage {
        get { return imagesToCrop[currentIndex] }
        set { imagesToCrop[currentIndex] = newValue }
    }
    
    var isLastImage: Bool {
        return currentIndex == imagesToCrop.count - 1
    }
    
    // 현재 회전 각도 (90도 단위)
    private var currentRotation: CGFloat = 0
    
    private let cropView = CropImageView()
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var imageViewFrame: CGRect = .zero
    
    private var gestureHandler: GestureHandler!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if imagesToCrop.isEmpty {
            showErrorAndHideView(message: "이미지를 불러오는 데 실패했습니다.")
            return
        }
        if imagesToCrop.count > 10 {
            showErrorAndHideView(message: "최대 10개의 이미지까지 업로드 가능합니다.")
            return
        }
        setupUI()
        setupGestures()
        setupInitialState()
    }
    
        private func showErrorAndHideView(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
        view.isHidden = true
    }
    
    private func setupUI() {
        view.addSubview(cropView)
        cropView.snp.makeConstraints { $0.edges.equalToSuperview() }
        cropView.imageView.image = imageToCrop
        
        setupButtonActions()
    }
    
    private func setupButtonActions() {
        cropView.ratioControl.addTarget(self, action: #selector(ratioChanged), for: .valueChanged)
        cropView.cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cropView.cropButton.addTarget(self, action: #selector(cropTapped), for: .touchUpInside)
        cropView.rotateLeftButton.addTarget(self, action: #selector(rotateLeftTapped), for: .touchUpInside)
        cropView.rotateRightButton.addTarget(self, action: #selector(rotateRightTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        
        cropView.cropAreaView.addGestureRecognizer(panGesture)
        cropView.cropAreaView.addGestureRecognizer(pinchGesture)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageViewFrame = self.cropView.imageView.frame
            self.gestureHandler = GestureHandler(
                cropView: self.cropView,
                imageViewFrame: self.imageViewFrame
            )
        }
    }
    
    private func setupInitialState() {
        cropView.applyRatio(cropView.ratioOptions.first!)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageViewFrame = self.cropView.imageView.frame
            self.cropView.updateOverlayMask()
        }
    }
    
    // MARK: - Ratio 변경
    @objc private func ratioChanged() {
        let ratio = cropView.ratioOptions[cropView.ratioControl.selectedSegmentIndex]
        cropView.applyRatio(ratio)
        
        // Fit 모드는 이미지 전체 영역 감싸기
        if ratio == "Fit" {
            let imageSize       = imageToCrop.size
            let imageAspect     = imageSize.width / imageSize.height
            let viewAspect      = imageViewFrame.width  / imageViewFrame.height
            let cropSize: CGSize
            
            if imageAspect > viewAspect {
                cropSize = CGSize(
                    width:  imageViewFrame.height * imageAspect,
                    height: imageViewFrame.height
                )
            } else {
                cropSize = CGSize(
                    width:  imageViewFrame.width,
                    height: imageViewFrame.width / imageAspect
                )
            }
            
            let origin = CGPoint(
                x: (imageViewFrame.width  - cropSize.width)  / 2,
                y: (imageViewFrame.height - cropSize.height) / 2
            )
            cropView.cropAreaView.frame = CGRect(origin: origin, size: cropSize)
            cropView.updateOverlayMask()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        gestureHandler.handlePan(gesture)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        gestureHandler.handlePinch(gesture)
    }

    @objc private func cancelTapped() {
        delegate?.cropImageViewControllerDidCancel(self)
    }

    @objc private func cropTapped() {
        let croppedImage = ImageProcessor.crop(
            image: imageToCrop,
            cropFrame: cropView.cropAreaView.frame,
            contentFrame: cropView.imageDisplayFrame()
        )
        
        delegate?.cropImageViewController(self, didCrop: croppedImage)
        
        if currentIndex < imagesToCrop.count - 1 {
            currentIndex += 1
            cropView.imageView.image = imageToCrop
            setupInitialState()
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func rotateLeftTapped() {
        rotateImage(degrees: -Constants.rotationStep)
    }
    
    @objc private func rotateRightTapped() {
        rotateImage(degrees: Constants.rotationStep)
    }
    
    private func rotateImage(degrees: CGFloat) {
        currentRotation += degrees
        if currentRotation >= Constants.fullRotation { currentRotation -= Constants.fullRotation }
        if currentRotation < 0 { currentRotation += Constants.fullRotation }
        
        let rotatedImage = imageToCrop.rotated(by: degrees)
        imageToCrop = rotatedImage
        cropView.imageView.image = rotatedImage
        
        // 회전 후 크롭 영역 재설정
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageViewFrame = self.cropView.imageView.frame
            self.cropView.updateOverlayMask()
        }
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func rotated(by degrees: CGFloat) -> UIImage {
        let radians = degrees * .pi / 180
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, self.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            context.rotate(by: radians)
            draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
            
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return rotatedImage ?? self
        }
        return self
    }
}

extension CGSize {
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width  / rhs,
                      height: lhs.height / rhs)
    }
}
