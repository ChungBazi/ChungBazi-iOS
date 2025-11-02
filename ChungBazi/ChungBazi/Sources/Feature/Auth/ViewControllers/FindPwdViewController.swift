//
//  FindPwdViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/7/25.
//

import UIKit
import SnapKit
import Then

final class FindPwdViewController: UIViewController {
    
    // MARK: - State
    private enum Step {
        case enterEmail
        case enterCode
    }
    private var step: Step = .enterEmail {
        didSet { updateUIForStep() }
    }
    
    private let emailService = EmailService()
    private var timer: Timer?
    private var remainingSeconds = 300
    
    // MARK: - UI
    private let descriptionLabel = UILabel().then {
        $0.text = "회원가입 시 등록하신\n이메일을 입력해주세요."
        $0.numberOfLines = 2
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }
    
    // MARK: - 이메일 그룹
    private let emailLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }
    
    private let emailField = UITextField().then {
        $0.placeholder = "이메일 주소를 입력하세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
        $0.keyboardType = .emailAddress
        $0.autocapitalizationType = .none
    }
    
    private let emailUnderline = UIView().then {
        $0.backgroundColor = .gray500
    }
    
    // MARK: - 인증번호 그룹
    private let codeLabel = UILabel().then {
        $0.text = "인증번호"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
        $0.isHidden = true
    }
    
    private let codeField = UITextField().then {
        $0.placeholder = "인증번호 6자리를 입력하세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
        $0.keyboardType = .numberPad
        $0.autocapitalizationType = .none
        $0.isHidden = true
    }
    
    private let timerLabel = UILabel().then {
        $0.textColor = .red
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.text = "05:00"
        $0.isHidden = true
    }
    
    private let codeUnderline = UIView().then {
        $0.backgroundColor = .gray500
        $0.isHidden = true
    }
    
    private let completeButton = UIButton(type: .system).then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 10
        $0.isEnabled = false
    }
    
    // MARK: - Lifecycle
    deinit { invalidateTimer() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addCustomNavigationBar(titleText: "비밀번호 재설정", showBackButton: true, backgroundColor: .white)
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        [
            descriptionLabel,
            emailLabel, emailField, emailUnderline,
            codeLabel, codeField, codeUnderline, timerLabel,
            completeButton
        ].forEach { view.addSubview($0) }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(86)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(143)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        
        emailField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(emailLabel)
            $0.height.equalTo(27)
        }
        
        emailUnderline.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(emailField)
            $0.height.equalTo(1)
        }
        
        codeLabel.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        
        codeField.snp.makeConstraints {
            $0.top.equalTo(codeLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(codeLabel)
            $0.height.equalTo(27)
        }
        
        codeUnderline.snp.makeConstraints {
            $0.top.equalTo(codeField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(codeField)
            $0.height.equalTo(1)
        }
        
        timerLabel.snp.makeConstraints {
            $0.centerY.equalTo(codeField)
            $0.trailing.equalToSuperview().inset(45)
        }
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
    }
    
    private func setupActions() {
        [emailField, codeField].forEach {
            $0.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        }
        [emailField, codeField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidBegin(_:)), for: .editingDidBegin)
            $0.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
        }
        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
    }
    
    private func updateUIForStep() {
        switch step {
        case .enterEmail:
            descriptionLabel.text = "회원가입 시 등록하신\n이메일을 입력해주세요."
            setCodeUI(hidden: true)
            textFieldsChanged()
        case .enterCode:
            descriptionLabel.text = "메일로 전달 받은\n인증번호를 입력해주세요."
            setCodeUI(hidden: false)
            startTimer()
            textFieldsChanged()
            codeField.becomeFirstResponder()
        }
    }
    
    private func setCodeUI(hidden: Bool) {
        [codeLabel, codeField, codeUnderline, timerLabel].forEach { $0.isHidden = hidden }
        if hidden {
            invalidateTimer()
            codeField.text = nil
            codeField.textColor = .gray300
            timerLabel.text = "05:00"
        }
    }
    
    @objc private func textFieldDidBegin(_ textField: UITextField) {
        textField.textColor = .black
    }
    @objc private func textFieldDidEnd(_ textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            textField.textColor = .gray300
        } else {
            textField.textColor = .black
        }
    }
    
    @objc private func textFieldsChanged() {
        if emailField.isFirstResponder { emailField.textColor = .black }
        if codeField.isFirstResponder { codeField.textColor = .black }
        
        switch step {
        case .enterEmail:
            let isFilled = !(emailField.text ?? "").isEmpty
            completeButton.isEnabled = isFilled
            completeButton.backgroundColor = isFilled ? .blue700 : .gray200
        case .enterCode:
            let isFilled = !(codeField.text ?? "").isEmpty
            completeButton.isEnabled = isFilled
            completeButton.backgroundColor = isFilled ? .blue700 : .gray200
        }
    }
    
    @objc private func completeTapped() {
        switch step {
        case .enterEmail:
            guard let email = emailField.text, !email.isEmpty else { return }
            guard email.isValidEmail() else {
                showCustomAlert(title: "유효한 이메일 형식이 아닙니다", rightButtonText: "확인", rightButtonAction: nil)
                return
            }
            requestEmailVerification(email: email)
        case .enterCode:
            guard let code = codeField.text, !code.isEmpty else { return }
            verifyCode(code)
        }
    }
    
    private func requestEmailVerification(email: String) {
        completeButton.isEnabled = false
        emailService.requestEmailVerification(email: email) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let message):
                    if let msg = message, !msg.isEmpty { print("✅ \(msg)") }
                    self.step = .enterCode
                case .failure(let error):
                    self.showCustomAlert(title: "인증번호 전송 실패: \(error.localizedDescription)", rightButtonText: "확인", rightButtonAction: nil)
                    self.textFieldsChanged()
                }
            }
        }
    }
    
    private func verifyCode(_ code: String) {
        completeButton.isEnabled = false
        guard let email = emailField.text, !email.isEmpty else {
            showCustomAlert(title: "이메일을 먼저 입력하세요", rightButtonText: "확인", rightButtonAction: nil)
            completeButton.isEnabled = true
            completeButton.backgroundColor = .blue700
            return
        }
        
        emailService.verifyEmailCode(email: email, code: code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success:
                    self.invalidateTimer()
                    let resetVC = ResetPasswordViewController()
                    self.navigationController?.pushViewController(resetVC, animated: true)
                case .failure(let error):
                    self.showCustomAlert(title: "인증 실패: \(error.localizedDescription)", rightButtonText: "확인", rightButtonAction: nil)
                    self.textFieldsChanged()
                }
            }
        }
    }
    
    private func startTimer() {
        invalidateTimer()
        remainingSeconds = 300
        updateTimerLabel()
        timerLabel.isHidden = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] t in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                t.invalidate()
                self.remainingSeconds = 0
                self.updateTimerLabel()
                self.completeButton.isEnabled = false
                self.completeButton.backgroundColor = .gray200
                self.showCustomAlert(title: "인증 시간이 만료되었습니다", rightButtonText: "확인", rightButtonAction: nil)
            } else {
                self.updateTimerLabel()
            }
        })
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}
