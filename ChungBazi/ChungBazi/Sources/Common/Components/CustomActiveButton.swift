//
//  CustomActiveButton.swift
//  ChungBazi
//
//  Created by 이현주 on 1/17/25.
//

import UIKit
import SnapKit

class CustomActiveButton: UIButton {

    // MARK: - Properties
    /// 버튼 활성화 상태에서의 기본 배경색
    private var originalBackgroundColor: UIColor = .blue700
    private var originaltitleColor: UIColor = .white
    
    // MARK: - Initializer
    init(
        backgroundColor: UIColor = .gray200,
        title: String = "",
        titleColor: UIColor = .gray50,
        radius: CGFloat = 10,
        isEnabled: Bool? = nil
    ) {
        super.init(frame: .zero)
        configureButton(
            title: title,
            titleColor: titleColor,
            radius: radius,
            backgroundColor: backgroundColor,
            isEnabled: isEnabled ?? true
        )
        setDefaultHeight(40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    /// 버튼 설정 업데이트
    func configure(
        title: String,
        titleColor: UIColor,
        radius: CGFloat?,
        backgroundColor: UIColor,
        isEnabled: Bool?
    ) {
        configureButton(
            title: title,
            titleColor: titleColor,
            radius: radius ?? 10,
            backgroundColor: backgroundColor,
            isEnabled: isEnabled ?? true
        )
    }
    
    /// 버튼 활성화 상태 업데이트
    func setEnabled(_ isEnabled: Bool?) {
        self.isEnabled = isEnabled ?? true
        updateBackgroundNTitleColor()
    }
    
    // MARK: - Private Helper Methods
    private func configureButton(
        title: String,
        titleColor: UIColor,
        radius: CGFloat,
        backgroundColor: UIColor,
        isEnabled: Bool
    ) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 14)
        self.layer.cornerRadius = radius
        self.originalBackgroundColor = backgroundColor
        self.isEnabled = isEnabled
        updateBackgroundNTitleColor()
    }
    
    private func updateBackgroundNTitleColor() {
        self.backgroundColor = self.isEnabled ? originalBackgroundColor : .gray200
        self.setTitleColor(isEnabled ? originaltitleColor : .gray50, for: .normal)
    }
    
    private func setDefaultHeight(_ height: CGFloat) {
        self.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
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
//    titleColor: .red,
//    radius: nil,
//    backgroundColor: .systemGray,
//    isEnabled: false
//)
//
//// 활성화 상태 변경
//button.setEnabled(true)
