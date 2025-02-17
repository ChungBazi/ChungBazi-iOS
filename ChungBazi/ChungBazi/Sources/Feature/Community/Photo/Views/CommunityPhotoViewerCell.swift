//
//  CommunityPhotoViewerCell.swift
//  ChungBazi
//
//  Created by 신호연 on 2/11/25.
//

import UIKit
import SnapKit
import Kingfisher

final class CommunityPhotoViewerCell: UICollectionViewCell, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.delegate = self
        scrollView.backgroundColor = .black

        imageView.isUserInteractionEnabled = true
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func setupGestureRecognizers() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
    }
    
    func configure(with imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    self.updateImageViewSize(image: value.image)
                case .failure(let error):
                    print("❌ 이미지 로딩 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateImageViewSize(image: UIImage) {
        let imageRatio = image.size.width / image.size.height
        let screenWidth = UIScreen.main.bounds.width
        let targetHeight = screenWidth / imageRatio

        imageView.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(screenWidth)
            $0.height.equalTo(targetHeight)
        }

        layoutIfNeeded()
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let zoomRect = zoomRectForScale(scale: 2.0, center: gesture.location(in: gesture.view))
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        let width = scrollView.frame.width / scale
        let height = scrollView.frame.height / scale
        return CGRect(
            x: center.x - width / 2.0,
            y: center.y - height / 2.0,
            width: width,
            height: height
        )
    }

    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
