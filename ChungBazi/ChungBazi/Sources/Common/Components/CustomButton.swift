//
//  CustomButton.swift
//  ChungBazi
//
//  Created by 이현주 on 1/17/25.
//

import UIKit
import SnapKit

// 파라미터에 따라 커스텀되는 버튼
//constraints는 너비만 잡아주심 됩니다. (BTN-L, BTN-M, BTN-S)
class CustomButton: UIButton {
    
    init(
        backgroundColor: UIColor,
        titleText: String,
        titleColor: UIColor,
        borderWidth: CGFloat = 0,
        borderColor: UIColor = .clear
    ) {
        super.init(frame: .zero)
        
        // 버튼의 속성 설정
        self.backgroundColor = backgroundColor
        self.setTitle(titleText, for: .normal)
        self.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        self.setTitleColor(titleColor, for: .normal)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = 10
        
        setDefaultHeight(48)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDefaultHeight(_ height: CGFloat) {
        self.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }
}
