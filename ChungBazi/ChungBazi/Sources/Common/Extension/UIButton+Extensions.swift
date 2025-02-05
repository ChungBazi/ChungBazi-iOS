//
//  UIButton+Extensions.swift
//  ChungBazi
//
//  Created by 신호연 on 1/19/25.
//

import UIKit
import Then

extension UIButton {
    /// UIButton 생성과 속성 결정
    static func create(
        title: String = "",
        titleColor: UIColor = .gray800,
        backgroundColor: UIColor = .clear,
        /// B16_M를 기본으로
        font: UIFont = UIFont.ptdMediumFont(ofSize: 16),
        cornerRadius: CGFloat = 0
    ) -> UIButton {
        return UIButton(type: .system).then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(titleColor, for: .normal)
            $0.backgroundColor = backgroundColor
            $0.titleLabel?.font = font
            $0.layer.cornerRadius = cornerRadius
        }
    }
    
    /// 이미지 버튼
    static func createWithImage(
        image: UIImage?,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        cornerRadius: CGFloat = 0,
        target: Any? = nil,
        action: Selector? = nil,
        touchAreaInsets: UIEdgeInsets = .zero
    ) -> UIButton {
        let button = UIButton(type: .system).then {
            $0.setImage(image, for: .normal)
            $0.imageView?.contentMode = contentMode
            $0.clipsToBounds = true
            $0.layer.cornerRadius = cornerRadius
            $0.backgroundColor = .clear
            $0.contentEdgeInsets = touchAreaInsets
        }
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        return button
    }
}
