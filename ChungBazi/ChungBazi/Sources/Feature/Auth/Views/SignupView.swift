//
//  SignupView.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/1/25.
//

import UIKit
import SnapKit
import Then

final class SignupView: UIView {

    // MARK: - UI Components
    let titleLabel = UILabel().then {
        $0.text = "청바지의\n회원이 되어주세요!"
        $0.numberOfLines = 2
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }

    let emailTitleLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }

    let emailTextField = UITextField().then {
        $0.placeholder = "이메일 주소를 입력하세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.autocapitalizationType = .none
        $0.keyboardType = .emailAddress
    }

    let pwdTitleLabel = UILabel().then {
        $0.text = "비밀번호 설정"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }

    let pwdInfoButton = UIButton().then {
        $0.setImage(UIImage(named: "questionmark"), for: .normal)
    }

    let pwdTextField = UITextField().then {
        $0.placeholder = "영문, 숫자, 특수문자 8자 이상"
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.isSecureTextEntry = true
    }

    let pwdEyeButton = UIButton().then {
        $0.setImage(UIImage(named: "eye_closed"), for: .normal)
        $0.tintColor = .gray
    }

    let checkPwdTitleLabel = UILabel().then {
        $0.text = "비밀번호 확인"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray
    }

    let checkPwdTextField = UITextField().then {
        $0.placeholder = "다시 한 번 입력해주세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.isSecureTextEntry = true
    }

    let checkPwdEyeButton = UIButton().then {
        $0.setImage(UIImage(named: "eye_closed"), for: .normal)
        $0.tintColor = .gray
    }

    let infoLabel = UILabel().then {
        $0.text = "청바지의 서비스 이용약관과 개인정보 보호정책에 동의하게 됩니다."
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray900
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }

    let registerButton = UIButton(type: .system).then {
        $0.setTitle("다음으로", for: .normal)
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func setupLayout() {
        backgroundColor = .white
        [
            titleLabel,
            emailTitleLabel, emailTextField,
            pwdTitleLabel, pwdInfoButton, pwdTextField, pwdEyeButton,
            checkPwdTitleLabel, checkPwdTextField, checkPwdEyeButton,
            infoLabel, registerButton
        ].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(80)
            $0.leading.equalToSuperview().offset(45)
        }

        emailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(54)
            $0.leading.equalToSuperview().offset(45)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(27)
        }
        addUnderline(to: emailTextField)

        pwdTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(45)
        }

        pwdInfoButton.snp.makeConstraints {
            $0.centerY.equalTo(pwdTitleLabel)
            $0.leading.equalTo(pwdTitleLabel.snp.trailing).offset(4)
            $0.width.height.equalTo(16)
        }

        pwdTextField.snp.makeConstraints {
            $0.top.equalTo(pwdTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(27)
        }
        addUnderline(to: pwdTextField)

        pwdEyeButton.snp.makeConstraints {
            $0.centerY.equalTo(pwdTextField)
            $0.trailing.equalTo(pwdTextField).inset(8)
            $0.width.height.equalTo(24)
        }

        checkPwdTitleLabel.snp.makeConstraints {
            $0.top.equalTo(pwdTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(45)
        }

        checkPwdTextField.snp.makeConstraints {
            $0.top.equalTo(checkPwdTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(27)
        }
        addUnderline(to: checkPwdTextField)

        checkPwdEyeButton.snp.makeConstraints {
            $0.centerY.equalTo(checkPwdTextField)
            $0.trailing.equalTo(checkPwdTextField).inset(8)
            $0.width.height.equalTo(24)
        }

        infoLabel.snp.makeConstraints {
            $0.bottom.equalTo(registerButton.snp.top).offset(-25)
            $0.leading.trailing.equalToSuperview().inset(45)
        }

        registerButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
    }

    func addUnderline(to textField: UITextField) {
        let underline = UIView()
        underline.backgroundColor = .gray500
        self.addSubview(underline)
        underline.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(textField)
            $0.height.equalTo(1)
        }
    }
}
