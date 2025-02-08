//
//  CommunityWritePhotoCell.swift
//  ChungBazi
//
//  Created by 신호연 on 2/4/25.
//

import UIKit
import SnapKit
import Then

final class CommunityWritePhotoCell: UICollectionViewCell {
    
    private let photoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    private let xButtonContainerView = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0.7)
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.clipsToBounds = true
    }
    private let xButton = UIButton.createWithImage(image: .xIcon)
    var onDeleteTapped: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(photoImageView, xButtonContainerView)
        photoImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        xButtonContainerView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(33)
        }
        xButtonContainerView.addSubview(xButton)
        xButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(5)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with image: UIImage, index: Int, onDelete: @escaping (Int) -> Void) {
        photoImageView.image = image
        onDeleteTapped = onDelete
        xButton.tag = index
        xButton.addTarget(self, action: #selector(handleDeleteTap), for: .touchUpInside)
    }
    
    @objc private func handleDeleteTap() {
        onDeleteTapped?(xButton.tag)
    }
    
    func configure(with url: URL) {
        photoImageView.kf.setImage(with: url)
    }
}
