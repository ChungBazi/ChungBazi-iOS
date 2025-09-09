//
//  SelectLoginView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit
import SnapKit
import Then
import AuthenticationServices

class SelectLoginView: UIView {
    
    private let title = UILabel().then {
        let fullText = "정책도 쉽고 간편하게,\n청바지"
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [.font: UIFont.ptdSemiBoldFont(ofSize: 32)])
        
        attributedString.addAttribute(.font, value: UIFont.afgRegularFont(ofSize: 32), range: (fullText as NSString).range(of: "청바지"))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2 // 줄 간격 적용
        
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        $0.attributedText = attributedString
        $0.textColor = .white
        $0.numberOfLines = 2
    }
    
    private lazy var labelStackView = UIStackView(arrangedSubviews: [title]).then {
        $0.axis = .vertical
        $0.spacing = 21
        $0.alignment = .leading
    }
    
    // MARK: - 이메일 그룹
    private let emailLabel = UILabel().then {
        $0.text = "이메일"
        $0.textColor = .white
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    
    public let emailField = UITextField().then {
        $0.placeholder = "이메일을 입력하세요."
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
        $0.keyboardType = .emailAddress
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.returnKeyType = .next
        $0.attributedPlaceholder = NSAttributedString(
            string: "이메일을 입력하세요.",
            attributes: [.foregroundColor: UIColor.gray300]
        )
    }
    
    private let emailUnderline = UIView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - 비밀번호 그룹
    private let passwordLabel = UILabel().then {
        $0.text = "비밀번호"
        $0.textColor = .white
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    
    public let passwordField = UITextField().then {
        $0.placeholder = "비밀번호를 입력하세요."
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .gray300
        $0.isSecureTextEntry = true
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "비밀번호를 입력하세요.",
            attributes: [.foregroundColor: UIColor.gray300]
        )
    }
    
    private let passwordUnderline = UIView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - Buttons
    // 시작하기 버튼
    public let startButton = UIButton(type: .system).then {
        $0.setTitle("시작하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .ptdMediumFont(ofSize: 16)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    // 하단 링크: 아이디 찾기 | 비밀번호 찾기 | 회원가입
    public let findIdButton = UIButton(type: .system).then {
        $0.setTitle("아이디 찾기", for: .normal)
        $0.setTitleColor(UIColor.gray100, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
    }
    public let findPwButton = UIButton(type: .system).then {
        $0.setTitle("비밀번호 찾기", for: .normal)
        $0.setTitleColor(UIColor.gray100, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
    }
    public let signUpButton = UIButton(type: .system).then {
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(UIColor.gray100, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
    }
    private let divider1 = UIView().then { $0.backgroundColor = UIColor.gray300 }
    private let divider2 = UIView().then { $0.backgroundColor = UIColor.gray300 }
    private lazy var linkRow = UIStackView(arrangedSubviews: [
        findIdButton, divider1, findPwButton, divider2, signUpButton
    ]).then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 14
        $0.distribution = .equalCentering
    }
    
    // MARK: - 소셜 로그인
    public let appleBtn = ASAuthorizationAppleIDButton()
    
    public let kakaoBtn = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        // 이미지 설정
        configuration.image = UIImage(named: "kakao")?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 14

        // 타이틀 속성 설정
        let attributes: AttributeContainer = AttributeContainer([
            .font: UIFont.ptdSemiBoldFont(ofSize: 15), .foregroundColor: UIColor.black.withAlphaComponent(0.85)])
        configuration.attributedTitle = AttributedString("카카오 로그인", attributes: attributes)
        configuration.titleAlignment = .center
        
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 14) // 여백 설정

        // 버튼 설정
        $0.configuration = configuration
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.backgroundColor = UIColor(hex: "#FEE500")
    }
    
    // 네이버, 구글 소셜 로그인
    public let otherMethodButton = UIButton(type: .system).then {
        let title = "다른 방법으로 로그인"
        let attributed = NSMutableAttributedString(
            string: title,
            attributes: [
                .font: UIFont.ptdMediumFont(ofSize: 14),
                .foregroundColor: UIColor.gray100
            ]
        )
        // 밑줄
        attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        $0.setAttributedTitle(attributed, for: .normal)
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .blue700
        addComponents()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [
            labelStackView,
            emailLabel, emailField, emailUnderline,
            passwordLabel, passwordField, passwordUnderline,
            startButton,
            linkRow,
            appleBtn, kakaoBtn, otherMethodButton
        ].forEach(addSubview)
    }
    
    private func setConstraints() {
        
        labelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(101)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(labelStackView.snp.bottom).offset(56)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
        
        emailField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(emailLabel)
            $0.height.equalTo(22)
        }
        
        emailUnderline.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(emailField)
            $0.height.equalTo(1)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(emailUnderline.snp.bottom).offset(21)
            $0.leading.trailing.equalTo(emailLabel)
        }
        
        passwordField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(emailLabel)
            $0.height.equalTo(22)
        }
        
        passwordUnderline.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(passwordField)
            $0.height.equalTo(1)
        }
        
        startButton.snp.makeConstraints {
            $0.top.equalTo(passwordUnderline.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(48)
        }
        
        divider1.snp.makeConstraints { $0.width.equalTo(1); $0.height.equalTo(17.5) }
        divider2.snp.makeConstraints { $0.width.equalTo(1); $0.height.equalTo(17.5) }
        
        linkRow.snp.makeConstraints {
            $0.top.equalTo(startButton.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
        }
        
        appleBtn.snp.makeConstraints {
            $0.top.equalTo(linkRow.snp.bottom).offset(70)
            $0.leading.trailing.equalToSuperview().inset(17)
            $0.height.equalTo(48)
        }
        
        kakaoBtn.snp.makeConstraints {
            $0.top.equalTo(appleBtn.snp.bottom).offset(11)
            $0.leading.trailing.equalTo(appleBtn)
            $0.height.equalTo(48)
        }
        
        otherMethodButton.snp.makeConstraints {
            $0.top.equalTo(kakaoBtn.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
        }
    }
}
