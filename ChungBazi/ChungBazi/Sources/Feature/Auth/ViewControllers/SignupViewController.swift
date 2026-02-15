//
//  SignupViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/1/25.
//

import UIKit
import SnapKit
import Then
import SwiftyToaster

final class SignupViewController: UIViewController {

    private let authService = AuthService.shared
    private let registerView = SignupView()
    
    private var isPasswordVisible = false
    private var isCheckPasswordVisible = false

    private let tooltipView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowRadius = 4
        $0.isHidden = true
        $0.alpha = 1.0
        $0.clipsToBounds = false
    }
    
    private let tooltipLabel = UILabel().then {
        $0.text = "영문, 숫자, 특수문자 8자 이상 필수"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.numberOfLines = 1
        $0.textAlignment = .center
    }

    override func loadView() {
        self.view = registerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCustomNavigationBar(titleText: "회원가입", showBackButton: true)
        setupActions()
        setupTooltipLayout()
        enableKeyboardHandling(for: registerView.scrollView)
        registerView.scrollView.keyboardDismissMode = .onDrag
        
        registerView.scrollView.canCancelContentTouches = true
        registerView.scrollView.panGestureRecognizer.cancelsTouchesInView = false
    }

    private func setupActions() {
        [registerView.emailTextField,
         registerView.pwdTextField,
         registerView.checkPwdTextField].forEach {
            $0.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        }

        registerView.registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerView.pwdEyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        registerView.checkPwdEyeButton.addTarget(self, action: #selector(toggleCheckPasswordVisibility), for: .touchUpInside)
        registerView.pwdInfoButton.addTarget(self, action: #selector(showPasswordRule), for: .touchUpInside)
    }

    private func setupTooltipLayout() {
        registerView.addSubview(tooltipView)
        tooltipView.addSubview(tooltipLabel)
        
        tooltipView.snp.makeConstraints {
            $0.width.equalTo(195)
            $0.height.equalTo(24)
            $0.leading.equalTo(registerView.pwdInfoButton.snp.trailing).offset(0)
            $0.bottom.equalTo(registerView.pwdInfoButton.snp.top).offset(0)
        }
        
        tooltipLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    @objc private func textFieldsChanged() {
        let isFilled = [registerView.emailTextField,
                        registerView.pwdTextField,
                        registerView.checkPwdTextField]
            .allSatisfy { !($0.text ?? "").isEmpty }

        registerView.registerButton.isEnabled = isFilled
        registerView.registerButton.backgroundColor = isFilled ? .blue700 : .gray200
    }

    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        registerView.pwdTextField.isSecureTextEntry = !isPasswordVisible
        let iconName = isPasswordVisible
        ? UIImage(systemName: "eye")
        : UIImage(resource: .eyeClosed)
        registerView.pwdEyeButton.setImage(iconName, for: .normal)
    }

    @objc private func toggleCheckPasswordVisibility() {
        isCheckPasswordVisible.toggle()
        registerView.checkPwdTextField.isSecureTextEntry = !isCheckPasswordVisible
        let iconName = isCheckPasswordVisible
        ? UIImage(systemName: "eye")
        : UIImage(resource: .eyeClosed)
        registerView.checkPwdEyeButton.setImage(iconName, for: .normal)
    }

    @objc private func showPasswordRule() {
        tooltipView.isHidden.toggle()
    }

    @objc private func registerTapped() {
        guard let email = registerView.emailTextField.text, !email.isEmpty,
              let password = registerView.pwdTextField.text, !password.isEmpty,
              let checkPassword = registerView.checkPwdTextField.text, !checkPassword.isEmpty else {
            showCustomAlert(title: "모든 항목을 입력해주세요", rightButtonText: "확인", rightButtonAction: nil)
            return
        }
        
        guard email.isValidEmail() else {
            showCustomAlert(title: "유효한 이메일 형식이 아닙니다", rightButtonText: "확인", rightButtonAction: nil)
            return
        }
        
        guard isValidPassword(password) else { showCustomAlert(title: "비밀번호 규칙을 확인해 주세요", rightButtonText: "확인", rightButtonAction: nil); return }
        
        guard password == checkPassword else {
            showCustomAlert(title: "비밀번호가 일치하지 않습니다", rightButtonText: "확인", rightButtonAction: nil)
            return
        }
        
        let dto = RegisterRequestDto(email: email, password: password, checkPassword: checkPassword)
        let EmailVerifyVC = EmailVerificationCodeViewController(registerInfo: dto)
        self.navigationController?.pushViewController(EmailVerifyVC, animated: true)
    }
    
    private func isValidPassword(_ pwd: String) -> Bool {
        let pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+=\\-{}\\[\\]|:;\"'<>,.?/`~]).{8,}$"
        return pwd.range(of: pattern, options: .regularExpression) != nil
    }
}
