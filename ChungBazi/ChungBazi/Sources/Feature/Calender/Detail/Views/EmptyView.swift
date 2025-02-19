//
//  EmptyView.swift
//  ChungBazi
//
//  Created by 이현주 on 2/18/25.
//

import UIKit

class EmptyView: UIView {
    
    let addButton = CustomButton(backgroundColor: .blue100, titleText: "추가하기", titleColor: .black)
    
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
            $0.top.equalToSuperview().offset(15)
            $0.horizontalEdges.equalToSuperview().inset(105)
            $0.centerX.equalToSuperview()
        }
    }
}
