//
//  EmailRegisterView.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/1/25.
//

import UIKit
import SnapKit
import Then

final class EmailRegisterView: UIView {

    // MARK: - UI Components
    let titleLabel = UILabel().then {
        $0.text = "청바지의\n회원이 되어주세요!"
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .black
    }

    let emailTitleLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .gray
    }

    let emailTextField = UITextField().then {
        $0.placeholder = "이메일 주소를 입력하세요."
        $0.font = .systemFont(ofSize: 15)
        $0.autocapitalizationType = .none
        $0.keyboardType = .emailAddress
    }

    let passwordTitleLabel = UILabel().then {
        $0.text = "비밀번호 설정"
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .gray
    }

    let passwordInfoButton = UIButton().then {
        $0.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        $0.tintColor = .gray
    }

    let passwordTextField = UITextField().then {
        $0.placeholder = "영문, 숫자, 특수문자 8자 이상"
        $0.font = .systemFont(ofSize: 15)
        $0.isSecureTextEntry = true
    }

    let passwordEyeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        $0.tintColor = .gray
    }

    let checkPasswordTitleLabel = UILabel().then {
        $0.text = "비밀번호 확인"
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .gray
    }

    let checkPasswordTextField = UITextField().then {
        $0.placeholder = "다시 한 번 입력해주세요."
        $0.font = .systemFont(ofSize: 15)
        $0.isSecureTextEntry = true
    }

    let checkPasswordEyeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        $0.tintColor = .gray
    }

    let infoLabel = UILabel().then {
        $0.text = "청바지의 서비스 이용약관과 개인정보 보호정책에 동의하게 됩니다."
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .gray
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }

    let registerButton = UIButton(type: .system).then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 17)
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
            passwordTitleLabel, passwordInfoButton, passwordTextField, passwordEyeButton,
            checkPasswordTitleLabel, checkPasswordTextField, checkPasswordEyeButton,
            infoLabel, registerButton
        ].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(80)
            $0.leading.equalToSuperview().offset(45)
        }

        emailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(45)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailTitleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(44)
        }
        addUnderline(to: emailTextField)

        passwordTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(45)
        }

        passwordInfoButton.snp.makeConstraints {
            $0.centerY.equalTo(passwordTitleLabel)
            $0.leading.equalTo(passwordTitleLabel.snp.trailing).offset(4)
            $0.width.height.equalTo(16)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTitleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(44)
        }
        addUnderline(to: passwordTextField)

        passwordEyeButton.snp.makeConstraints {
            $0.centerY.equalTo(passwordTextField)
            $0.trailing.equalTo(passwordTextField).inset(8)
            $0.width.height.equalTo(24)
        }

        checkPasswordTitleLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(45)
        }

        checkPasswordTextField.snp.makeConstraints {
            $0.top.equalTo(checkPasswordTitleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(44)
        }
        addUnderline(to: checkPasswordTextField)

        checkPasswordEyeButton.snp.makeConstraints {
            $0.centerY.equalTo(checkPasswordTextField)
            $0.trailing.equalTo(checkPasswordTextField).inset(8)
            $0.width.height.equalTo(24)
        }

        infoLabel.snp.makeConstraints {
            $0.bottom.equalTo(registerButton.snp.top).offset(-16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        registerButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
    }

    func addUnderline(to textField: UITextField) {
        let underline = UIView()
        underline.backgroundColor = .gray300
        textField.addSubview(underline)
        underline.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
