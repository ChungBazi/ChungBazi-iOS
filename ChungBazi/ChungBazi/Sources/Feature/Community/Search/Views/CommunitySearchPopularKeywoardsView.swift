//
//  CommunitySearchPopularKeywoardsView.swift
//  ChungBazi
//
//  Created by 신호연 on 2/9/25.
//

import UIKit
import SnapKit
import Then

final class CommunitySearchPopularKeywoardsView: UIView {
    // API 없음
    private let keywords = ["지원금", "인턴쉽", "취업", "진로", "대기업", "월세지원"]
    
    private lazy var wrapStackView = UIWrapStackView().then {
        $0.spacing = 9
        $0.verticalSpacing = 9
    }
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(wrapStackView)
        
        for keyword in keywords {
            let button = CustomButton(
                backgroundColor: .clear,
                titleText: keyword,
                titleColor: .gray800,
                borderWidth: 1,
                borderColor: .gray400
            )
            
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            
            button.snp.removeConstraints()
            button.snp.makeConstraints {
                $0.height.equalTo(36)
            }
            
            wrapStackView.addArrangedSubview(button)
        }
        
        wrapStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
