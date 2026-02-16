//
//  CommunityDetailPostAuthoreProfileView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher
import SwiftyToaster

final class CommunityDetailPostAuthoreProfileView: UIView {
    
    var onRequestPopToRoot: (() -> Void)?
    
    var isMyPost: Bool = false
    var ownerUserId: Int = 0
    var postId: Int = 0

    private let actionHandler = MoreActionHandler()
    
    private let characterView = UIView().then {
        $0.backgroundColor = .green300
        $0.createRoundedView(radius: 23.29)
    }
    private let characterImgView = UIImageView()
    private let textView = UIView()
    private let userNameLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
    }
    private let userLevelLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray500
    }
    private let createdAtLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray300
    }
    private let moreButton = UIButton.createWithImage(image: .moreIcon, tintColor: .gray500,  target: self, action: #selector(moreBtnTapped))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(characterView, textView, moreButton)
        
        characterView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.size.equalTo(46.58)
        }
        characterView.addSubview(characterImgView)
        characterImgView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(-0.67)
            $0.leading.trailing.equalToSuperview().inset(0.33)
            $0.bottom.equalToSuperview().inset(1.66)
        }
        
        textView.addSubviews(userNameLabel, userLevelLabel, createdAtLabel)
        textView.snp.makeConstraints {
            $0.leading.equalTo(characterView.snp.trailing).offset(10)
            $0.centerY.equalTo(characterView)
            $0.height.equalTo(42)
        }
        userNameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        userLevelLabel.snp.makeConstraints {
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(7)
            $0.centerY.equalTo(userNameLabel)
        }
        createdAtLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.top.equalTo(userNameLabel.snp.bottom)
            $0.height.equalTo(20)
        }
        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(3)
        }
    }
    
    func configure(userName: String, userLevel: String?, characterImageUrl: String?, createdAt: String) {
        userNameLabel.text = userName
        userLevelLabel.text = formatUserLevel(userLevel)
        createdAtLabel.text = createdAt
        
        if let assetName = characterImageUrl, !assetName.isEmpty {
            characterImgView.image = UIImage(named: assetName) ?? UIImage(named: "basicBaro")
        } else { return }
    }
    
    @objc private func moreBtnTapped() {
        guard let hostView = self.owningViewController?.view else { return }
        let entity: MoreEntity = .post(
            postId: postId,
            ownerUserId: ownerUserId,
            mine: isMyPost
        )

        MoreActionRouter.present(in: hostView, for: entity) { [weak self] action, entity in
            guard let self else { return }
            self.actionHandler.handle(action, entity: entity) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        switch action {
                        case .delete:
//                            Toaster.shared.makeToast("게시글이 삭제되었어요.")
                            // 삭제 후 목록으로 이동 유지
                            self.onRequestPopToRoot?()

                        case .block:
                            Toaster.shared.makeToast("해당 사용자를 차단했어요.")
                            self.onRequestPopToRoot?()

                        case .report:
                            Toaster.shared.makeToast("신고가 접수되었어요.")
                            self.onRequestPopToRoot?()

                        default:
                            break
                        }

                    case .failure(let err):
                        switch action {
                        case .delete: Toaster.shared.makeToast("삭제에 실패했어요. 잠시 후 다시 시도해 주세요.")
                        case .block:  Toaster.shared.makeToast("차단에 실패했어요. 네트워크 상태를 확인해 주세요.")
                        case .report: Toaster.shared.makeToast("신고에 실패했어요. 잠시 후 다시 시도해 주세요.")
                        default:      Toaster.shared.makeToast("요청을 처리하지 못했어요.")
                        }
                        print("⚠️ action failed: \(err)")
                    }
                }
            }
        }
    }
    
    func formatUserLevel(_ level: String?) -> String {
        guard let level = level, level.starts(with: "LEVEL_") else { return "" }
        let levelNumber = level.replacingOccurrences(of: "LEVEL_", with: "")
        return "Lv.\(levelNumber)"
    }
}
