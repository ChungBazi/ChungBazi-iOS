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

    private let policyStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.distribution = .fill
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubviews(titleLabel, policyStackView)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }

        policyStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
}
