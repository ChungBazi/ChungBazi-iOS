//
//  CommunityDetailCommentAuthorProfileView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/8/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class CommunityDetailCommentAuthorProfileView: UIView {
    
    private let characterImgView = UIImageView().then {
        $0.backgroundColor = .green300
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 16.5
        $0.clipsToBounds = true
    }
    
    private let userNameLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
    }
    
    private let userLevelLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(characterImgView, userNameLabel, userLevelLabel)
        
        characterImgView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
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
    }
    
    func configure(userName: String, userLevel: String?, characterImageUrl: String?) {
        userNameLabel.text = userName
        userLevelLabel.text = formatUserLevel(userLevel)
        
        if let assetName = characterImageUrl, !assetName.isEmpty {
            characterImgView.image = UIImage(named: assetName) ?? UIImage(named: "basicBaro")
        } else { return }
        
        layoutIfNeeded()
    }
    
    func formatUserLevel(_ level: String?) -> String {
        guard let level = level else { return "" }
        if level.starts(with: "LEVEL_") {
            let levelNumber = level.replacingOccurrences(of: "LEVEL_", with: "")
            return "Lv.\(levelNumber)"
        }
        
        return level
    }
}
