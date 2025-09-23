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
                switch result {
                case .success:
                    if case .delete = action { self.onRequestPopToRoot?() }
                    if case .block  = action { self.onRequestPopToRoot?() }
                    if case .report  = action { self.onRequestPopToRoot?() }
                    break
                case .failure(let err):
                    print("⚠️ action failed: \(err)")
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
