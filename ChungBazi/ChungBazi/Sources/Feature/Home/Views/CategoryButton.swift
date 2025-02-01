//
//  CategoryButton.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit

class CategoryButton: UIButton {

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let customTitleLabel: UILabel = { 
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: AppFontName.pMedium, size: 16)
        label.textColor = AppColor.gray800
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColor.blue100
        layer.cornerRadius = 10
        setupLayout()
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(iconImageView)
        addSubview(customTitleLabel)

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
