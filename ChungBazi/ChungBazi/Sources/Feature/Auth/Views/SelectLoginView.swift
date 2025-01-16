//
//  SelectLoginView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit
import SnapKit
import Then

class SelectLoginView: UIView {
    
    private let subTitle = UILabel().then {
        $0.text = "청년 정책 지원 플랫폼"
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .gray100
    }
    
    private let title = UILabel().then {
        $0.text = "전정책도 쉽고 간편하게,\n청바지"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 32)
        $0.textColor = .white
    }
    
    private let logo = UIImageView().then {
        $0.image = UIImage(named: "bazi")
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
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
        [subTitle, title, logo].forEach { self.addSubview($0) }
    }
    
    private func setConstraints() {
        subTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(112)
            $0.leading.equalToSuperview().offset(45)
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(subTitle.snp.bottom).offset(21)
            $0.leading.equalTo(subTitle.snp.leading)
        }
        
        logo.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(70)
            $0.centerX.equalToSuperview()
        }
    }

}
