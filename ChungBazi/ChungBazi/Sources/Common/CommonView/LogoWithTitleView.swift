//
//  LogoWithTitleView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit

class LogoWithTitleView: UIView {
    
    private let title = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.textColor = .white
        $0.numberOfLines = 2
    }
    
    private lazy var logo = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
    }

    init(image: ImageResource, title: String) {
        super.init(frame: .zero)
        self.title.text = title
        self.title.setLineSpacing()
        self.title.textAlignment = .center
        self.logo.image = UIImage(resource: image)
        self.backgroundColor = .blue700
        addComponents()
        setConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [logo, title].forEach { self.addSubview($0) }
    }
    
    private func setConstraints() {
        
        logo.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.superViewHeight * 0.26)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.superViewHeight * 0.35)
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(logo.snp.bottom).offset(21)
            $0.centerX.equalToSuperview()
        }
    }
}
