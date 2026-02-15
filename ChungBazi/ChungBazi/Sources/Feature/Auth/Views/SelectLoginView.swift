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
    
    // MARK: - Top Title
    private let title = UILabel().then {
        let fullText = "정책도 쉽고\n간편하게, 청바지"
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
    
    // MARK: - Background
    private lazy var loginBG = UIImageView().then {
        $0.image = UIImage(resource: .loginBG)
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        $0.clipsToBounds = true
    }
    
    // MARK: - 소셜 로그인
    public let appleBtn = ASAuthorizationAppleIDButton()
    
    public let kakaoBtn = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        // 이미지 설정
        configuration.image = UIImage(resource: .kakao).withRenderingMode(.alwaysOriginal).withTintColor(.black).resize(to: CGSize(width: 13, height: 13))
        configuration.imagePlacement = .leading
        configuration.imagePadding = 7
        
        // 타이틀 속성 설정
        let attributes: AttributeContainer = AttributeContainer([
            .font: UIFont.appleSDSemiBoldFont(ofSize: 17), .foregroundColor: UIColor.black.withAlphaComponent(0.85)])
        configuration.attributedTitle = AttributedString("카카오로 로그인", attributes: attributes)
        configuration.titleAlignment = .center
        
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7) // 여백 설정
        
        // 버튼 설정
        $0.configuration = configuration
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.backgroundColor = UIColor(hex: "#FEE500")
    }
    
    private lazy var loginButtonStackView = UIStackView(arrangedSubviews: [appleBtn, kakaoBtn]).then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    // 하단 링크: 회원가입 | 이메일 로그인
    public let signUpButton = UIButton(type: .system).then {
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(UIColor.gray800, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
    }
    public let emailLoginButton = UIButton(type: .system).then {
        $0.setTitle("이메일 로그인", for: .normal)
        $0.setTitleColor(UIColor.gray800, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
    }
    private let divider = UIView().then { $0.backgroundColor = UIColor.gray800 }
    
    private let linkRow = UIView()
    private let leftContainer = UIView()
    private let rightContainer = UIView()
    
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
    
    func addComponents() {
        addSubview(loginBG)
        loginBG.addSubviews(title, loginButtonStackView, linkRow)
        linkRow.addSubviews(divider, leftContainer, rightContainer)
        leftContainer.addSubview(signUpButton)
        rightContainer.addSubview(emailLoginButton)
    }
    
    private func setConstraints() {
        loginBG.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(101)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(kakaoBtn.snp.bottom).offset(31)
            $0.center.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(17.5)
        }
        
        linkRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(37.5)
        }
        
        leftContainer.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(divider.snp.leading)
            $0.verticalEdges.equalTo(divider.snp.verticalEdges)
        }
        
        rightContainer.snp.makeConstraints {
            $0.leading.equalTo(divider.snp.trailing)
            $0.trailing.equalToSuperview().inset(16)
            $0.verticalEdges.equalTo(divider.snp.verticalEdges)
        }
        
        signUpButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        emailLoginButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loginButtonStackView.snp.makeConstraints {
            $0.bottom.equalTo(linkRow.snp.top).offset(-38)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        appleBtn.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        kakaoBtn.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
}
