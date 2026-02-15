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
    func didTapNotificationSettings()
    func didTapEditMemberInfo()
    func didTapContact()
    func didTapAppInfo()
    func didTapLogout()
    func didTapWithdraw()
}

final class ProfileView: UIView {
    
    weak var delegate: ProfileViewDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileView = UIView().then {
        $0.backgroundColor = .green300
        $0.createRoundedView(radius: 56)
    }
    private let profileImageView = UIImageView()
    private let nameLabel = T20_M(text: "")
    private let editProfileBtn = UIButton.createWithImage(
        image: .moveIcon,
        target: self,
        action: #selector(editProfileBtnTapped)
    ).then {
        $0.tintColor = .gray800
    }
    private let emailLabel = B14_M(text: "", textColor: .gray500)

    private let tableView = UITableView()
    private let menuItems = ["알림 설정",
                             "회원정보 수정",
                             "문의하기",
                             "앱 정보",
                             "로그아웃",
                             "탈퇴"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let totalHeight = CGFloat(menuItems.count * 70)
        tableView.snp.updateConstraints {
            $0.height.equalTo(totalHeight)
        }
    }
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.addSubviews(profileView, nameLabel, editProfileBtn, emailLabel, tableView)
        
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(112)
        }
        profileView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(-2)
            $0.leading.trailing.equalToSuperview().inset(2)
            $0.bottom.equalToSuperview().inset(4)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(17)
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
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(23)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(70)
            $0.height.equalTo(1)
        }
        tableView.register(ProfileTableCell.self, forCellReuseIdentifier: "ProfileTableCell")
    }

    func configure(with data: ProfileModel) {
        nameLabel.text = data.name
        emailLabel.text = data.email
        profileImageView.image = UIImage(named: "\(data.characterImg)")
    }
    
    @objc private func editProfileBtnTapped() {
        delegate?.didTapEditProfile()
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
        case "알림 설정":
            delegate?.didTapNotificationSettings()
        case "회원정보 수정":
            delegate?.didTapEditMemberInfo()
        case "문의하기":
            delegate?.didTapContact()
        case "앱 정보":
            delegate?.didTapAppInfo()
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
