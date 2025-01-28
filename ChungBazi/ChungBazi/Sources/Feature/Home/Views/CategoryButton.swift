//
//  CategoryButton.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit

class CategoryButton: UIView {

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let titleLabel: UILabel = {
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(iconImageView)
        addSubview(titleLabel)

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }
}
