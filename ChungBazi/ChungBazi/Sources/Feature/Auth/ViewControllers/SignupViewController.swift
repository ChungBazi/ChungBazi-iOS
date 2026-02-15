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
    
    private let tooltipView = TooltipView()

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
        tooltipView.show(
            anchorView: registerView.pwdInfoButton,
            text: "비밀번호는 8자 이상이며, 영문 대·소문자, 숫자, 특수문자를 각각 1자 이상 포함해야 합니다.",
            width: 190,
            duration: 3
        )
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
