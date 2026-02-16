//
//  CalendarDetailDocumentReferenceView.swift
//  ChungBazi
//
//  Created by 신호연 on 1/21/25.
//

import UIKit
import SnapKit
import Then

final class CalendarDetailDocumentReferenceView: UIView {
    
    private let documentText = B16_M(text: "").then {
        $0.lineBreakMode = .byCharWrapping
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(documentText)
        documentText.lineBreakMode = .byCharWrapping
        documentText.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
    }
    
    func update(policy: Policy) {
        documentText.text = policy.documentText.isEmpty ? "서류 참고 내용 없음" : policy.documentText
        documentText.setLineSpacing(ratio: 1.17)
    }
}
