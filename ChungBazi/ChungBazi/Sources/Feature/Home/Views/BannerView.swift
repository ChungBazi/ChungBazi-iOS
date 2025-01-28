//
//  BannerView.swift
//  ChungBazi
//
//  Created by 엄민서 on 1/24/25.
//

import UIKit

class BannerView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: AppFontName.pSemiBold, size: 16)
        label.textColor = UIColor.black
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: AppFontName.pMedium, size: 12)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(-10)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(90)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(22)
            make.trailing.equalTo(iconImageView.snp.leading).offset(-8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(22)
        }
    }
}
