//
//  ProfileEditView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SnapKit
import Then

protocol ProfileEditViewDelegate: AnyObject {
    func didCompleteEditing(nickname: String)
}

final class ProfileEditView: UIView, UITextFieldDelegate {
    
    weak var delegate: ProfileEditViewDelegate?
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .blue700
        $0.image = .basicBaro
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.createRoundedView(radius: 78)
    }
    private let settingPhotoBtn = CustomButton(backgroundColor: .white, titleText: "사진 설정하기", titleColor: .black, borderWidth: 1, borderColor: .gray400)
    private let settingCharacterBtn = CustomButton(backgroundColor: .white, titleText: "캐릭터 설정하기", titleColor: .black, borderWidth: 1, borderColor: .gray400)
    
    private let nickNameTitle = B12_M(text: "닉네임", textColor: .gray500)
    private let nickNameTextField = UITextField().then {
        $0.text = ""
        $0.textColor = .gray800
        $0.clearButtonMode = .always
        $0.returnKeyType = .done
    }
    private let nickNameUnderLine = UIView().then {
        $0.backgroundColor = .gray500
    }
    
    private let emailTitle = B12_M(text: "이메일", textColor: .gray500)
    private let emailLabel = B16_M(text: "", textColor: .gray300)
    private let emailUnderLine = UIView().then {
        $0.backgroundColor = .gray500
    }
    
    private let completeBtn = CustomButton(backgroundColor: .blue700, titleText: "프로필 설정 완료", titleColor: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        nickNameTextField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviews(profileImageView, settingPhotoBtn, settingCharacterBtn, nickNameTitle, nickNameTextField, nickNameUnderLine, emailTitle, emailLabel, emailUnderLine, completeBtn)
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(156)
        }
        settingPhotoBtn.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(33)
            $0.trailing.equalTo(profileImageView.snp.centerX).offset(-6)
            $0.width.equalTo(118)
        }
        settingCharacterBtn.snp.makeConstraints {
            $0.top.equalTo(settingPhotoBtn)
            $0.leading.equalTo(profileImageView.snp.centerX).offset(6)
            $0.width.equalTo(settingPhotoBtn)
        }
        nickNameTitle.snp.makeConstraints {
            $0.top.equalTo(settingPhotoBtn.snp.bottom).offset(51)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameTitle.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(nickNameTitle)
            $0.height.equalTo(22)
        }
        nickNameUnderLine.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(nickNameTextField)
            $0.height.equalTo(1)
        }
        emailTitle.snp.makeConstraints {
            $0.top.equalTo(nickNameUnderLine.snp.bottom).offset(35)
            $0.leading.trailing.equalTo(nickNameTitle)
        }
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(emailTitle.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(nickNameTitle)
            $0.height.equalTo(22)
        }
        emailUnderLine.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(emailLabel)
            $0.height.equalTo(1)
        }
        completeBtn.snp.makeConstraints {
            $0.top.equalTo(emailUnderLine.snp.bottom).offset(144)
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(Constants.gutter)
        }
    }
    
    private func setupActions() {
        settingPhotoBtn.addTarget(self, action: #selector(settingPhotoBtnTapped), for: .touchUpInside)
        settingCharacterBtn.addTarget(self, action: #selector(settingCharacterBtnTapped), for: .touchUpInside)
        completeBtn.addTarget(self, action: #selector(completeBtnTapped), for: .touchUpInside)
    }
    
    func configure(with data: ProfileModel) {
        nickNameTextField.text = data.nickname
        emailLabel.text = data.email
    }
    
    @objc private func settingPhotoBtnTapped() {
        // FIXME: 사진 설정하기 버튼
    }
    
    @objc private func settingCharacterBtnTapped() {
        // FIXME: 캐릭터 설정하기 버튼
    }
    
    @objc private func completeBtnTapped() {
        // FIXME: 예외 처리 구현
        guard let nickname = nickNameTextField.text, !nickname.isEmpty else {
            print("닉네임이 비어있습니다.")
            return
        }
        delegate?.didCompleteEditing(nickname: nickname)
    }
}
