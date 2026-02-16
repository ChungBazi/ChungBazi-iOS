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
        $0.text = "이메일로\n로그인 해주세요!"
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
        $0.text = "비밀번호"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }

    let pwdTextField = UITextField().then {
        $0.placeholder = "비밀번호를 입력하세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.isSecureTextEntry = true
    }

    let pwdEyeButton = UIButton().then {
        $0.setImage(UIImage(resource: .eyeClosed), for: .normal)
        $0.tintColor = .gray
    }

    let findPwdButton = UIButton().then {
        let title = "비밀번호를 잊으셨나요?"
        let attributed = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.ptdMediumFont(ofSize: 14),
                .foregroundColor: UIColor.gray500,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        $0.setAttributedTitle(attributed, for: .normal)
    }

    let registerButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
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
            pwdTitleLabel, pwdTextField, pwdEyeButton,
            findPwdButton, registerButton
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

        findPwdButton.snp.makeConstraints {
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
        underline.backgroundColor = .gray500
        self.addSubview(underline)
        underline.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(textField)
            $0.height.equalTo(1)
        }
    }
}
