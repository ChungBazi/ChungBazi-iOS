//
//  EmptyBaroWithTitleView.swift
//  ChungBazi
//
//  Created by 이현주 on 2/16/26.
//

import UIKit

class EmptyBaroWithTitleView: UIView {
    
    private let title = B16_SB(text: "", textColor: .gray500)
    
    private lazy var emptyBaro = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.image = .emptyBaro
    }

    init(title: String) {
        super.init(frame: .zero)
        self.title.text = title
        self.title.setLineSpacing()
        self.title.textAlignment = .center
        addComponents()
        setConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [emptyBaro, title].forEach { self.addSubview($0) }
    }
    
    private func setConstraints() {
        let stack = UIStackView(arrangedSubviews: [emptyBaro, title])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 0
        
        addSubview(stack)
        
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyBaro.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(emptyBaro.snp.width)
        }
    }
}
