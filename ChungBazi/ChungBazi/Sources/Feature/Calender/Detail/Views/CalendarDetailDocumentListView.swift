//
//  CalendarDetailDocumentListView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/21/25.
//

import UIKit
import SnapKit
import Then

final class CalendarDetailDocumentListView: UIView {
    
    private let addButton = CustomButton(backgroundColor: .white, titleText: "서류 추가하기", titleColor: .black, borderWidth: 1, borderColor: .gray400)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.width.equalTo(118)
        }
    }
}
