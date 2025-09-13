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
    
    var isMyPost: Bool = false
    
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

        let items: [BottomSheetView.Item] = {
            if isMyPost {
                return [.init(title: "삭제하기", textColor: AppColor.buttonAccent)]
            } else {
                return [
                    .init(title: "대댓글 알람 켜기", textColor: AppColor.gray800),
                    .init(title: "쪽지 보내기",     textColor: AppColor.gray800),
                    .init(title: "신고하기",        textColor: AppColor.buttonAccent),
                    .init(title: "차단하기",        textColor: AppColor.buttonAccent)
                ]
            }
        }()

        let sheet = BottomSheetView.present(in: hostView, items: items) { [weak self] index, title in
            guard let self else { return }
            if self.isMyPost {
                // 삭제하기
            } else {
                switch index {
                case 0: /* 대댓글 알람 켜기 */ break
                case 1: /* 쪽지 보내기 */     break
                case 2: /* 신고하기 */        break
                case 3: /* 차단하기 */        break
                default: break
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
