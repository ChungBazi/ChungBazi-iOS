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
    
    private let profileView = CommunityDetailCommentAuthorProfileView()
    
    private let createdAtLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray300
    }
    
    private let postContentView = UIView()
    private let categoryLabel = UILabel().then {
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .blue700
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let postTitleLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.lineBreakMode = .byCharWrapping
    }
    private let contentLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
        $0.numberOfLines = 0
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
  
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray100
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
        addSubviews(profileView, createdAtLabel, postContentView, socialInfoStackView)
        
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(17)
            $0.leading.equalToSuperview()
            $0.height.equalTo(33)
        }
        
        createdAtLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(profileView)
        }
        
        postContentView.addSubviews(categoryLabel, postTitleLabel, contentLabel, thumbnailImgView)
        postContentView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(contentLabel.snp.bottom)
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
        
        addSubviews(separatorView)
        separatorView.snp.makeConstraints {
            $0.top.equalTo(socialInfoStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
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
    
    func configure(with post: CommunityPost, isLastCell: Bool) {
        profileView.configure(
            userName: post.userName,
            userLevel: "Lv.\(post.reward.replacingOccurrences(of: "LEVEL_", with: ""))",
            characterImageUrl: post.characterImg
        )
        
        createdAtLabel.text = post.formattedCreatedAt
        categoryLabel.text = post.category.displayName
        
        postTitleLabel.text = post.title
        contentLabel.text = post.content
        
        let likeText = "좋아요 \(post.postLikes)"
        let commentText = "댓글 \(post.commentCount)"
        let viewText = "조회 \(post.views)"
        
        socialInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        socialInfoStackView.addArrangedSubview(createSocialLabel(text: likeText))
        socialInfoStackView.addArrangedSubview(createSeparatedLineView())
        socialInfoStackView.addArrangedSubview(createSocialLabel(text: commentText))
        socialInfoStackView.addArrangedSubview(createSeparatedLineView())
        socialInfoStackView.addArrangedSubview(createSocialLabel(text: viewText))
        
        if let thumbnailUrl = post.thumbnailUrl, !thumbnailUrl.isEmpty, let url = URL(string: thumbnailUrl) {
            let processor = DownsamplingImageProcessor(size: thumbnailImgView.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 10)
            thumbnailImgView.kf.indicatorType = .activity
            thumbnailImgView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"), // 기본 이미지 설정
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.3)), // 부드러운 페이드 효과
                    .cacheOriginalImage
                ],
                completionHandler: { result in
                    switch result {
                    case .success(let value):
                        print("✅ 썸네일 로드 성공: \(value.source.url?.absoluteString ?? "")")
                    case .failure(let error):
                        print("❌ 썸네일 로드 실패: \(error.localizedDescription)")
                    }
                }
            )
        } else {
            thumbnailImgView.image = UIImage(named: "placeholder") // 기본 이미지 설정
        }
        
        separatorView.isHidden = isLastCell
        
        contentLabel.sizeToFit()
        layoutIfNeeded()
    }
    
    private func createSocialLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .ptdMediumFont(ofSize: 14)
        label.textColor = .gray500
        return label
    }
}
