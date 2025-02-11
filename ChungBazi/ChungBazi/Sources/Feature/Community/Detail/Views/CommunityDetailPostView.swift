//
//  CommunityDetailPostView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class CommunityDetailPostView: UIView {
    
    private let profileView = CommunityDetailPostAuthoreProfileView()
    private var imageUrls: [String] = []
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .ptdSemiBoldFont(ofSize: 16)
    }
    private let contentLabel = UILabel().then {
        $0.textColor = .gray800
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.numberOfLines = 0
    }
    
    private let photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 131, height: 131)
        layout.minimumInteritemSpacing = 7
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 0, left: Constants.gutter, bottom: 0, right: Constants.gutter)
        $0.showsHorizontalScrollIndicator = false
        $0.register(CommunityWritePhotoCell.self, forCellWithReuseIdentifier: "CommunityWritePhotoCell")
    }
    
    private var isLiked: Bool = false
    private let likeButton = UIButton.createWithImage(
        image: UIImage.likeIcon.withRenderingMode(.alwaysOriginal),
        target: self,
        action: #selector(likeBtnTapped)
    )
    private let likeCountLabel = UILabel().then {
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    private let commentCountLabel = UILabel().then {
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    private let viewCountLabel = UILabel().then {
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(profileView, titleLabel, contentLabel, photoCollectionView, likeButton, likeCountLabel, commentCountLabel, viewCountLabel)
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(14)
            $0.leading.trailing.equalTo(profileView)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(profileView)
        }
        photoCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(contentLabel.snp.bottom).offset(23)
            $0.height.equalTo(131)
        }
        likeButton.snp.makeConstraints {
            $0.top.equalTo(photoCollectionView.snp.bottom).offset(26)
            $0.bottom.leading.equalToSuperview().inset(Constants.gutter)
        }
        likeCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.leading.equalTo(likeButton.snp.trailing).offset(5)
        }
        commentCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.trailing.equalTo(viewCountLabel.snp.leading).offset(-16)
        }
        viewCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
    }
    
    @objc private func likeBtnTapped() {
        isLiked.toggle()
        let image = isLiked ? UIImage.likeSelectedIcon.withRenderingMode(.alwaysOriginal)
                            : UIImage.likeIcon.withRenderingMode(.alwaysOriginal)
        likeButton.setImage(image, for: .normal)
    }
    
    func configure(with post: CommunityDetailPostModel) {
        profileView.configure(userName: post.userName, userLevel: post.reward, characterImageUrl: post.characterImg, createdAt: post.formattedCreatedAt)
        titleLabel.text = post.title
        contentLabel.text = post.content
        likeCountLabel.text = "좋아요 \(post.postLikes)"
        commentCountLabel.text = "댓글 \(post.commentCount)"
        viewCountLabel.text = "조회 \(post.views)"
        
        imageUrls = post.imageUrls ?? []
        
        let hasImages = !imageUrls.isEmpty
        photoCollectionView.isHidden = !hasImages
        
        if hasImages {
            photoCollectionView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.top.equalTo(contentLabel.snp.bottom).offset(23)
                $0.height.equalTo(131)
            }
            
            likeButton.snp.remakeConstraints {
                $0.top.equalTo(photoCollectionView.snp.bottom).offset(26)
                $0.bottom.leading.equalToSuperview().inset(Constants.gutter)
            }
        } else {
            likeButton.snp.remakeConstraints {
                $0.top.equalTo(contentLabel.snp.bottom).offset(26)
                $0.bottom.leading.equalToSuperview().inset(Constants.gutter)
            }
        }
        
        layoutIfNeeded()

        DispatchQueue.main.async {
            self.photoCollectionView.reloadData()
        }
    }
}

extension CommunityDetailPostView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityWritePhotoCell", for: indexPath) as! CommunityWritePhotoCell
        if let url = URL(string: imageUrls[indexPath.item]) {
            cell.configure(with: url, showDeleteButton: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoViewerVC = CommunityPhotoViewController(imageUrls: imageUrls, initialIndex: indexPath.item)
        photoViewerVC.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController?.present(photoViewerVC, animated: true, completion: nil)
    }
}
