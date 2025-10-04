//
//  NicknameRegisterViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/1/25.
//
// TODO: - 모든 방법의 로그인 화면에서 닉네임 설정으로 연결되기
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
        $0.text = "청바지에서 사용할\n닉네임을 알려주세요!"
        $0.numberOfLines = 2
        $0.textColor = .black
        $0.font = .ptdExtraBoldFont(ofSize: 20)
        $0.textAlignment = .center
    }

    // TODO: - 프로필 사진 추가 완료하기
    private let profileImg = UIImageView().then {
        $0.image = UIImage(named: "basicBaro")
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
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

    private let emailLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray800
    }
    
    // TODO: - 전에 설정한 이메일 자동으로 연동되기
    private let emailTextField = UITextField().then {
        $0.placeholder = "이메일"
        $0.font = .ptdRegularFont(ofSize: 14)
        $0.textColor = .black
        $0.autocapitalizationType = .none
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
    }

    // MARK: - Setup
    private func setupLayout() {
        [titleLabel, nicknameLabel, nicknameTextField,
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
        }
        
        underlineView.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(1)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(40)
            $0.leading.equalToSuperview().inset(24)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(24)
        }
       

        underlineView.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(8)
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

    private func updateStatus(text: String, color: UIColor, underline: UIColor) {
        statusLabel.text = text
        statusLabel.textColor = color
        underlineView.backgroundColor = underline
    }
}
