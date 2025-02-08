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
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16.5
        $0.clipsToBounds = true
    }
    
    private let userNameLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 16)
    }
    
    private let userLevelLabel = UILabel().then {
        $0.font = .ptdBoldFont(ofSize: 16)
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
        userLevelLabel.text = userLevel ?? ""
        
        let defaultProfileImage = UIImage(named: "basicBaro")
        if let imageUrl = characterImageUrl, !imageUrl.isEmpty {
            characterImgView.kf.setImage(with: URL(string: imageUrl), placeholder: defaultProfileImage)
        } else {
            characterImgView.image = defaultProfileImage
        }
    }
}
