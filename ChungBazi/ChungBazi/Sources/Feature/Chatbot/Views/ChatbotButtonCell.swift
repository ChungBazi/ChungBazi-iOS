//
//  ChatbotButtonView.swift
//  ChungBazi
//
//  Created by 신호연 on 6/8/25.
//

import UIKit
import Then

/**
 챗봇 추천 버튼
 - 버튼형 정책 선택(예: 인기 정책, 월세 지원...)
 */

final class ChatbotButtonView: UIButton {
    
    enum Design {
        case blue
        case normal
    }
    
    // MARK: - Init
    init(title: String, design: Design) {
        super.init(frame: .zero)
        
        setupStyle(title: title, design: design)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupStyle(title: String, design: Design) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
        self.contentEdgeInsets = UIEdgeInsets(top: 6, left: 13, bottom: 6, right: 13)
        self.layer.cornerRadius = 14
        self.layer.masksToBounds = true
        
        switch design {
        case .blue:
            self.setTitleColor(.blue700, for: .normal)
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.blue700.cgColor
            self.backgroundColor = .white
        case .normal:
            self.setTitleColor(.gray800, for: .normal)
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
            self.backgroundColor = .white
        }
    }
}
