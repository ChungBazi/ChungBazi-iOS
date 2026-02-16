//
//  CartCategoryView.swift
//  ChungBazi
//
//  Created by 엄민서 on 2/16/25.
//

import UIKit
import SnapKit

final class CartCategoryView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ptdSemiBoldFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let dottedLineView: DottedLineView = {
        let view = DottedLineView()
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubviews(dottedLineView, titleLabel)
        
        dottedLineView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dottedLineView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(32)
        }
    }

    func configure(with category: String) {
        titleLabel.text = category
    }
}
