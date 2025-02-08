//
//  CommunityDetailCommentCell.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import Then

final class CommunityDetailCommentCell: UITableViewCell {
    
    static let identifier = "CommunityDetailCommentCell"
    
    private let profileView = CommunityDetailCommentAuthorProfileView()
    private let moreButton = UIButton.createWithImage(image: .moreIcon, tintColor: .gray300,  target: self, action: #selector(moreBtnTapped))
    private let commentLabel = UILabel().then {
        $0.textColor = .gray800
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    private let createdAtLabel = UILabel().then {
        $0.textColor = .gray300
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    private let likeButton = UIButton.createWithImage(image: .likeIcon, target: self, action: #selector(likeBtnTapped))
    private let likeCountLabel = UILabel().then {
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    private let commentButton = UIButton.createWithImage(image: .commentIcon, target: self, action: #selector(commentBtnTapped))
    private let commentCountLabel = UILabel().then {
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func setupUI() {
        addSubviews(profileView, moreButton, commentLabel, createdAtLabel, likeButton, likeCountLabel, commentButton, commentCountLabel)
        profileView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(profileView)
            $0.trailing.equalToSuperview()
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(20)
        }
        
        createdAtLabel.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints {
            $0.top.equalTo(createdAtLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
        }
        
        likeCountLabel.snp.makeConstraints {
            $0.leading.equalTo(likeButton.snp.trailing).offset(5)
            $0.centerY.equalTo(likeButton)
        }
        
        commentButton.snp.makeConstraints {
            $0.leading.equalTo(likeCountLabel.snp.trailing).offset(19)
            $0.centerY.equalTo(likeButton)
        }
        
        commentCountLabel.snp.makeConstraints {
            $0.leading.equalTo(commentButton.snp.trailing).offset(5)
            $0.centerY.equalTo(likeButton)
        }
    }
    
    @objc private func moreBtnTapped() {
        
    }
    
    @objc private func likeBtnTapped() {
        
    }
    
    @objc private func commentBtnTapped() {
        
    }
    
    func configure(with comment: CommunityDetailCommentModel) {
        profileView.configure(userName: comment.userName, userLevel: comment.reward, characterImageUrl: comment.characterImg)
        commentLabel.text = comment.content
        createdAtLabel.text = comment.formattedCreatedAt
    }
}
