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
    
    private let characterImgView = UIImageView().then {
        $0.backgroundColor = .green300
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 23.5
        $0.clipsToBounds = true
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
    
    private func setupUI() {
        addSubviews(characterImgView, textView, moreButton)
        
        characterImgView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.size.equalTo(47)
        }
        
        textView.addSubviews(userNameLabel, userLevelLabel, createdAtLabel)
        textView.snp.makeConstraints {
            $0.leading.equalTo(characterImgView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
        }
        userNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
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
        userLevelLabel.text = userLevel ?? ""
        createdAtLabel.text = createdAt
        
        let defaultProfileImage = UIImage(named: "basicBaro")
        if let imageUrl = characterImageUrl, !imageUrl.isEmpty {
            characterImgView.kf.setImage(with: URL(string: imageUrl), placeholder: defaultProfileImage)
        } else {
            characterImgView.image = defaultProfileImage
        }
    }
    
    @objc private func moreBtnTapped() {
        
    }
}
