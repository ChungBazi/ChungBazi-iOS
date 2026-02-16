//
//  ResetPasswordViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/7/25.
//

import UIKit
import SnapKit
import Then

final class ResetPasswordViewController: UIViewController {

    enum Mode {
        case loggedIn
        case noAuth(email: String, code: String)
    }

    private let mode: Mode
    private let resetView = ResetPasswordView()
    private var isNewPwdVisible = false
    private var isConfirmPwdVisible = false
    private let authService = AuthService.shared
    private let userAuthService = UserAuthService()
    
    private let tooltipView = TooltipView()

    convenience init() { self.init(mode: .loggedIn) }
    init(mode: Mode) { self.mode = mode; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        self.view = resetView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addCustomNavigationBar(titleText: "비밀번호 재설정", showBackButton: true, backgroundColor: .white)
        setupTooltip()
        setupActions()
        enableKeyboardHandling(for: resetView.scrollView)
        resetView.scrollView.keyboardDismissMode = .onDrag
        
        resetView.scrollView.canCancelContentTouches = true
        resetView.scrollView.panGestureRecognizer.cancelsTouchesInView = false
    }
    
    private func setupTooltip() {
        resetView.addSubview(tooltipView)
    }
    
    private func setupActions() {
        [resetView.newPwdField, resetView.confirmPwdField].forEach {
            $0.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        }
        resetView.newPwdEye.addTarget(self, action: #selector(toggleNewPwdVisibility), for: .touchUpInside)
        resetView.confirmPwdEye.addTarget(self, action: #selector(toggleConfirmPwdVisibility), for: .touchUpInside)
        resetView.questionButton.addTarget(self, action: #selector(toggleTooltip), for: .touchUpInside)
        resetView.completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
    }
    
    @objc private func toggleTooltip() {
        tooltipView.show(
            anchorView: resetView.questionButton,
            text: "비밀번호는 8자 이상이며, 영문 대·소문자, 숫자, 특수문자를 각각 1자 이상 포함해야 합니다.",
            width: 190,
            duration: 2
        )
    }
    
    @objc private func toggleNewPwdVisibility() {
        isNewPwdVisible.toggle()
        resetView.newPwdField.isSecureTextEntry = !isNewPwdVisible
        let iconName = isNewPwdVisible
            ? UIImage(systemName: "eye")
        : UIImage(resource: .eyeClosed)
        resetView.newPwdEye.setImage(iconName, for: .normal)
    }
    
    @objc private func toggleConfirmPwdVisibility() {
        isConfirmPwdVisible.toggle()
        resetView.confirmPwdField.isSecureTextEntry = !isConfirmPwdVisible
        let iconName = isConfirmPwdVisible
            ? UIImage(systemName: "eye")
            : UIImage(resource: .eyeClosed)
        resetView.confirmPwdEye.setImage(iconName, for: .normal)
    }
    
    @objc private func textFieldsChanged() {
        let newPwd = resetView.newPwdField.text ?? ""
        let confirm = resetView.confirmPwdField.text ?? ""
        let valid = !newPwd.isEmpty && !confirm.isEmpty
        
        resetView.completeButton.isEnabled = valid
        resetView.completeButton.backgroundColor = valid ? .blue700 : .gray200
    }
    
    @objc private func completeTapped() {
        let newPwd = resetView.newPwdField.text ?? ""
        let confirm = resetView.confirmPwdField.text ?? ""
        guard isValidPassword(newPwd) else { showCustomAlert(title: "비밀번호 규칙을 확인해 주세요.", buttonText: "확인", buttonAction: nil); return }
        guard newPwd == confirm else { showCustomAlert(title: "비밀번호가 일치하지 않습니다.", buttonText: "확인", buttonAction: nil); return }
        
        switch mode {
        case .loggedIn:
            let dto = ResetPasswordRequestDto(newPassword: newPwd, checkNewPassword: confirm)
            userAuthService.resetPassword(data: dto, completion: handleResult)
        case .noAuth(let email, let code):
            authService.resetPasswordNoAuth(
                email: email,
                authCode: code,
                newPassword: newPwd
                , completion: handleResult)
        }
    }


    
    private func handleResult(_ result: Result<String, NetworkError>) {
        DispatchQueue.main.async {
            switch result {
            case .success:
                self.showCustomAlert(title: "비밀번호가 재설정되었습니다.", buttonText: "확인") {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            case .failure(let error):
                let msg: String
                switch error { case .serverError(_, let m): msg = m; default: msg = error.localizedDescription }
                self.showCustomAlert(title: msg, buttonText: "확인", buttonAction: nil)
            }
        }
    }
    
    private func isValidPassword(_ pwd: String) -> Bool {
        let pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+=\\-{}\\[\\]|:;\"'<>,.?/`~]).{8,}$"
        return pwd.range(of: pattern, options: .regularExpression) != nil
    }
}
