//
//  ResetPasswordView.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/1/25.
//

import UIKit
import SnapKit
import Then

final class ResetPasswordView: UIView {
    
    let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - UI
    let descriptionLabel = UILabel().then {
        $0.text = "새로운 비밀번호를\n입력해 주세요."
        $0.numberOfLines = 2
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }
    
    // 신규 비밀번호
    let newPwdLabel = UILabel().then {
        $0.text = "신규 비밀번호"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }
    let questionButton = UIButton().then {
        $0.setImage(UIImage(resource: .questionmark), for: .normal)
        $0.tintColor = .gray500
    }
    let newPwdField = UITextField().then {
        $0.placeholder = "영문, 숫자, 특수문자 8자 이상"
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.isSecureTextEntry = true
    }
    let newPwdEye = UIButton().then {
        $0.setImage(UIImage(resource: .eyeClosed), for: .normal)
        $0.tintColor = .gray
    }
    private let newPwdUnderline = UIView().then {
        $0.backgroundColor = .gray500
    }
    
    // 신규 비밀번호 확인
    let confirmPwdLabel = UILabel().then {
        $0.text = "신규 비밀번호 확인"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }
    let confirmPwdField = UITextField().then {
        $0.placeholder = "비밀번호를 다시 입력해주세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.isSecureTextEntry = true
    }
    let confirmPwdEye = UIButton().then {
        $0.setImage(UIImage(resource: .eyeClosed), for: .normal)
        $0.tintColor = .gray
    }
    private let confirmPwdUnderline = UIView().then {
        $0.backgroundColor = .gray500
    }
    
    let completeButton = UIButton(type: .system).then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 10
        $0.isEnabled = false
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Layout
    private func setupLayout() {
        backgroundColor = .white
        
        addSubview(scrollView)
        addSubview(completeButton)
        scrollView.addSubview(contentView)
        
        completeButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(self).inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(48)
        }
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(completeButton.snp.top).offset(-12)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        [
            descriptionLabel,
            newPwdLabel, questionButton, newPwdField, newPwdEye, newPwdUnderline,
            confirmPwdLabel, confirmPwdField, confirmPwdEye, confirmPwdUnderline
        ].forEach { contentView.addSubview($0) }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(93)
            $0.leading.trailing.equalTo(contentView).inset(45)
        }
        
        newPwdLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(136)
            $0.leading.equalTo(contentView).inset(45)
        }
        
        questionButton.snp.makeConstraints {
            $0.centerY.equalTo(newPwdLabel)
            $0.leading.equalTo(newPwdLabel.snp.trailing).offset(6)
            $0.width.height.equalTo(16)
        }
        
        newPwdField.snp.makeConstraints {
            $0.top.equalTo(newPwdLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(45)
            $0.height.equalTo(22)
        }
        
        newPwdUnderline.snp.makeConstraints {
            $0.top.equalTo(newPwdField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(newPwdField)
            $0.height.equalTo(1)
        }
        
        newPwdEye.snp.makeConstraints {
            $0.centerY.equalTo(newPwdField)
            $0.trailing.equalTo(newPwdField).inset(8)
            $0.width.height.equalTo(24)
        }
        
        confirmPwdLabel.snp.makeConstraints {
            $0.top.equalTo(newPwdUnderline.snp.bottom).offset(32)
            $0.leading.equalTo(contentView).inset(45)
        }
        
        confirmPwdField.snp.makeConstraints {
            $0.top.equalTo(confirmPwdLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(45)
            $0.height.equalTo(22)
        }
        
        confirmPwdUnderline.snp.makeConstraints {
            $0.top.equalTo(confirmPwdField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(confirmPwdField)
            $0.height.equalTo(1)
        }
        
        confirmPwdEye.snp.makeConstraints {
            $0.centerY.equalTo(confirmPwdField)
            $0.trailing.equalTo(confirmPwdField).inset(8)
            $0.width.height.equalTo(24)
        }
        
        contentView.snp.makeConstraints {
            $0.bottom.equalTo(confirmPwdUnderline.snp.bottom).offset(40)
        }
        
        scrollView.delaysContentTouches = false
    }
}
