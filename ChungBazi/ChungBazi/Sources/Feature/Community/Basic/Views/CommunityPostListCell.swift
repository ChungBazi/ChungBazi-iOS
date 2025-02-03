//
//  CommunityPostListCell.swift
//  ChungBazi
//
//  Created by 신호연 on 2/3/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class CommunityPostListCell: UICollectionViewCell {
    
    private let profileView = UIView()
    private let characterImgView = UIImageView().then {
        $0.backgroundColor = .green300
        $0.contentMode = .scaleAspectFill
    }
    private let userNameLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
    }
    private let userLevelLabel = UILabel().then {
        $0.font = .ptdBoldFont(ofSize: 16)
        $0.textColor = .gray300
    }
    private let createdAtLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray300
    }
    
    private let postContentView = UIView()
    private let categoryLabel = UILabel().then {
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .blue700
    }
    private let postTitleLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .black
    }
    private let contentLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }
    private let thumbnailImgView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.createRoundedView()
    }
    
    private let socialInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 14
        $0.alignment = .leading
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupSocialInfoStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(profileView, postContentView, socialInfoStackView)
        
        profileView.addSubviews(characterImgView, userNameLabel, userLevelLabel, createdAtLabel)
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(17)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(33)
        }
        characterImgView.layer.cornerRadius = 16.5
        characterImgView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(33)
        }
        userNameLabel.snp.makeConstraints {
            $0.leading.equalTo(characterImgView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
        userLevelLabel.snp.makeConstraints {
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(5)
            $0.centerY.equalToSuperview()
        }
        createdAtLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        postContentView.addSubviews(categoryLabel, postTitleLabel, contentLabel, thumbnailImgView)
        postContentView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        categoryLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        postTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(categoryLabel)
            $0.leading.equalTo(categoryLabel.snp.trailing).offset(5)
            $0.trailing.equalTo(thumbnailImgView.snp.leading).inset(8)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(postTitleLabel)
        }
        thumbnailImgView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(66)
        }
        
        socialInfoStackView.snp.makeConstraints {
            $0.top.equalTo(postContentView.snp.bottom).offset(14)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().inset(17)
        }
    }
    
    private func setupSocialInfoStackView() {
        let likeText = B14_M(text: "좋아요", textColor: .gray500)
        let firstSeparatedLineView = createSeparatedLineView()
        let commentCountText = B14_M(text: "댓글", textColor: .gray500)
        let secondSeparatedLineView = createSeparatedLineView()
        let viewsText = B14_M(text: "조회", textColor: .gray500)

        socialInfoStackView.addArrangedSubview(likeText)
        socialInfoStackView.addArrangedSubview(firstSeparatedLineView)
        socialInfoStackView.addArrangedSubview(commentCountText)
        socialInfoStackView.addArrangedSubview(secondSeparatedLineView)
        socialInfoStackView.addArrangedSubview(viewsText)
    }
    
    private func createSeparatedLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = .gray300
        view.heightAnchor.constraint(equalToConstant: 14).isActive = true
        view.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
    
    func configure(with post: CommunityPost) {
        userNameLabel.text = post.userName
        createdAtLabel.text = post.formattedCreatedAt
        categoryLabel.text = post.category.displayName
        postTitleLabel.text = post.title
        contentLabel.text = post.content
        
        // FIXME: - 프로필 이미지 형식에 따라 코드 수정 필요
        let defaultProfileImage = UIImage(named: "basicBaro")
        if let imageUrl = post.characterImg, !imageUrl.isEmpty {
            characterImgView.kf.setImage(with: URL(string: imageUrl), placeholder: defaultProfileImage)
        } else {
            characterImgView.image = defaultProfileImage
        }

        if let thumbnailUrl = post.thumbnailUrl, let url = URL(string: thumbnailUrl) {
            thumbnailImgView.kf.setImage(with: url)
        } else {
            thumbnailImgView.image = nil
        }
    }
}
