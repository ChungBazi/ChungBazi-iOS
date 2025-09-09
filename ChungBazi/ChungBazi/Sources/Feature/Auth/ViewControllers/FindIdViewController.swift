//
//  FindIdViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/7/25.
//

import UIKit
import SnapKit
import Then

final class FindIdViewController: UIViewController {
    
    // MARK: - UI
    private let descriptionLabel = UILabel().then {
        $0.text = "회원가입 시 등록하신 휴대폰번호로\n아이디를 확인하실 수 있습니다."
        $0.numberOfLines = 2
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
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
    }
    
    private let codeField = UITextField().then {
        $0.placeholder = "인증번호 6자리를 입력하세요."
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
        $0.keyboardType = .numberPad
    }
    
    private let codeUnderline = UIView().then {
        $0.backgroundColor = .gray500
    }
    
    private let completeButton = UIButton(type: .system).then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.backgroundColor = .blue700
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addCustomNavigationBar(titleText: "아이디 찾기", showBackButton: true)
        phoneField.addTarget(self, action: #selector(phoneTextChanged), for: .editingChanged)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        [descriptionLabel, phoneLabel, phoneField, phoneUnderline, verifyButton, codeLabel, codeField, codeUnderline, completeButton].forEach {
            view.addSubview($0)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(86)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        
        phoneLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(54)
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
            $0.top.equalTo(codeField.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(codeField)
            $0.height.equalTo(1)
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
        
        verifyButton.isEnabled = formatted.count == 13
        verifyButton.setTitleColor(verifyButton.isEnabled ? .systemBlue : .lightGray, for: .normal)
    }
    
}
