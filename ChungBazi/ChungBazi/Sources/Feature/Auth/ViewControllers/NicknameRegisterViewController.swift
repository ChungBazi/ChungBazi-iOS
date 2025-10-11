//
//  NicknameRegisterViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/1/25.
//

import UIKit
import SnapKit
import Then
import SwiftyToaster

final class NicknameRegisterViewController: UIViewController {
    
    private let authService = AuthService()
    
    private let initialEmail: String?
    private let isFirst: Bool
    private var isRequesting = false
    
    init(email: String?, isFirst: Bool) {
        self.initialEmail = email
        self.isFirst = isFirst
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "청바지에서 사용할\n닉네임을 알려주세요!"
        $0.numberOfLines = 2
        $0.font = .ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }

    private let profileBgView = UIView().then {
        $0.backgroundColor = .green300
        $0.layer.cornerRadius = 49.94
        $0.clipsToBounds = true
    }
    
    private let profileImg = UIImageView().then {
        $0.image = UIImage(named: "basicBaro")
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
    }
    
    private let nicknameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }

    private let nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임을 입력하세요."
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
        $0.autocapitalizationType = .none
    }

    private let emailLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray500
    }

    private let emailTextField = UITextField().then {
        $0.placeholder = "이메일"
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
        $0.autocapitalizationType = .none
        $0.keyboardType = .emailAddress
    }
    
    private let nicknameUnderlineView = UIView().then { $0.backgroundColor = .gray500 }
    private let emailUnderlineView = UIView().then { $0.backgroundColor = .gray500 }

    private let completeButton = CustomActiveButton(title: "완료", isEnabled: false)
    
    private let activity = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addCustomNavigationBar(titleText: "회원가입", showBackButton: true)
        setupLayout()
        bind()
        prefill()
    }

    // MARK: - Setup
    private func setupLayout() {
        profileImg.layer.cornerRadius = 36
        
        view.addSubviews(
            titleLabel, profileBgView, profileImg,
            nicknameLabel, nicknameTextField, nicknameUnderlineView,
            emailLabel, emailTextField, emailUnderlineView,
            completeButton, activity
        )

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(86)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        profileBgView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(27.12)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(99.88)
        }
        profileImg.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(25.7)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(97.74)
        }

        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImg.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(45)
        }

        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(nicknameLabel)
            $0.height.equalTo(22)
        }
        
        nicknameUnderlineView.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(nicknameTextField)
            $0.height.equalTo(1)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameUnderlineView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(45)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(emailLabel)
            $0.height.equalTo(22)
        }

        emailUnderlineView.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(emailTextField)
            $0.height.equalTo(1)
        }

        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        activity.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(completeButton.snp.top).offset(-12)
        }
    }
    
    private func bind() {
        nicknameTextField.addTarget(self, action: #selector(nicknameEditingChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailEditingChanged), for: .editingChanged)
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
    }
    
    private func prefill() {
        if let email = initialEmail, !email.isEmpty {
            emailTextField.text = email
        }
        applyNicknameAppearanceAndButtonState()
    }

    // MARK: - Actions
    @objc private func nicknameEditingChanged() {
        applyNicknameAppearanceAndButtonState()
    }
    
    private func applyNicknameAppearanceAndButtonState() {
        let hasNickname = !(nicknameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        nicknameTextField.textColor = hasNickname ? .black : .gray300
        completeButton.setEnabled(isEnabled: hasNickname)
    }
    
    @objc private func emailEditingChanged() {
    }
    
    @objc private func didTapComplete() {
        guard !isRequesting else { return }
        
        let nickname = (nicknameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let dto = RegisterNicknameRequestDto(name: nickname, email: email)
        
        isRequesting = true
        activity.startAnimating()
        completeButton.setEnabled(isEnabled: false)
        
        authService.registerNickname(data: dto) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activity.stopAnimating()
                self.isRequesting = false
                self.applyNicknameAppearanceAndButtonState()
            }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    Toaster.shared.makeToast("닉네임이 등록되었습니다.")
                    let vc = FinishRegisterViewController()
                    vc.isFirst = self.isFirst
                    if let nav = self.navigationController {
                        nav.pushViewController(vc, animated: true)
                    } else {
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print("registerNickname 실패: \(error)")
                DispatchQueue.main.async {
                    Toaster.shared.makeToast("닉네임 등록에 실패했어요. 잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }
}
