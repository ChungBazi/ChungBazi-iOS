//
//  ProfileView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SnapKit
import Then

protocol ProfileViewDelegate: AnyObject {
    func didTapEditProfile()
    func didTapLogout()
    func didTapWithdraw()
    func didTapMyRewardView()
}

final class ProfileView: UIView {
    
    weak var delegate: ProfileViewDelegate?
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .blue700
        $0.image = .basicBaro
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.createRoundedView(radius: 57)
    }
    private let nameLabel = T20_M(text: "Name")
    private let editProfileBtn = UIButton.createWithImage(
        image: .moveIcon,
        target: self,
        action: #selector(editProfileBtnTapped)
    )
    private let emailLabel = B12_M(text: "Email", textColor: .gray500)
    
    private let myRewardView = UIView()
    private let myRewardIcon = UIImageView().then {
        $0.image = .rewardIcon
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    private let myRewardLabel = B12_M(text: "마이 리워드")
    
    
    private let myCharacterView = UIView()
    private let myCharacterIcon = UIImageView().then {
        $0.image = .myCharacterIcon
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    private let myCharacterLabel = B12_M(text: "마이 캐릭터")
    
    private let gray100View = UIView().then {
        $0.backgroundColor = .gray100
    }
    private let tableView = UITableView()
    private let menuItems = ["정보 수정", "로그아웃", "탈퇴"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(profileImageView, nameLabel, editProfileBtn, emailLabel, myRewardView, myCharacterView, gray100View, tableView)
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(23)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(114)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        editProfileBtn.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(4)
        }
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        
        myRewardView.addSubviews(myRewardIcon, myRewardLabel)
        myRewardView.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(35.5)
            $0.leading.equalToSuperview().inset(80)
            $0.width.equalTo(55)
            $0.height.equalTo(51)
        }
        myRewardIcon.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        myRewardLabel.snp.makeConstraints {
            $0.bottom.centerX.equalToSuperview()
        }
        myRewardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(myRewardViewTapped)))
        myRewardView.isUserInteractionEnabled = true
        
        myCharacterView.addSubviews(myCharacterIcon, myCharacterLabel)
        myCharacterView.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(35.5)
            $0.trailing.equalToSuperview().inset(80)
            $0.width.equalTo(55)
            $0.height.equalTo(51)
        }
        myCharacterIcon.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        myCharacterLabel.snp.makeConstraints {
            $0.bottom.centerX.equalToSuperview()
        }
        
        gray100View.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(myRewardView.snp.bottom).offset(26.5)
            $0.height.equalTo(8)
        }
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.snp.makeConstraints {
            $0.top.equalTo(gray100View.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        tableView.register(ProfileTableCell.self, forCellReuseIdentifier: "ProfileTableCell")
    }
    
    @objc private func editProfileBtnTapped() {
        delegate?.didTapEditProfile()
    }
    
    @objc private func myRewardViewTapped() {
        delegate?.didTapMyRewardView()
    }
}

extension ProfileView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableCell", for: indexPath) as! ProfileTableCell
        cell.configure(with: menuItems[indexPath.row])
        cell.backgroundColor = .gray50
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuItems[indexPath.row] {
        case "정보 수정":
            delegate?.didTapEditProfile()
        case "로그아웃":
            delegate?.didTapLogout()
        case "탈퇴":
            delegate?.didTapWithdraw()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
