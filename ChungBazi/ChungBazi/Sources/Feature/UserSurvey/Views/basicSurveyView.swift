//
//  basicSurveyView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit

class basicSurveyView: UIView {

    private let title = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 24)
        $0.textColor = .black
        $0.numberOfLines = 2
    }
    
    private lazy var pageLogo = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
    }
    
    public lazy var kakaoBtn = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        // 이미지 설정
        configuration.image = UIImage(named: "kakao")?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 86

        // 타이틀 속성 설정
        let attributes: AttributeContainer = AttributeContainer([
            .font: UIFont.ptdSemiBoldFont(ofSize: 15), .foregroundColor: UIColor.black])
        configuration.attributedTitle = AttributedString("카카오 로그인", attributes: attributes)
        configuration.titleAlignment = .center
        
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 86) // 여백 설정

        // 버튼 설정
        $0.configuration = configuration
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.backgroundColor = UIColor(hex: "#FEE500")
    }

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
        [labelStackView, logo, kakaoBtn].forEach { self.addSubview($0) }
    }
    
    private func setConstraints() {
        
        labelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(112)
            $0.centerX.equalToSuperview()
        }
        
        logo.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(70)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.superViewHeight * 0.3)
        }
        
        kakaoBtn.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(48)
        }
    }

}
