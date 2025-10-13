//
//  EmailRegisterViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/1/25.
//

import UIKit
import SnapKit
import Then
import KeychainSwift

final class EmailRegisterViewController: UIViewController, UITextFieldDelegate {

    
    private let authService = AuthService()
    private let registerView = EmailRegisterView()
    private var isPasswordVisible = false
    
    override func loadView() {
        self.view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCustomNavigationBar(titleText: "이메일 로그인", showBackButton: true)
        setupActions()
        setupTextFieldDelegates()
        setupBackgroundTapToDismiss()
        setupKeyboardFollowing()
    }
    
    private func setupTextFieldDelegates() {
        registerView.emailTextField.delegate = self
        registerView.pwdTextField.delegate = self
        
        registerView.emailTextField.returnKeyType = .next
        registerView.pwdTextField.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == registerView.emailTextField {
            registerView.pwdTextField.becomeFirstResponder()
        } else if textField == registerView.pwdTextField {
            view.endEditing(true)
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    private func setupBackgroundTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupKeyboardFollowing() {
        if #available(iOS 15.0, *) {
            registerView.registerButton.snp.makeConstraints {
                $0.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).offset(-12).priority(.required)
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    @objc private func kbWillShow(_ note: Notification) {
        guard
            let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        UIView.animate(withDuration: duration) {
            self.additionalSafeAreaInsets.bottom = frame.height - self.view.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func kbWillHide(_ note: Notification) {
        let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        UIView.animate(withDuration: duration) {
            self.additionalSafeAreaInsets.bottom = 0
            self.view.layoutIfNeeded()
        }
    }

    private func setupActions() {
        [registerView.emailTextField,
         registerView.pwdTextField].forEach {
            $0.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        }
        
        registerView.registerButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerView.pwdEyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        registerView.findPwdButton.addTarget(self, action: #selector(findPwdTapped), for: .touchUpInside)
    }
    
    @objc private func textFieldsChanged() {
        let isFilled = [registerView.emailTextField,
                        registerView.pwdTextField]
            .allSatisfy { !($0.text ?? "").isEmpty }
        
        registerView.registerButton.isEnabled = isFilled
        registerView.registerButton.backgroundColor = isFilled ? .blue700 : .gray200
    }
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        registerView.pwdTextField.isSecureTextEntry = !isPasswordVisible
        if registerView.pwdTextField.isFirstResponder {
            let existingText = registerView.pwdTextField.text
            registerView.pwdTextField.text = nil
            registerView.pwdTextField.text = existingText
        }
        let icon = isPasswordVisible ? "eye" : "eye.slash"
        registerView.pwdEyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @objc private func findPwdTapped() {
        let vc = FindPwdViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginTapped() {
        guard let email = registerView.emailTextField.text, !email.isEmpty,
              let password = registerView.pwdTextField.text, !password.isEmpty else {
            showCustomAlert(title: "모든 항목을 입력해주세요", rightButtonText: "확인", rightButtonAction: nil)
            return
        }
        
        guard email.isValidEmail() else {
            showCustomAlert(title: "유효한 이메일 형식이 아닙니다", rightButtonText: "확인", rightButtonAction: nil)
            return
        }
        
        let fcmToken = KeychainSwift().get("fcmToken") ?? ""
        
        let dto = LoginRequestDto(email: email, password: password, fcmToken: fcmToken)
        
        authService.login(data: dto) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    KeychainSwift().set(response.accessToken, forKey: "serverAccessToken")
                    KeychainSwift().set(response.refreshToken, forKey: "serverRefreshToken")
                    let expirationTimestamp = Int(Date().timeIntervalSince1970) + response.accessExp
                    KeychainSwift().set(String(expirationTimestamp), forKey: "serverAccessTokenExp")
                    
                    KeychainSwift().set(String(response.userId), forKey: "userId")
                    KeychainSwift().set(response.userName, forKey: "userName")
                    KeychainSwift().set(response.isFirst ? "1" : "0", forKey: "isFirstLogin")
                    
                    if response.isFirst {
                        let nicknameVC = NicknameRegisterViewController(email: email, isFirst: true)
                        self?.navigationController?.pushViewController(nicknameVC, animated: true)
                    } else {
                        self?.showCustomAlert(title: "로그인에 성공했습니다", rightButtonText: "확인") {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                case .failure(let error):
                    self?.showCustomAlert(title: error.localizedDescription, rightButtonText: "확인", rightButtonAction: nil)
                }
            }
        }
    }
}
