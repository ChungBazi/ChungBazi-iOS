//
//  NicknameRegisterViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/1/25.
//

import UIKit
import SnapKit
import Then

final class NicknameRegisterViewController: UIViewController {
    
    private let email: String
    private var isNicknameValid: Bool = false {
        didSet {
            completeButton.setEnabled(isEnabled: isNicknameValid)
        }
    }
    
    // MARK: - Init
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "청바지에서 사용할\n정보를 알려주세요!"
        $0.numberOfLines = 2
        $0.textColor = .black
        $0.font = .ptdExtraBoldFont(ofSize: 20)
        $0.textAlignment = .center
    }

    private let nicknameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray800
    }

    private let nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임을 입력하세요."
        $0.font = .ptdRegularFont(ofSize: 14)
        $0.textColor = .black
        $0.autocapitalizationType = .none
    }

    private let checkDuplicateButton = UIButton(type: .system).then {
        $0.setTitle("중복 확인", for: .normal)
        $0.setTitleColor(.gray800, for: .normal)
        $0.titleLabel?.font = .ptdMediumFont(ofSize: 14)
    }

    private let underlineView = UIView().then {
        $0.backgroundColor = .gray300
    }

    private let statusLabel = UILabel().then {
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .clear
    }

    private let completeButton = CustomActiveButton(title: "완료", isEnabled: false)


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupActions()
    }

    // MARK: - Setup
    private func setupLayout() {
        [titleLabel, nicknameLabel, nicknameTextField, checkDuplicateButton,
         underlineView, statusLabel, completeButton].forEach { view.addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(28)
            $0.centerX.equalToSuperview()
        }

        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().inset(24)
        }

        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalTo(checkDuplicateButton.snp.leading).offset(-12)
        }

        checkDuplicateButton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameTextField)
            $0.trailing.equalToSuperview().inset(24)
        }

        underlineView.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(1)
        }

        statusLabel.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(24)
        }

        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func setupActions() {
        checkDuplicateButton.addTarget(self, action: #selector(handleCheckDuplicate), for: .touchUpInside)
    }

    // MARK: - Action
    @objc private func handleCheckDuplicate() {
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if nickname.isEmpty {
            updateStatus(text: "", color: .clear, underline: .gray300)
            isNicknameValid = false
        } else if nickname == "" {
            updateStatus(text: "중복 된 닉네임 입니다.", color: .red, underline: .red)
            isNicknameValid = false
        } else {
            updateStatus(text: "사용 가능한 닉네임 입니다.", color: .blue500, underline: .blue500)
            isNicknameValid = true
        }
    }

    private func updateStatus(text: String, color: UIColor, underline: UIColor) {
        statusLabel.text = text
        statusLabel.textColor = color
        underlineView.backgroundColor = underline
    }
}
