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

// MARK: - CropImageViewController
/// 여러 장의 이미지를 순차적으로 크롭해서 델리게이트로 전달하는 컨트롤러
final class CropImageViewController: UIViewController {
    // 델리게이트
    weak var delegate: CropImageViewControllerDelegate?
    
    // 순차 처리할 이미지 배열
    var imagesToCrop: [UIImage] = []
    private var currentIndex = 0
    
    // 현재 크롭할 이미지
    var imageToCrop: UIImage {
        get { return imagesToCrop[currentIndex] }
        set { imagesToCrop[currentIndex] = newValue }
    }
    
    // 마지막 이미지 여부
    var isLastImage: Bool {
        return currentIndex == imagesToCrop.count - 1
    }
    
    // 현재 회전 각도 (90도 단위)
    private var currentRotation: CGFloat = 0
    
    // 뷰 & 제스처
    private let cropView = CropImageView()
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var imageViewFrame: CGRect = .zero

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 반드시 이미지가 하나 이상 세팅되어 있어야 함
        assert(!imagesToCrop.isEmpty, "imagesToCrop에 최소 한 장의 이미지를 넣어주세요.")
        
        view.addSubview(cropView)
        cropView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 첫 이미지 표시
        cropView.imageView.image = imageToCrop
        
        // 버튼·컨트롤 액션
        cropView.ratioControl.addTarget(self, action: #selector(ratioChanged), for: .valueChanged)
        cropView.cancelButton.addTarget(self, action: #selector(cancelTapped),   for: .touchUpInside)
        cropView.cropButton.addTarget(self,   action: #selector(cropTapped),     for: .touchUpInside)
        cropView.rotateLeftButton.addTarget(self, action: #selector(rotateLeftTapped), for: .touchUpInside)
        cropView.rotateRightButton.addTarget(self, action: #selector(rotateRightTapped), for: .touchUpInside)
        
        // pan/pinch 제스처 설정
        setupGestures()
        
        // 초기 비율 적용
        cropView.applyRatio(cropView.ratioOptions.first!)
        
        // imageView.frame을 저장해 두기
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageViewFrame = self.cropView.imageView.frame
            self.cropView.updateOverlayMask()
        }
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        
        cropView.cropAreaView.addGestureRecognizer(panGesture)
        cropView.cropAreaView.addGestureRecognizer(pinchGesture)
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

    // MARK: - Pan 제스처 (이동)
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: cropView)
        let newCenter = CGPoint(x: cropView.cropAreaView.center.x + translation.x,
                                y: cropView.cropAreaView.center.y + translation.y)
        
        // 이미지의 실제 표시 영역 가져오기
        let imageFrame = cropView.imageDisplayFrame()
        
        // 크롭 영역이 이미지 표시 영역을 벗어나지 않도록 제한
        let minX = imageFrame.minX + cropView.cropAreaView.frame.width/2
        let maxX = imageFrame.maxX - cropView.cropAreaView.frame.width/2
        let minY = imageFrame.minY + cropView.cropAreaView.frame.height/2
        let maxY = imageFrame.maxY - cropView.cropAreaView.frame.height/2
        
        // 새로운 중심점이 이미지 표시 영역 내에 있도록 제한
        let constrainedCenter = CGPoint(
            x: min(maxX, max(minX, newCenter.x)),
            y: min(maxY, max(minY, newCenter.y))
        )
        
        cropView.cropAreaView.center = constrainedCenter
        gesture.setTranslation(.zero, in: cropView)
        cropView.updateOverlayMask()
    }

    // MARK: - Pinch 제스처 (확대/축소)
    @objc private func handlePinch(_ gr: UIPinchGestureRecognizer) {
        let scale = gr.scale
        let area = cropView.cropAreaView
        
        // 현재 크롭 영역의 크기
        let currentWidth = area.frame.width
        let currentHeight = area.frame.height
        
        // 새로운 크기 계산
        let newWidth = currentWidth * scale
        let newHeight = currentHeight * scale
        
        // 이미지의 실제 표시 영역 가져오기
        let imageFrame = cropView.imageDisplayFrame()
        
        // 크롭 영역의 중심점
        let center = area.center
        
        // 새로운 크롭 영역의 프레임 계산
        let newFrame = CGRect(
            x: center.x - newWidth/2,
            y: center.y - newHeight/2,
            width: newWidth,
            height: newHeight
        )
        
        // 이미지 표시 영역을 벗어나는지 확인
        let isOutOfBounds = newFrame.minX < imageFrame.minX ||
                           newFrame.maxX > imageFrame.maxX ||
                           newFrame.minY < imageFrame.minY ||
                           newFrame.maxY > imageFrame.maxY
        
        // 최소 크기 제한
        let minSize: CGFloat = 50
        
        // 축소는 항상 허용, 확대는 이미지 영역을 벗어나지 않는 경우에만 허용
        if (scale < 1.0 || !isOutOfBounds) && newWidth >= minSize && newHeight >= minSize {
            area.transform = area.transform.scaledBy(x: scale, y: scale)
        }
        
        gr.scale = 1
        cropView.updateOverlayMask()
    }

    // MARK: - 취소
    @objc private func cancelTapped() {
        delegate?.cropImageViewControllerDidCancel(self)
    }

    // MARK: - 크롭 & 다음 이미지 처리
    @objc private func cropTapped() {
        guard let cgImage = imageToCrop.cgImage else { return }
        
        // 1) 실제 이미지가 그려진 프레임
        let contentFrame = cropView.imageContentFrame()
        // 2) 크롭 영역 프레임
        let cropFrame    = cropView.cropAreaView.frame
        // 3) 상대 좌표 계산
        let originX = cropFrame.minX - contentFrame.minX
        let originY = cropFrame.minY - contentFrame.minY
        // 4) 스케일
        let scaleX = imageToCrop.size.width  / contentFrame.width
        let scaleY = imageToCrop.size.height / contentFrame.height
        // 5) cropping Rect
        let rect = CGRect(
            x:      originX * scaleX,
            y:      originY * scaleY,
            width:  cropFrame.width  * scaleX,
            height: cropFrame.height * scaleY
        )
        
        // 6) 잘라내기
        guard let croppedCG = cgImage.cropping(to: rect) else { return }
        let cropped = UIImage(
            cgImage:       croppedCG,
            scale:         imageToCrop.scale,
            orientation:   imageToCrop.imageOrientation
        )
        
        // 7) 델리게이트 호출
        delegate?.cropImageViewController(self, didCrop: cropped)
        
        // 8) 다음 이미지 or dismiss
        if currentIndex < imagesToCrop.count - 1 {
            currentIndex += 1
            cropView.ratioControl.selectedSegmentIndex = 0
            cropView.imageView.image = imageToCrop
            cropView.applyRatio(cropView.ratioOptions.first!)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.imageViewFrame = self.cropView.imageView.frame
                self.cropView.updateOverlayMask()
            }
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - 회전 관련 메서드
    @objc private func rotateLeftTapped() {
        rotateImage(degrees: -90)
    }
    
    @objc private func rotateRightTapped() {
        rotateImage(degrees: 90)
    }
    
    private func rotateImage(degrees: CGFloat) {
        currentRotation += degrees
        if currentRotation >= 360 { currentRotation -= 360 }
        if currentRotation < 0 { currentRotation += 360 }
        
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

// 이 파일에 dragResize가 필요하다면, 그대로 붙여넣으세요.
// private func dragResize(…)
// …

// MARK: - UIImage Extension
extension UIImage {
    func rotated(by degrees: CGFloat) -> UIImage {
        let radians = degrees * .pi / 180
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        
        UIGraphicsBeginImageContext(rotatedSize)
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

