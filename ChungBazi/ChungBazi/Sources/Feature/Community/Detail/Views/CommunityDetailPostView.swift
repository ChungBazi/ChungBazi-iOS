//
//  CommunityDetailPostView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import Then

final class CommunityDetailPostView: UIView {
    
    private let profileView = CommunityDetailPostAuthoreProfileView()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .ptdSemiBoldFont(ofSize: 16)
    }
    private let contentLabel = UILabel().then {
        $0.textColor = .gray800
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    
    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 131, height: 131)
        layout.minimumInteritemSpacing = 7
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Constants.gutter, bottom: 0, right: Constants.gutter)
        return collectionView
    }()
    
    private let likeButton = UIButton.createWithImage(image: .likeIcon, target: self, action: #selector(likeBtnTapped))
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
        }
        likeButton.snp.makeConstraints {
            $0.top.equalTo(photoCollectionView.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(Constants.gutter)
        }
        likeCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.leading.equalTo(likeButton.snp.trailing).offset(5)
        }
        commentCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.trailing.equalTo(viewCountLabel.snp.trailing).offset(16)
        }
        viewCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.trailing.equalToSuperview().offset(Constants.gutter)
        }
    }
    
    @objc private func likeBtnTapped() {
        
    }
    
    func configure(with post: CommunityDetailPostModel) {
        profileView.configure(userName: post.userName, userLevel: post.reward, characterImageUrl: post.characterImg, createdAt: post.formattedCreatedAt)
        titleLabel.text = post.title
        contentLabel.text = post.content
        likeCountLabel.text = "\(post.postLikes)"
        commentCountLabel.text = "\(post.commentCount)"
        viewCountLabel.text = "\(post.views)"
    }
}
