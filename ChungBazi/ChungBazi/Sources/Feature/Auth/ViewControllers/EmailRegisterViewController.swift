//
//  EmailRegisterViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 2025/09/01.
//

import UIKit
import SnapKit
import Then

final class EmailRegisterViewController: UIViewController {

    private let authService = AuthService()
    private let registerView = EmailRegisterView()
    
    private var isPasswordVisible = false
    private var isCheckPasswordVisible = false

    override func loadView() {
        self.view = registerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCustomNavigationBar(titleText: "", showBackButton: true)
        setupActions()
    }

    private func setupActions() {
        [registerView.emailTextField,
         registerView.passwordTextField,
         registerView.checkPasswordTextField].forEach {
            $0.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        }

        registerView.registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerView.passwordEyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        registerView.checkPasswordEyeButton.addTarget(self, action: #selector(toggleCheckPasswordVisibility), for: .touchUpInside)
        registerView.passwordInfoButton.addTarget(self, action: #selector(showPasswordRule), for: .touchUpInside)
    }

    @objc private func textFieldsChanged() {
        let isFilled = [registerView.emailTextField,
                        registerView.passwordTextField,
                        registerView.checkPasswordTextField]
            .allSatisfy { !($0.text ?? "").isEmpty }

        registerView.registerButton.isEnabled = isFilled
        registerView.registerButton.backgroundColor = isFilled ? .blue700 : .gray200
    }

    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        registerView.passwordTextField.isSecureTextEntry = !isPasswordVisible
        let icon = isPasswordVisible ? "eye" : "eye.slash"
        registerView.passwordEyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }

    @objc private func toggleCheckPasswordVisibility() {
        isCheckPasswordVisible.toggle()
        registerView.checkPasswordTextField.isSecureTextEntry = !isCheckPasswordVisible
        let icon = isCheckPasswordVisible ? "eye" : "eye.slash"
        registerView.checkPasswordEyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }

    @objc private func showPasswordRule() {
        showCustomAlert(title: "비밀번호 규칙", ButtonText: "영문, 숫자, 특수문자 8자 이상 필수")
    }

    @objc private func registerTapped() {
        guard let email = registerView.emailTextField.text, !email.isEmpty,
              let password = registerView.passwordTextField.text, !password.isEmpty,
              let checkPassword = registerView.checkPasswordTextField.text, !checkPassword.isEmpty else {
            showCustomAlert(title: "모든 항목을 입력해주세요", rightButtonText: "확인", rightButtonAction: nil)
            return
        }

        guard email.isValidEmail() else {
            showCustomAlert(title: "유효한 이메일 형식이 아닙니다", rightButtonText: "확인", rightButtonAction: nil)
            return
        }

        guard password == checkPassword else {
            showCustomAlert(title: "비밀번호가 일치하지 않습니다", rightButtonText: "확인", rightButtonAction: nil)
            return
        }

        let dto = RegisterRequestDto(email: email, password: password, checkPassword: checkPassword)

        authService.register(data: dto) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        self?.showCustomAlert(title: "회원가입이 완료되었습니다", rightButtonText: "확인") {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self?.showCustomAlert(title: response.message, rightButtonText: "확인", rightButtonAction: nil)
                    }

                case .failure(let error):
                    self?.showCustomAlert(title: error.localizedDescription, rightButtonText: "확인", rightButtonAction: nil)
                }
            }
        }
    }
}
