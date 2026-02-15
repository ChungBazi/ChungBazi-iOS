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
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
    }

    init(image: ImageResource, title: String) {
        super.init(frame: .zero)
        self.title.text = title
        self.title.setLineSpacing()
        self.title.textAlignment = .center
        self.logo.image = UIImage(resource: image)
        self.backgroundColor = .clear
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
        let stack = UIStackView(arrangedSubviews: [logo, title])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 21
        
        addSubview(stack)
        
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        logo.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(logo.snp.width)
        }
    }
}
