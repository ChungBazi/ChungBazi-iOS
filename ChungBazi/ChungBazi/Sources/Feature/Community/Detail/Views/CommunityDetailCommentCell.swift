//
//  CommunityDetailCommentCell.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import Then
import SwiftyToaster

final class CommunityDetailCommentCell: UITableViewCell {
    
    static let identifier = "CommunityDetailCommentCell"
    
    var onTapLike: (() -> Void)?
    var onTapReply: (() -> Void)?
    
    var isMyComment: Bool = false
    var ownerUserId: Int = 0
    var commentId: Int = 0
    var postId: Int = 0
    
    var onRequestRefresh: (() -> Void)?
    
    private let actionHandler = MoreActionHandler()
    
    private let profileView = CommunityDetailCommentAuthorProfileView()
    private let moreButton = UIButton.createWithImage(image: .moreIcon, tintColor: .gray300,  target: self, action: #selector(moreBtnTapped))
    private let commentLabel = UILabel().then {
        $0.textColor = .gray800
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.numberOfLines = 0
    }
    private let createdAtLabel = UILabel().then {
        $0.textColor = .gray300
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    
    private var isLiked: Bool = false
    private let likeButton = UIButton.createWithImage(
        image: UIImage.likeIcon.withRenderingMode(.alwaysOriginal),
        tintColor: .gray500,
        target: self,
        action: #selector(likeBtnTapped)
    )
    private let likeCountLabel = UILabel().then {
        $0.text = "0"
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    private let commentButton = UIButton.createWithImage(image: .commentIcon, tintColor: .gray500, target: self, action: #selector(commentBtnTapped))
    private let commentCountLabel = UILabel().then {
        $0.text = "0"
        $0.textColor = .gray500
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    
    private let replyIconView = UIImageView().then {
        $0.image = .replyIcon.withRenderingMode(.alwaysOriginal)
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    
    private let leadingGuide = UIView()
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray100
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubviews(
            replyIconView, leadingGuide,
            profileView, moreButton, commentLabel, createdAtLabel,
            likeButton, likeCountLabel, commentButton, commentCountLabel, separatorView
        )
        
        replyIconView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constants.gutter + 8)
            $0.top.equalToSuperview().inset(20.75)
            $0.size.equalTo(16)
        }
        
        leadingGuide.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constants.gutter)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(0)
        }
        
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(leadingGuide.snp.leading)
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(profileView)
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(4)
            $0.leading.equalTo(leadingGuide.snp.leading)
            $0.trailing.equalToSuperview().inset(Constants.gutter)
        }
        
        createdAtLabel.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(5)
            $0.leading.equalTo(leadingGuide.snp.leading)
        }
        
        likeButton.snp.makeConstraints {
            $0.top.equalTo(createdAtLabel.snp.bottom).offset(8)
            $0.leading.equalTo(leadingGuide.snp.leading)
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
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
        
        commentButton.addTarget(self, action: #selector(commentBtnTapped), for: .touchUpInside)
    }
    
    private func applyThreadIndent(isReply: Bool) {
        if isReply {
            replyIconView.isHidden = false
            leadingGuide.snp.remakeConstraints {
                $0.leading.equalTo(replyIconView.snp.trailing).offset(11)
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(0)
            }
        } else {
            replyIconView.isHidden = true
            leadingGuide.snp.remakeConstraints {
                $0.leading.equalToSuperview().inset(Constants.gutter)
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(0)
            }
        }
    }
    
    @objc private func moreBtnTapped() {
        guard let hostView = self.owningViewController?.view else { return }
        let entity: MoreEntity = .comment(
            commentId: commentId,
            postId: postId,
            ownerUserId: ownerUserId,
            mine: isMyComment
        )
        
        MoreActionRouter.present(in: hostView, for: entity) { [weak self] action, entity in
            guard let self else { return }
            self.actionHandler.handle(action, entity: entity) { result in
                switch result {
                case .success:
                    switch action {
                    case .delete:
                        self.onRequestRefresh?()
                        
                    case .block:
                        Toaster.shared.makeToast("해당 사용자를 차단했어요.")
                        self.onRequestRefresh?()
                        
                    case .report:
                        Toaster.shared.makeToast("신고가 접수되었어요.")
                        self.onRequestRefresh?()
                        
                    default:
                        break
                    }
                    
                case .failure(let err):
                    // 실패 메시지
                    switch action {
                    case .delete:
                        Toaster.shared.makeToast("댓글 삭제에 실패했어요. 잠시 후 다시 시도해 주세요.")
                    case .block:
                        Toaster.shared.makeToast("차단에 실패했어요. 네트워크 상태를 확인해 주세요.")
                    case .report:
                        Toaster.shared.makeToast("신고에 실패했어요. 잠시 후 다시 시도해 주세요.")
                    default:
                        Toaster.shared.makeToast("요청을 처리하지 못했어요.")
                    }
                    print("⚠️ action failed: \(err)")
                }
            }
        }
    }
    
    @objc private func likeBtnTapped() {
        onTapLike?()
    }
    
    @objc private func commentBtnTapped() {
        onTapReply?()
    }
    
    func configure(with comment: CommunityDetailCommentModel) {
        profileView.configure(
            userName: comment.userName,
            userLevel: comment.reward,
            characterImageUrl: comment.characterImg
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 19.6
        paragraphStyle.maximumLineHeight = 19.6
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributedString = NSAttributedString(
            string: comment.content,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: commentLabel.font ?? UIFont.systemFont(ofSize: 14),
                .foregroundColor: commentLabel.textColor ?? UIColor.gray800
            ]
        )
        commentLabel.attributedText = attributedString
        
        createdAtLabel.text = comment.formattedCreatedAt
        
        self.isMyComment = comment.mine
        self.ownerUserId = comment.userId
        self.commentId = comment.commentId
        self.postId = comment.postId
        
        let isReply = (comment.parentCommentId != nil)
        applyThreadIndent(isReply: isReply)
        
        self.isLiked = comment.likedByUser
        likeCountLabel.text = "\(comment.likesCount)"
        let img = comment.likedByUser
        ? UIImage.likeSelectedIcon.withRenderingMode(.alwaysOriginal)
        : UIImage.likeIcon.withRenderingMode(.alwaysOriginal)
        likeButton.setImage(img, for: .normal)
        
        commentCountLabel.text = "\(comment.replyCount)"
        
        likeButton.isEnabled = !comment.deleted
        contentView.alpha = comment.deleted ? 0.6 : 1.0
        
        commentButton.isHidden = isReply
        commentCountLabel.isHidden = isReply
    }
    
    func updateLikeUI(liked: Bool, count: Int) {
        self.isLiked = liked
        likeCountLabel.text = "\(count)"
        let img = liked
        ? UIImage.likeSelectedIcon.withRenderingMode(.alwaysOriginal)
        : UIImage.likeIcon.withRenderingMode(.alwaysOriginal)
        likeButton.setImage(img, for: .normal)
    }
}
