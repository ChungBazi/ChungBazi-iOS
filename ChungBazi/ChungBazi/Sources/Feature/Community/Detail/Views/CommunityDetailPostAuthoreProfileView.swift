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
    
    private let characterImgView = CustomImageView().then {
        $0.backgroundColor = .green300
        $0.createRoundedView(radius: 23.5)
    }
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        characterImgView.setImageMargins(
            top: -2.65,
            left: -4.09,
            right: -3.63,
            bottom: -6.07
        )
    }
    
    private func setupUI() {
        addSubviews(characterImgView, textView, moreButton)
        
        characterImgView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.size.equalTo(47)
        }
        
        textView.addSubviews(userNameLabel, userLevelLabel, createdAtLabel)
        textView.snp.makeConstraints {
            $0.leading.equalTo(characterImgView.snp.trailing).offset(10)
            $0.centerY.equalTo(characterImgView)
            $0.height.equalTo(42)
        }
        userNameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        userLevelLabel.snp.makeConstraints {
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(7)
            $0.centerY.equalTo(userNameLabel)
        }
        createdAtLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
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
        
    }
    
    func formatUserLevel(_ level: String?) -> String {
        guard let level = level, level.starts(with: "LEVEL_") else { return "" }
        let levelNumber = level.replacingOccurrences(of: "LEVEL_", with: "")
        return "Lv.\(levelNumber)"
    }
}
