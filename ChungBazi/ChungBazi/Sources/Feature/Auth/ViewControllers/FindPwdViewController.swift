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
    
    // MARK: - UI
    private let descriptionLabel = UILabel().then {
        $0.text = "회원가입 시 등록하신 이메일로\n비밀번호를 확인하실 수 있습니다."
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
    }
    
    private let emailUnderline = UIView().then {
        $0.backgroundColor = .gray500
    }
    
    // MARK: - 휴대폰번호 그룹
    private let phoneLabel = UILabel().then {
        $0.text = "휴대폰번호"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }
    
    private let phoneField = UITextField().then {
        $0.placeholder = "휴대폰번호를 입력하세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
        $0.keyboardType = .phonePad
    }
    
    private let phoneUnderline = UIView().then {
        $0.backgroundColor = .gray500
    }
    
    private let verifyButton = UIButton(type: .system).then {
        $0.setTitle("인증번호", for: .normal)
        $0.setTitleColor(.gray300, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.isEnabled = false
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
        $0.isHidden = true
    }
    
    private let timerLabel = UILabel().then {
        $0.textColor = .red
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
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
        $0.backgroundColor = .blue700
        $0.layer.cornerRadius = 10
    }
    
    private var timer: Timer?
    private var remainingSeconds = 300
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addCustomNavigationBar(titleText: "비밀번호 찾기", showBackButton: true)
        phoneField.addTarget(self, action: #selector(phoneTextChanged), for: .editingChanged)
        verifyButton.addTarget(self, action: #selector(startVerification), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        [descriptionLabel, emailLabel, emailUnderline, emailField, phoneLabel, phoneField, phoneUnderline, verifyButton,
         codeLabel, codeField, codeUnderline, timerLabel, completeButton].forEach {
            view.addSubview($0)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(86)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(54)
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
        
        phoneLabel.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        
        phoneField.snp.makeConstraints {
            $0.top.equalTo(phoneLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(phoneLabel)
            $0.height.equalTo(27)
        }
        
        phoneUnderline.snp.makeConstraints {
            $0.top.equalTo(phoneField.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(phoneField)
            $0.height.equalTo(1)
        }
        
        verifyButton.snp.makeConstraints {
            $0.centerY.equalTo(phoneField)
            $0.trailing.equalToSuperview().inset(45)
        }
        
        codeLabel.snp.makeConstraints {
            $0.top.equalTo(phoneField.snp.bottom).offset(24)
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
    }
    
    @objc private func phoneTextChanged() {
        let numbers = phoneField.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? ""
        
        var formatted = ""
        for (i, char) in numbers.enumerated() {
            if i == 3 || i == 7 { formatted.append("-") }
            formatted.append(char)
        }
        phoneField.text = formatted
        
        let emailFilled = !(emailField.text?.isEmpty ?? true)
        let phoneValid = formatted.count == 13
        
        verifyButton.isEnabled = emailFilled && phoneValid
        verifyButton.setTitleColor(verifyButton.isEnabled ? .systemBlue : .lightGray, for: .normal)
    }
    
    @objc private func startVerification() {
        codeLabel.isHidden = false
        codeField.isHidden = false
        timerLabel.isHidden = false
        verifyButton.setTitle("재전송", for: .normal)
        
        remainingSeconds = 300
        updateTimerLabel()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateCountdown),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func updateCountdown() {
        remainingSeconds -= 1
        updateTimerLabel()
        
        if remainingSeconds <= 0 {
            timer?.invalidate()
            timerLabel.text = "만료됨"
        }
    }
    
    private func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}
