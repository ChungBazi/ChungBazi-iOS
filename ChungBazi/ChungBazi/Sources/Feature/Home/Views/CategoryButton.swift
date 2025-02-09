//
//  CategoryButton.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit
import SnapKit
import Then

class CategoryButton: UIButton {

    let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    let customTitleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .gray800
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.do {
            $0.backgroundColor = .blue100
            $0.layer.cornerRadius = 10
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubviews(iconImageView, customTitleLabel)

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(31)
        }

        customTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func buttonTapped() {
        print("카테고리 버튼 클릭됨: \(customTitleLabel.text ?? "알 수 없음")")
    }
}
