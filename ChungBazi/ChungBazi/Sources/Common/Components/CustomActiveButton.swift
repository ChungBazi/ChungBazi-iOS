//
//  CustomActiveButton.swift
//  ChungBazi
//
//  Created by 이현주 on 1/17/25.
//

import UIKit
import SnapKit

class CustomActiveButton: UIButton {
    
    public init(
        title: String = "",
        isEnabled: Bool = true
    ) {
        super.init(frame: .zero)
        self.isEnabled = isEnabled
        self.setTitle(title, for: .normal)
        self.setTitleColor(isEnabled ? .white : .gray50, for: .normal)
        self.backgroundColor = isEnabled ? .blue700 : .gray200
        
        self.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        self.layer.cornerRadius = 10
        
        self.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    public func configure(
        title: String,
        isEnabled: Bool
    ) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(isEnabled ? .white : .gray50, for: .normal)
        self.backgroundColor = isEnabled ? .blue700 : .gray200
    }
    
    public func setEnabled(isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.backgroundColor = isEnabled ? .blue700 : .gray200
        self.setTitleColor(isEnabled ? .white : .gray50, for: .normal)
    }
}

// MARK: 버튼 사용 예시
// disabled일 때인 회색에서 -> enabled일 때인 파란색으로 변경되는 버튼
//title과 isEnabled만 설정해주심 됩니다.
//constraints는 너비만 잡아주심 됩니다. (BTN-L, BTN-M, BTN-S)

//// 버튼 생성
//let button = CustomButton(
//    title: "확인",
//    isEnabled: true
//)
//
//// 버튼 구성 업데이트
//button.configure(
//    title: "취소",
//    isEnabled: false
//)
//
//// 활성화 상태 변경
//button.setEnabled(true)

