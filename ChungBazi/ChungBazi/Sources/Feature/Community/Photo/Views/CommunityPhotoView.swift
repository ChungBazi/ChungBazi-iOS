//
//  CommunityPhotoView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/11/25.
//

import UIKit
import SnapKit
import Then

protocol CommunityPhotoViewDelegate: AnyObject {
    func closeButtonTapped()
}

final class CommunityPhotoView: UIView {
    
    weak var delegate: CommunityPhotoViewDelegate?
    
    private var imageUrls: [String] = []
    private var currentIndex: Int = 0
    
    private let collectionView: UICollectionView
    private let countImageLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 16)
    }
    private let xButton = UIButton.createWithImage(
        image: .xIcon,
        tintColor: .white,
        target: self,
        action: #selector(xButtonTapped)
    )
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 0
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.isPagingEnabled = true
        
        super.init(frame: frame)
        
        setupUI()
        collectionView.register(CommunityPhotoViewerCell.self, forCellWithReuseIdentifier: "CommunityPhotoViewerCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(collectionView)
        addSubview(xButton)
        addSubview(countImageLabel)
        
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        xButton.snp.makeConstraints {
            $0.centerY.equalTo(countImageLabel)
            $0.leading.equalToSuperview().offset(28)
            $0.width.height.equalTo(24)
        }
        
        countImageLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            $0.centerX.equalToSuperview()
        }
    }
    
    func configure(images: [String], initialIndex: Int) {
        self.imageUrls = images
        self.currentIndex = initialIndex
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: initialIndex, section: 0), at: .centeredHorizontally, animated: false)
        updateImageCountLabel()
    }
    
    private func updateImageCountLabel() {
        countImageLabel.text = "\(currentIndex + 1) / \(imageUrls.count)"
    }
    
    @objc private func xButtonTapped() {
        delegate?.closeButtonTapped()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CommunityPhotoView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityPhotoViewerCell", for: indexPath) as? CommunityPhotoViewerCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: imageUrls[indexPath.item])
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        currentIndex = pageIndex
        updateImageCountLabel()
    }
}
