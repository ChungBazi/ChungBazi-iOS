//
//  EmailVerificationCodeViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 8/28/25.
//

import UIKit
import SnapKit
import Then

final class EmailVerificationCodeViewController: UIViewController {
    
    private let email: String
    private let emailService = EmailService()
    
    private let descriptionLabel = UILabel().then {
        $0.text = "회원님의 이메일로\n코드를 전송했어요!"
        $0.numberOfLines = 2
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }
    
    // MARK: - 이메일 그룹
    private let codeLabel = UILabel().then {
        $0.text = "코드 입력"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }
    
    private let codeTextField = UITextField().then {
        $0.placeholder = "코드를 입력하세요"
        $0.borderStyle = .roundedRect
        $0.keyboardType = .numberPad
    }
    
    private let resendButton = UIButton().then {
        $0.setTitle("코드 재전송", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.titleLabel?.font = .ptdMediumFont(ofSize: 14)
    }
    
    private let verifyButton = UIButton().then {
        $0.setTitle("인증 확인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .blue
        $0.layer.cornerRadius = 8
    }

    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addCustomNavigationBar(titleText: "회원가입", showBackButton: true)
        setupViews()
        setupActions()
        
//        requestEmailVerification()
    }
    
    private func setupViews() {
        view.addSubview(codeTextField)
        view.addSubview(verifyButton)
        
        codeTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        
        resendButton.snp.makeConstraints {
            $0.top.equalTo(codeTextField.snp.bottom).offset(8)
            $0.trailing.equalTo(codeTextField)
        }
        
        verifyButton.snp.makeConstraints {
            $0.top.equalTo(resendButton.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(codeTextField)
            $0.height.equalTo(48)
        }
    }

    private func setupActions() {
        verifyButton.addTarget(self, action: #selector(verifyCodeTapped), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
    }
    
    // MARK: - 인증 코드 재전송
    @objc private func resendTapped() {
        requestEmailVerification()
    }
    
    private func requestEmailVerification() {
        emailService.requestEmailVerification { [weak self] result in
            switch result {
            case .success(let response):
                print("✅ 인증 요청 성공: \(response)")
            case .failure(let error):
                self?.showCustomAlert(title: "인증 요청 실패", rightButtonText: "확인", rightButtonAction: nil)
                print("❌ 인증 요청 실패: \(error)")
            }
        }
    }

    // MARK: - 인증 코드 확인
    @objc private func verifyCodeTapped() {
        guard let code = codeTextField.text, !code.isEmpty else {
            showCustomAlert(title: "코드를 입력해주세요", rightButtonText: "확인", rightButtonAction: nil)
            return
        }
        
        emailService.verifyEmailCode(authCode: code) { [weak self] result in
            switch result {
            case .success(let response):
                if response.isSuccess {
                    self?.navigateToNextStep()
                } else {
                    self?.showCustomAlert(title: response.message, rightButtonText: "확인", rightButtonAction: nil)
                }
            case .failure(let error):
                self?.showCustomAlert(title: "인증 오류", rightButtonText: "확인", rightButtonAction: nil)
                print("❌ 인증 실패: \(error)")
            }
        }
    }

    private func navigateToNextStep() {
        let nicknameVC = NicknameRegisterViewController(email: email, isFirst: true)
        self.navigationController?.pushViewController(nicknameVC, animated: true)
    }
}
